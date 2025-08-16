# Capture stdout from Python (unbuffered, just in case)
out="$(python -u myscript.py 2>&1)"
status=$?

echo "[exit ] $status"
echo "[out  ] $out"
