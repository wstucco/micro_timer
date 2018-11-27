#! /bin/bash

BASEDIR="$(cd "$(dirname "$0")" && pwd)";

OUT_FILE="$BASEDIR/bench_results.csv";
BIN_DIR="$BASEDIR/bin"
TMP_DIR="$BASEDIR/tmp"

rm -rf "$BIN_DIR";
mkdir -p "$BIN_DIR";

rm -rf "$TMP_DIR";
mkdir -p "$TMP_DIR";

gcc -o "$BIN_DIR/sleep" "$BASEDIR/sleep.c"
elixirc --ignore-module-conflict -o "$BIN_DIR" "$BASEDIR/ex0.ex"
elixirc --ignore-module-conflict -o "$BIN_DIR" "$BASEDIR/ex1.ex"

for i in {1..5000}; do
  od -vAn -N2 -tu2 < /dev/urandom | tr -d ' ' | grep -v "^$" >> "$TMP_DIR/timeouts";
done;

"$BIN_DIR/sleep" "$TMP_DIR/timeouts" > "$TMP_DIR/c_bench.csv";
elixir -pa "$BIN_DIR" -e "MicroTimerBenchNoAdjust.run(\"$TMP_DIR/timeouts\")" > "$TMP_DIR/ex0_bench.csv";
elixir -pa "$BIN_DIR" -e "MicroTimerBenchAdjust.run(\"$TMP_DIR/timeouts\")" > "$TMP_DIR/ex1_bench.csv";

echo "timeout;C timeout;C jitter;C %;Ex0 timeout;Ex0 jitter;Ex0 %;Ex1 timeout;Ex1 jitter;Ex1 %;" > "$TMP_DIR/header.csv";
paste -d ';' "$TMP_DIR/timeouts" "$TMP_DIR/c_bench.csv" "$TMP_DIR/ex0_bench.csv" "$TMP_DIR/ex1_bench.csv" > "$TMP_DIR/results.csv";

cat "$TMP_DIR/header.csv" "$TMP_DIR/results.csv" > "$BASEDIR/bench_results.csv"
