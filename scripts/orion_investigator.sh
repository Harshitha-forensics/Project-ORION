
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# ORION public investigation script
# Educational demonstration only.
# Review all evidence manually before drawing conclusions.

CASE="${1:-}"
SUBJECT="${2:-}"

EXAMINER="${ORION_EXAMINER:-Public Demo Examiner}"
LOG="${ORION_ACCESS_LOG:-/var/log/nginx/access.log}"
DOWNLOAD_DIR="${ORION_DOWNLOAD_DIR:-$HOME/.local/share/torbrowser/tbb/x86_64/tor-browser/Browser/Downloads}"
WEBROOT="${ORION_WEBROOT:-$HOME/ORION-PUBLIC-OUTPUT}"
EVIDENCE_DIR="${ORION_EVIDENCE_DIR:-$HOME/ORION-CASE-EVIDENCE}"

if [[ ! "$CASE" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "Usage: $0 CASE-ID SUBJECT-ID"
    echo "Example: $0 ORION-001 VISITOR-01"
    exit 1
fi

if [[ -z "$SUBJECT" || "$SUBJECT" == *$'\n'* ]]; then
    echo "Please provide a subject label without newline characters."
    exit 1
fi

BASELINE="$HOME/${CASE}_baseline.txt"

if [[ ! -r "$BASELINE" ]]; then
    echo "ERROR: Baseline not found: $BASELINE"
    echo "Create a baseline before the demonstration begins."
    exit 1
fi

if [[ ! -r "$LOG" ]]; then
    echo "ERROR: Cannot read access log: $LOG"
    echo "Check the log path and permissions."
    exit 1
fi

START_LINE="$(head -n 1 "$BASELINE" | tr -d '[:space:]')"

if [[ ! "$START_LINE" =~ ^[0-9]+$ ]]; then
    echo "ERROR: Baseline must contain a numeric log line count."
    exit 1
fi

mkdir -p "$WEBROOT" "$EVIDENCE_DIR"
chmod 700 "$EVIDENCE_DIR"

CASELOG="$(mktemp)"
trap 'rm -f "$CASELOG"' EXIT

# Keep log entries appended after the baseline line count.
if ! sudo awk -v n="$START_LINE" 'NR > n' "$LOG" > "$CASELOG"; then
    echo "ERROR: Could not extract activity from the server log."
    exit 1
fi

SEARCH_LINE="$(grep -m 1 'GET /search\.html?q=' "$CASELOG" || true)"
DOWNLOAD_LINE="$(grep -m 1 'GET /orion-downloads/' "$CASELOG" || true)"

QUERY="Not recovered"
SEARCH_TIME="Not recorded"
RECORD="Not recovered"
DOWNLOAD="Not recovered"
DOWNLOAD_TIME="Not recorded"
LOCAL_STATUS="Not applicable"

if [[ -n "$SEARCH_LINE" ]]; then
    RAW_QUERY="$(printf '%s\n' "$SEARCH_LINE" |
        sed -n 's/.*GET \/search\.html?q=\([^& ]*\).*/\1/p')"

    if [[ -n "$RAW_QUERY" ]]; then
        QUERY="$(python3 -c \
            'import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.argv[1]))' \
            "$RAW_QUERY")"
    fi

    SEARCH_TIME="$(printf '%s\n' "$SEARCH_LINE" |
        awk '{print $4}' | tr -d '[')"
fi

if [[ "$QUERY" != "Not recovered" ]]; then
    RECORD="$QUERY Research Record"
fi

