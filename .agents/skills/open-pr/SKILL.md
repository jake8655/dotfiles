---
name: open-pr
description: Open a GitHub pull request for the current branch. Use when asked to create, open, or submit a PR.
---

# Open a PR

Inspect the branch, diff, and commits before writing the PR. Push the branch if needed.

- Use a Conventional Commit title: `type(scope): summary`.
- Keep the body brief and use simple language.
- Explain the problem and how the PR fixes it. Focus on the outcome, not implementation details or a list of files.
- Never add a `Tests`, `Testing`, `Validation`, or `Verification` section.
- If the change adds new tests, mention that only as part of the outcome paragraph.
- For significant visual changes, capture a screenshot or short video. Use T3 Code's built-in browser recording for browser videos, then upload the result with `file-host upload <path>`.

Embed an uploaded image with `![Description](URL)`. GitHub does not embed externally hosted video, so link it through an uploaded preview image with `[![Video preview](IMAGE_URL)](VIDEO_URL)`. If GitHub provides its own video asset URL, place that URL on its own line.
