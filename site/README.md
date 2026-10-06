# pack.complyeaze.com

The public website for ComplyEaze Pack, published to GitHub Pages by
`.github/workflows/site-pages.yml`. Plain HTML and CSS with no third-party scripts. The pages need no build step; `build.sh` runs at
deploy time.

- `index.html` — home page. Its claims follow the Chrome Web Store listing
  (`docs/chrome-web-store/listing.md`): one return period at a time, full year not advertised.
  The "Try it" demo names a one-period ZIP with the rules in
  `src/background/filed-returns-download-filename.ts` and makes a ZIP only when more than one
  document is selected, as `src/background/filed-returns-selected-artifacts.ts` does. Change any
  of these and update the page with it.
- `privacy/`, `terms/`, `support/`, `docs/`, `security/`, `acceptable-use/`,
  `release-automation/` — pages carried over from the previous pack.complyeaze.com with their
  text unchanged (rendered 6 October 2026). The Chrome Web Store listing links to `/gst`,
  `/support`, `/privacy` and `/terms`; the Google OAuth consent screen uses
  `/release-automation`, `/privacy` and `/terms`. `build.sh` also writes each page as `name.html`,
  so Pages serves the address without a trailing slash directly. Do not move these paths.
- The privacy notice and docs were updated on 7 October 2026 for this site and the Store
  build; the storage list now links to the README's Extension Storage section, which is the
  maintained inventory. The terms keep their "alpha" wording until the owner revises them.
- `gst/`, `changelog/`, `source/`, `status/` — redirects for retired addresses.
- `build.sh` — run by the deploy: copies this folder, writes the `name.html` copies, self-hosts
  the fonts with their OFL licences, and bakes in the GitHub star count (shown from 5 stars;
  the build fails if the count cannot be written). Visitors make no requests
  to Google or GitHub.

Preview: `bash site/build.sh /tmp/pack-site && python3 -m http.server -d /tmp/pack-site 8080`.

Brand assets (`favicon.svg`, the PNG icons, `og.png`) are trademarks of SPMS Comply Eaze
Solutions LLP; see `TRADEMARKS.md` and `NOTICE`.
