#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_GETH="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/geth-data"
rm -rf "${DATADIR}"

$GETH init ../merge-testnets/merge-devnet-5/genesis.json  --datadir "$DATADIR"
$GETH --jwt-secret 0x60d0363caf91d2723e7afab88ec6d3634e79ea32e347a10bf63182ab3c072931 --datadir "$DATADIR" --port 30305 --http --http.api="engine,eth,web3,net,debug" --http.corsdomain "*" --networkid=1337762 console --bootnodes "enode://77927a49570f079b4b73c4fca0c50206c48d3a22ed175e715fbfaccc08f838813d527b4ba9929a99bc87d53b8e80a63b185a37d9c950d57c227004b8c4e8fec1@164.92.193.6:30303,enode://6167e29219f7a0d35847a784111e5da1d3d52c074711692fdde7f8077c48943fd875fd2f5cc8b4813e6f35e56071ae3d85beaf6b06d8666fdad019d0be3e70f7@64.227.128.126:30303,enode://74744416c7fbdf28cb0a2631d8590c10d31f1d09e944e7f54d9dbf5741d088d4e0360e7c897e0527aee0bc9408cfac0edbea8571cc0ca445bd599be537aad262@164.92.206.58:30303"
