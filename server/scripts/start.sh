#!/usr/bin/env bash

# go to parent directory
if ! cd "$(dirname "$0")/.."; then exit; fi

# timestamp
timestamp="$(date '+%Y%m%d %H:%M:%S')"
logfile="logs/nvim-asciidoc-preview-server.log"
line="--------------------------------------------------------"

# set absolute path for server command
cmd=$(realpath "server.js")

# check if a command exists
isCommand() {
  command -v "$1" &>/dev/null
}

logMessage() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$1]: $2" >>"$logfile"
}

# create log directory
mkdir -p logs

# Log only current session
echo "$line" >"$logfile"
logMessage "INFO" "Starting script..."
echo "$line" >>"$logfile"

# check if npm is installed
if ! isCommand npm && ! isCommand node; then
  logMessage "FAIL" "'npm' not found"
  exit 0
fi
logMessage "OKAY" "'npm' found"

# check if node is installed
if ! isCommand node; then
  logMessage "FAIL" "'node' not found"
  exit 0
fi
logMessage "OKAY" "'node' found"

# check if server command exists
if [[ ! -f "$cmd" ]]; then
  logMessage "FAIL" "'${cmd}' not found"
  exit 0
fi
logMessage "OKAY" "'${cmd}' found"

# Fallback, if no build/run command in Neovim plugin manager
npm install >/dev/null 2>&1

# log arguments
logMessage "INFO" "Arguments: ${*}"

# Start server
echo "$line" >>"$logfile"
logMessage "INFO" "Starting node server..."
echo "$line" >>"$logfile"
nohup node "$cmd" "$@" >>"$logfile" 2>&1 &
