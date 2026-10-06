#!/usr/bin/env bash
# Assembles the deployable site into $1: copies site/, self-hosts the fonts with their OFL
# licences (visitors make no font requests to a third party), and bakes in the GitHub star
# count, shown only from 5 stars (visitors make no request to GitHub).
set -euo pipefail
out="${1:?usage: build.sh OUTPUT_DIR}"
here="$(cd "$(dirname "$0")" && pwd)"
rm -rf "$out"
mkdir -p "$out"
cp -R "$here"/. "$out"/
rm -f "$out/README.md" "$out/build.sh"

# Pages serves /name from name.html without a redirect, and the Store listing and the OAuth
# consent screen use the no-slash form. One source per page: name.html is made here.
for page in "$out"/*/index.html; do
  dir="$(basename "$(dirname "$page")")"
  case "$dir" in assets | fonts) continue ;; esac
  if [ "$(dirname "$page")" != "$out/$dir" ]; then continue; fi
  if grep -q 'http-equiv="refresh"' "$page"; then
    # a redirect served at /name resolves ../ from the root, so point it at the site root instead
    sed -e 's#url=\.\./"#url=./"#; s#content="0; url=\.\./"#content="0; url=./"#; s#href="\.\./"#href="./"#g' "$page" > "$out/$dir.html"
  else
    cp "$page" "$out/$dir.html"
  fi
done

mkdir -p "$out/fonts"
ua="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
css="https://fonts.googleapis.com/css2?family=Funnel+Display:wght@500;600;700&family=Funnel+Sans:wght@400;500;600&family=Geist+Mono:wght@400;500&display=swap"
curl -fsSL -A "$ua" "$css" -o "$out/fonts/google.css"
grep -oE 'https://fonts\.gstatic\.com/[^)]+' "$out/fonts/google.css" | sort -u > "$out/fonts/urls.txt"
test -s "$out/fonts/urls.txt"
while read -r u; do curl -fsSL "$u" -o "$out/fonts/$(basename "$u")"; done < "$out/fonts/urls.txt"
sed -E 's#https://fonts\.gstatic\.com/[^)]*/([^/)]+)#\1#g' "$out/fonts/google.css" > "$out/fonts/fonts.css"
rm "$out/fonts/google.css" "$out/fonts/urls.txt"
for f in funneldisplay funnelsans geistmono; do
  curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/$f/OFL.txt" -o "$out/fonts/OFL-$f.txt"
done

repo="${GH_REPO:-lamemustafa/pack}"
stars="$(curl -fsSL -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$repo" | sed -nE 's/.*"stargazers_count": *([0-9]+).*/\1/p' | head -1 || true)"
if [ -n "$stars" ] && [ "$stars" -ge 5 ]; then
  label="$stars"
  if [ "$stars" -ge 1000 ]; then label="$(awk -v n="$stars" 'BEGIN { printf "%.1fk", n / 1000 }' | sed 's/\.0k$/k/')"; fi
  # the tag may span lines after formatting, so match across whitespace
  find "$out" -name '*.html' -exec perl -0pi -e "s#data-stars\\s+hidden\\s*>\\s*</b\\s*>#data-stars>${label}</b>#g" {} +
  if grep -rlq 'data-stars hidden' "$out" --include='*.html'; then
    echo "star count ${stars} was not written into the pages" >&2
    exit 1
  fi
fi
echo "site assembled in $out (stars: ${stars:-unknown})"
