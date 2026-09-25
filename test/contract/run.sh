#!/usr/bin/env bash
# Engine-contract check (docs/ENGINE-CONTRACT.md v1) against a built binary on a machine with an
# NVIDIA GPU and driver. Runs a short simulation and asserts the stable line formats the Kraskus
# Universal Miner relies on. Exit code 0 = contract satisfied.
#
#   ./test/contract/run.sh [path/to/kawpowminer] [seconds]
set -uo pipefail
BIN="${1:-$(dirname "$0")/../../build/kawpowminer/kawpowminer}"; SECS="${2:-40}"
[ -x "$BIN" ] || { echo "no binary at $BIN"; exit 2; }
fail=0; pass=0
ok()  { pass=$((pass+1)); echo "PASS $1"; }
bad() { fail=$((fail+1)); echo "FAIL $1"; }
strip() { sed "s/\x1b\[[0-9;]*m//g"; }

v="$("$BIN" --version 2>&1 | strip | grep -E "^kawpowminer " | head -1)"
if echo "$v" | grep -qE "^kawpowminer [0-9]+\.[0-9]+\.[0-9]+\+commit\.[0-9a-f]{8}$"; then ok "version line: $v"; else bad "version line: '$v'"; fi

devs="$("$BIN" --list-devices 2>&1 | strip)"
if echo "$devs" | grep -qE "^ +Id +Pci Id +Type +Name +CUDA +SM +Total Memory"; then ok "--list-devices table header"; else bad "--list-devices header"; fi
if echo "$devs" | grep -qE "^ +0 +[0-9a-f]{2}:[0-9a-f]{2}\.[0-9] +Gpu +.+ +Yes +[0-9]+\.[0-9] +[0-9.]+ GB"; then ok "--list-devices row"; else bad "--list-devices row:
$devs"; fi

log="$(mktemp)"
timeout --signal=INT "$SECS" "$BIN" -U --cuda-devices 0 -Z 1000000 --display-interval 10 --api-bind 127.0.0.1:38077 > "$log" 2>&1 || true
strip < "$log" > "$log.txt"
if grep -qE "\[kraskus\] device [0-9]+ pci [0-9a-f]{8}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-9] uuid GPU-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} name .+ cc [0-9]+\.[0-9]+" "$log.txt"; then ok "identity line"; else bad "identity line"; fi
if grep -qE "^ ?m [0-9:]+ kawpowminer [0-9]+:[0-9]+ A[0-9]+(:R[0-9]+)?(:F[0-9]+)? [0-9.]+ [KMG]?h - cu0 [0-9.]+" "$log.txt"; then ok "speed line (A<accepted>[:R<rejected>][:F<failed>] <rate> <unit>h)"; else bad "speed line"; fi
if grep -qE "Job: [0-9a-f]{8}" "$log.txt"; then ok "job line"; else bad "job line"; fi
if grep -qE "Generated DAG \+ Light in [0-9,]+ ms" "$log.txt"; then ok "DAG line"; else bad "DAG line"; fi
if grep -qE "Pre-compiled period [0-9,]+ CUDA ProgPow kernel for arch [0-9]+\.[0-9]+" "$log.txt"; then ok "NVRTC kernel line"; else bad "NVRTC kernel line"; fi
if grep -qE "incorrect result" "$log.txt"; then bad "a solution failed CPU verification"; else ok "no incorrect results"; fi
# API: miner_getstat1 answers on the loopback port while mining
if command -v python3 >/dev/null; then
  timeout --signal=INT 30 "$BIN" -U --cuda-devices 0 -Z 1000000 --display-interval 10 --api-bind 127.0.0.1:38078 > /dev/null 2>&1 &
  p=$!; sleep 12
  resp="$(python3 - <<'PY'
import socket,json
s=socket.create_connection(("127.0.0.1",38078),timeout=5)
s.sendall(b'{"id":1,"jsonrpc":"2.0","method":"miner_getstat1"}\n')
print(s.recv(4096).decode(errors="replace").strip())
PY
)"
  kill -INT $p 2>/dev/null; wait $p 2>/dev/null
  if echo "$resp" | grep -q '"result"'; then ok "API miner_getstat1: ${resp:0:120}"; else bad "API miner_getstat1: '$resp'"; fi
fi
rm -f "$log" "$log.txt"
echo "contract: $pass passed, $fail failed"
[ "$fail" = 0 ]
