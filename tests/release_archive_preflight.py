#!/usr/bin/env python3
"""Check unreleased/versioned ED2 dist archive against tracked source bytes."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tarfile

REQUIRED = (
    "README.md", "LICENSE", "CITATION.cff", "configure.ac",
    "source/main.f90", "source/blas_lapack_interfaces.f90",
    "tests/verify_ex9.py", "tests/audit_physics_regression.py",
    "tests/test_ex9_legacy_projection.py", "tests/release_archive_preflight.py",
    "docs/reference/backend-validation.md",
    "docs/reference/release-qualification.md",
)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def git(root, *args):
    return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()


def audit(root, tarball, expected_sha, release_tag):
    sha = git(root, "rev-parse", "HEAD")
    if expected_sha and sha != expected_sha:
        raise ValueError("HEAD and expected full Git SHA differ")
    # Autotools may update tracked, generated build files after a clean
    # checkout. Required scientific/source files must still equal Git HEAD.
    postbuild_modified = git(root, "status", "--porcelain",
                             "--untracked-files=no").splitlines()
    check = [sys.executable, str(root / "tests/check_release_metadata.py"),
             "--repo", str(root)]
    if release_tag:
        check += ["--release-tag", release_tag]
    done = subprocess.run(check, capture_output=True, text=True)
    if done.returncode:
        raise ValueError("Citation/version validation failed: " + done.stdout.strip())
    metadata = json.loads(done.stdout)
    expected = {}
    for name in REQUIRED:
        path = root / name
        if not path.is_file() or path.is_symlink():
            raise ValueError("Missing regular source: " + name)
        if not git(root, "ls-files", "--", name):
            raise ValueError("Untracked required source: " + name)
        disk_bytes = path.read_bytes()
        commit_bytes = subprocess.check_output(
            ["git", "-C", str(root), "show", "HEAD:" + name])
        if disk_bytes != commit_bytes:
            raise ValueError("Tracked required file modified after checkout: " + name)
        expected[name] = sha256(commit_bytes)
    with tarfile.open(tarball, "r:*") as tar:
        members = tar.getmembers()
        if not members:
            raise ValueError("Empty archive")
        parsed = [PurePosixPath(m.name) for m in members]
        if any(p.is_absolute() or ".." in p.parts for p in parsed):
            raise ValueError("Unsafe archive path")
        roots = {p.parts[0] for p in parsed if p.parts}
        if len(roots) != 1:
            raise ValueError("Source archive must have one package root")
        root_dir = next(iter(roots))
        index = {}
        for m in members:
            if m.name in index:
                raise ValueError("Duplicate archive member " + m.name)
            index[m.name] = m
        for name, wanted in expected.items():
            m = index.get(root_dir + "/" + name)
            if m is None or not m.isfile():
                raise ValueError("Missing regular archive member: " + name)
            stream = tar.extractfile(m)
            if stream is None or sha256(stream.read()) != wanted:
                raise ValueError("Archive byte mismatch for " + name)
    return {
        "status": "PASS", "scope": "source/archive byte identity, NOT physics",
        "git_sha": sha, "citation": metadata, "archive_name": tarball.name,
        "archive_sha256": sha256(tarball.read_bytes()), "package_root": root_dir,
        "verified_files": len(REQUIRED), "source_sha256": expected,
        "postbuild_modified_tracked_paths": postbuild_modified,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    ap.add_argument("--archive", type=Path, required=True)
    ap.add_argument("--expected-commit", help="Full 40-character Git SHA")
    ap.add_argument("--release-tag", help="Validate vX.Y.Z metadata, never publish a tag")
    ap.add_argument("--json-out", type=Path)
    args = ap.parse_args()
    try:
        if args.expected_commit and (len(args.expected_commit) != 40 or
             any(c not in "0123456789abcdef" for c in args.expected_commit)):
            raise ValueError("Expected commit must be a full lowercase Git SHA")
        result = audit(args.repo.resolve(), args.archive.resolve(),
                       args.expected_commit, args.release_tag)
    except (OSError, ValueError, subprocess.CalledProcessError, tarfile.TarError,
            json.JSONDecodeError) as exc:
        result = {"status": "FAIL", "error": str(exc)}
    encoded = json.dumps(result, indent=2, sort_keys=True) + "\n"
    print(encoded, end="")
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(encoded)
    return int(result["status"] != "PASS")


if __name__ == "__main__":
    raise SystemExit(main())
