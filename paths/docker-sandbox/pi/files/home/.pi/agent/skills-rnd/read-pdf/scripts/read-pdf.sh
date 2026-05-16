#!/bin/bash
set -euo pipefail

PDF="$1"
WORK_DIR=$(mktemp -d)
OUT="pdf-summary.md"
PREV_SUMMARY_FILE=$(mktemp)

echo "read-pdf: rendering PDF to PNG (150 DPI)..."
pdftoppm -png -r 150 "$PDF" "$WORK_DIR/page"

TOTAL=$(ls "$WORK_DIR"/page-*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
  echo "read-pdf: no pages produced (check the PDF path and pdftoppm)." >&2
  rm -rf "$WORK_DIR" "$PREV_SUMMARY_FILE"
  exit 1
fi

echo "read-pdf: rendered $TOTAL page(s); summarizing..."

# init or clear summary file
> "$OUT"
PAGE_NUM=0

for IMG in $(ls "$WORK_DIR"/page-*.png 2>/dev/null | sort -V); do
    PAGE_NUM=$((PAGE_NUM + 1))
    echo "read-pdf: [$PAGE_NUM/$TOTAL] $(basename "$IMG") — calling pi…"

    if [ $PAGE_NUM -eq 1 ]; then
        PROMPT="You are a document analysis assistant. Examine this PDF page image and produce a structured summary.

Instructions:
- Transcribe ALL text exactly as it appears, preserving headings, lists, and table content.
- Describe every non-text element: images, charts, diagrams, tables (include values), logos.
- State the overall topic and purpose of this page.
- Use plain prose and bullet points. Do not add commentary or opinions.
- Do not say 'the image shows' — just state what is there."
    else
        PREV=$(cat "$PREV_SUMMARY_FILE")
        PROMPT="You are a document analysis assistant. Examine this PDF page image and produce a structured summary.

Context — previous page summary:
$PREV

Instructions:
- Transcribe ALL text exactly as it appears, preserving headings, lists, and table content.
- Describe every non-text element: images, charts, diagrams, tables (include values), logos.
- Note explicitly how this page continues, contrasts, or relates to the previous page.
- Use plain prose and bullet points. Do not add commentary or opinions.
- Do not say 'the image shows' — just state what is there."
    fi

    echo "## Page $PAGE_NUM" >> "$OUT"
    SUMMARY=$(pi -p "@$IMG" "$PROMPT")
    printf '%s\n\n' "$SUMMARY" >> "$OUT"
    printf '%s' "$SUMMARY" > "$PREV_SUMMARY_FILE"
    echo "read-pdf: [$PAGE_NUM/$TOTAL] done."
done

rm -rf "$WORK_DIR" "$PREV_SUMMARY_FILE"
echo "Done. Summary written to $OUT ($PAGE_NUM pages processed)."
