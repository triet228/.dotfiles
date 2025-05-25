
#!/bin/bash

INPUT="$1"
DELAY=0.5  # seconds to wait per slide
OUTDIR=$(mktemp -d)
OUTPDF="presentation.pdf"
MAX_SLIDES=100  # safety cap

# Launch sent
sent "$INPUT" &
PID=$!
sleep 5  # wait for window

# Focus window
xdotool search --sync --onlyvisible --class sent windowactivate

# Capture loop with hash comparison
SLIDE=1
PREV_HASH=""
while true; do
    FILE="$OUTDIR/slide_$SLIDE.png"
    maim "$FILE"
    CUR_HASH=$(sha256sum "$FILE" | cut -d ' ' -f1)

    if [[ "$CUR_HASH" == "$PREV_HASH" ]]; then
        rm "$FILE"  # clean up duplicate
        break
    fi

    PREV_HASH="$CUR_HASH"
    xdotool key space
    sleep "$DELAY"
    ((SLIDE++))
done


# Force quit
xdotool key Escape
sleep 0.5
kill $PID 2>/dev/null

# Convert to PDF
magick "$OUTDIR"/slide_*.png "$OUTPDF"
echo "PDF saved as $OUTPDF"


