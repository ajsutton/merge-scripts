#!/bin/bash
set -uo pipefail
echo -n "      Teku1: "; curl -s http://localhost:5051/eth/v1/beacon/blocks/head/root  | jq -r .data.root || echo
echo -n "      Teku2: "; curl -s http://localhost:5052/eth/v1/beacon/blocks/head/root  | jq -r .data.root || echo
echo -n "Lighthouse1: "; curl -s http://localhost:5053/eth/v1/beacon/blocks/head/root  | jq -r .data.root || echo
echo -n "Lighthouse1: "; curl -s http://localhost:5054/eth/v1/beacon/blocks/head/root  | jq -r .data.root || echo

echo
echo -n "      Geth1: "
curl -s -H 'Content-Type: application/json' --fail --data "{\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[\"latest\", false]}"   http://localhost:8545 | jq -c '[.result.number, .result.hash, .result.totalDifficulty]' || echo
echo -n "      Besu1: "
curl -s -H 'Content-Type: application/json' --fail --data "{\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[\"latest\", false]}"   http://localhost:8546 | jq -c '[.result.number, .result.hash, .result.totalDifficulty]' || echo
echo -n "      Geth2: "
curl -s -H 'Content-Type: application/json' --fail --data "{\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[\"latest\", false]}"   http://localhost:8547 | jq -c '[.result.number, .result.hash, .result.totalDifficulty]' || echo
echo -n "      Besu2: "
curl -s -H 'Content-Type: application/json' --fail --data "{\"id\":2,\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[\"latest\", false]}"   http://localhost:8548 | jq -c '[.result.number, .result.hash, .result.totalDifficulty]' || echo
