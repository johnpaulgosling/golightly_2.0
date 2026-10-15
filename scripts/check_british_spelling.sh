#!/usr/bin/env bash
# Flags common American spellings and em dashes. Exit status is 1 if anything is found.
# Usage: scripts/check_british_spelling.sh [PATH...]   (defaults to the repository root)
# See STYLE.md, section 2, for the rules this encodes and the accepted exceptions.

set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ "$#" -eq 0 ]; then
  set -- "$root"
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required." >&2
  exit 2
fi

# Em dashes are prohibited by the user's writing rules (see STYLE.md, section 8).
pattern='\x{2014}|'
# -ize/-yze/-ization (excluding genuine -size and -ize words that are not the suffix),
# -or/-our, -er/-re, -ense/-ence, single/double l, and a few others.
pattern+='\b(?!(?:size|sizes|sized|sizing|sizeable|prize|prizes|seize|seizes|seized|seizing|capsize|capsized|resize|resized|resizing|downsize|downsized|upsize|upsized|oversize|oversized)\b)[a-z]+iz(?:e|es|ed|ing|er|ers|ation|ations)\b'
pattern+='|\b[a-z]*(?:yz(?:e|es|ed|ing)|behavior|favor|honor|labor|neighbor|color|flavor|humor|rumor|vapor)[a-z]*\b'
pattern+='|\b(?:center|centers|centered|meter|liter|defense|offense|license|modeling|modeled|labeled|labeling|canceled|canceling|traveled|traveling|fulfill|enrollment|judgment|gray|catalog|artifact|artifacts|skeptic|skeptical|analog|toward|amongst|acknowledgment|acknowledgments|aluminum)\b'

rg --no-heading -n -i -P "$pattern" \
  --glob '!STYLE.md' \
  --glob '!Source papers/**' \
  --glob '!scripts/check_british_spelling.sh' \
  --glob '!.git/**' \
  "$@"
status=$?

if [ "$status" -eq 1 ]; then
  echo "No American spellings or em dashes found."
  exit 0
fi
if [ "$status" -eq 0 ]; then
  echo
  echo "Possible American spellings or em dashes found (above). Check STYLE.md section 2 for exceptions" >&2
  echo "(proper nouns, reference titles, quotations, code identifiers, legal boilerplate)." >&2
  exit 1
fi
exit "$status"
