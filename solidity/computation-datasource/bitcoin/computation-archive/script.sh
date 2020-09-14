#!/bin/bash

curl --silent https://blockstream.info/api/address/$ARG0 \
  | jq '.chain_stats.funded_txo_sum - .chain_stats.spent_txo_sum'
