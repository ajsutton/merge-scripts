#!/bin/bash
set -euo pipefail
echo -n "      Teku1: "; curl -s http://localhost:5051/eth/v1/beacon/blocks/head/root  | jq -r .data.root && echo -n "      Teku2: "; curl -s http://localhost:5052/eth/v1/beacon/blocks/head/root  | jq -r .data.root && echo -n "Lighthouse1: "; curl -s http://localhost:5053/eth/v1/beacon/blocks/head/root  | jq -r .data.root && echo -n "Lighthouse1: "; curl -s http://localhost:5054/eth/v1/beacon/blocks/head/root  | jq -r .data.root
