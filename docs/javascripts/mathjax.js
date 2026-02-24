// docs/javascripts/mathjax.js
window.MathJax = {
  tex: {
    inlineMath: [["$", "$"], ["\\(", "\\)"]],
    displayMath: [["$$", "$$"], ["\\[", "\\]"]],
    processEscapes: true,
    processEnvironments: true
  },
  options: {
    // Do not try to typeset code blocks etc.
    skipHtmlTags: ["script", "noscript", "style", "textarea", "pre", "code"]
  }
};
