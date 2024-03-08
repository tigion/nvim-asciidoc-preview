#!/usr/bin/env bash

# go to parent directory
if ! cd "$(dirname "$0")/.."; then exit; fi

# set absolute path for server command
cmd=$(realpath "server.js")

# check if a command exists
isCommand() {
  command -v "$1" &>/dev/null
}

# create log directory
mkdir -p logs

# Fallback, if no build/run command in Neovim plugin manager
if isCommand npm; then
  npm install
  # if [[ ! -d "node_modules" ]]; then
  #   # install server dependencies
  #   npm install
  # else
  #   # update server dependencies
  #   update_count=$(npm outdated -p | awk -F ':' '{if ($2 != $3) {print $3}}' | wc -l)
  #   if [[ $update_count -gt 0 ]]; then
  #     npm update
  #   fi
  # fi
fi

# start server
if isCommand node && [[ -f "$cmd" ]]; then
  #node "$cmd" > logs/server.log 2>&1 &
  nohup node "$cmd" >logs/server.log 2>&1 &
  #nohup node "$cmd" > /dev/null 2>&1 &
  #nohup node "$cmd" --open-browser > /dev/null 2>&1 &
fi
