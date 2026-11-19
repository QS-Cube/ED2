#!/usr/bin/env python3
"""Pre-release citation/version guard. Does not create a release or tag.

Development mode requires no release-specific version/date in CITATION.cff.
--release-tag vX.Y.Z checks metadata consistency for a prospective release.
"""
import argparse
from datetime import date
import json
from pathlib import Path
import re


def field(text, name):
    values = re.findall("^" + re.escape(name) + r":\s*(.*?)\s*$", text, re.M)
    if len(values) > 1:
        raise ValueError(f"Duplicate {name}")
    return values[0].strip("\"'") if values else None


def validate(root, tag):
    configure = (root / "configure.ac").read_text()
    citation = (root / "CITATION.cff").read_text()
    match = re.search(r"^AC_INIT\(\s*\[([^]]+)\]\s*,\s*\[([^]]+)\]", configure, re.M)
    if not match or match.group(1) != "QS3-ED2":
        raise ValueError("Cannot identify expected Autotools package/version")
    package_version = match.group(2)
    if field(citation, "cff-version") != "1.2.0":
        raise ValueError("Expected CFF format 1.2.0")
    version, released = field(citation, "version"), field(citation, "date-released")
    if not tag:
        if version is not None or released is not None:
            raise ValueError("Unreleased development: remove unissued CFF version/date")
        return {"mode": "unreleased_development",
                "autotools_package_version": package_version,
                "citation": "Use the full Git commit, not this package number"}
    if not re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+", tag):
        raise ValueError("Release tag must be vMAJOR.MINOR.PATCH")
    if version != tag[1:] or package_version != version:
        raise ValueError(f"Version mismatch: tag={tag}, AC_INIT={package_version}, CFF={version}")
    if not released:
        raise ValueError("Tagged release requires CFF date-released")
    try:
        date.fromisoformat(released)
    except ValueError as error:
        raise ValueError(f"Invalid CFF release date: {released}") from error
    return {"mode": "release_metadata", "version": version, "date_released": released}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--release-tag", help="Prospective vX.Y.Z tag, not an action")
    args = parser.parse_args()
    try:
        result = {"status": "PASS", **validate(args.repo, args.release_tag)}
    except (OSError, ValueError) as error:
        result = {"status": "FAIL", "error": str(error)}
    print(json.dumps(result, indent=2, sort_keys=True))
    return int(result["status"] != "PASS")


if __name__ == "__main__":
    raise SystemExit(main())