if [[ -n "$DOWNLOAD_LINE" ]]; then
    RAW_DOWNLOAD="$(printf '%s\n' "$DOWNLOAD_LINE" |
        sed -n 's/.*GET \/orion-downloads\/\([^? ]*\).*/\1/p')"

    if [[ -n "$RAW_DOWNLOAD" ]]; then
        DOWNLOAD="$(python3 -c \
            'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' \
            "$RAW_DOWNLOAD")"

        # Only permit a simple filename, not a path.
        if [[ "$DOWNLOAD" == */* || "$DOWNLOAD" == *$'\n'* || "$DOWNLOAD" == "." || "$DOWNLOAD" == ".." ]]; then
            DOWNLOAD="Invalid filename in log"
            LOCAL_STATUS="Not checked"
        elif [[ -f "$DOWNLOAD_DIR/$DOWNLOAD" ]]; then
            LOCAL_STATUS="Present in checked folder"
        else
            LOCAL_STATUS="Not found in checked folder"
        fi
    fi

    DOWNLOAD_TIME="$(printf '%s\n' "$DOWNLOAD_LINE" |
        awk '{print $4}' | tr -d '[')"
fi

if [[ -s "$CASELOG" ]]; then
    SURVIVING="ORION server log entries preserved"
else
    SURVIVING="No new log entries in selected range"
fi

EVIDENCE_FILE="$EVIDENCE_DIR/${CASE}_ORION_server_log.txt"
cp "$CASELOG" "$EVIDENCE_FILE"
chmod 600 "$EVIDENCE_FILE"

HASH="$(sha256sum "$EVIDENCE_FILE" | awk '{print $1}')"

# Python safely encodes JSON and escapes values inserted into HTML.
export CASE SUBJECT EXAMINER QUERY SEARCH_TIME RECORD
export DOWNLOAD DOWNLOAD_TIME LOCAL_STATUS SURVIVING HASH
export WEBROOT EVIDENCE_FILE

python3 <<'PY'
import html
import json
import os
from pathlib import Path

keys = [
    "CASE", "SUBJECT", "EXAMINER", "QUERY", "SEARCH_TIME",
    "RECORD", "DOWNLOAD", "DOWNLOAD_TIME", "LOCAL_STATUS",
    "SURVIVING", "HASH"
]
data = {key.lower(): os.environ[key] for key in keys}

webroot = Path(os.environ["WEBROOT"])
webroot.mkdir(parents=True, exist_ok=True)

(webroot / f"{data['case']}.json").write_text(
    json.dumps(data, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8"
)

def esc(value):
    return html.escape(str(value), quote=True)

rows = [
    ("Case", data["case"]),
    ("Subject label", data["subject"]),
    ("Search query", data["query"]),
    ("Search time in server log", data["search_time"]),
    ("Record inferred from query", data["record"]),
    ("Download request filename", data["download"]),
    ("Download request time", data["download_time"]),
    ("Local file check", data["local_status"]),
    ("Surviving evidence", data["surviving"]),
    ("Evidence SHA-256", data["hash"]),
    ("Examiner", data["examiner"]),
]

rows_html = "\n".join(
    f"<tr><th>{esc(label)}</th><td>{esc(value)}</td></tr>"
    for label, value in rows
)

page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ORION Investigation Result</title>
<style>
body {{ font:16px system-ui,sans-serif; margin:0; padding:24px;
       background:#0b1220; color:#e5e7eb; }}
main {{ max-width:900px; margin:auto; }}
h1 {{ color:#67e8f9; }}
table {{ width:100%; border-collapse:collapse; overflow-wrap:anywhere; }}
th,td {{ text-align:left; padding:14px; border-bottom:1px solid #334155; }}
th {{ width:34%; color:#67e8f9; }}
.note {{ margin-top:24px; color:#cbd5e1; line-height:1.6; }}
</style>
</head>
<body><main>
<h1>ORION // Investigation Result</h1>
<p>Educational digital-forensics demonstration</p>
<table>{rows_html}</table>
<p class="note">
Interpretation note: server logs show recorded HTTP requests, not the
real-world identity of a visitor. A file missing from the checked folder
is not proof of deletion. The inferred record is based on the search query;
the script does not establish that the visitor opened that record.
The SHA-256 value identifies the preserved log copy and does not by itself
prove that the log is complete or authentic.
</p>
</main></body></html>
"""

(webroot / "index.html").write_text(page, encoding="utf-8")
PY

echo
echo "ORION investigation report created."
echo "Case:          $CASE"
echo "Evidence copy: $EVIDENCE_FILE"
echo "SHA-256:       $HASH"
echo "Output folder: $WEBROOT"
echo
echo "Review the log and report before drawing conclusions."
