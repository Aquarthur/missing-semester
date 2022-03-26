# !/usr/bin/env bash

# Saves the current working directory to env var POLO_DIR
marco () {
  POLO_DIR=$(pwd)
}

# Changes directory back to POLO_DIR (if it is set)
polo () {
  if [[ -n $POLO_DIR ]]; then
    cd $POLO_DIR
  else
    echo "You haven't called marco yet!"
  fi
}
