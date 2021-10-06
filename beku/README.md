# Beku Local Testnet Setup

## Initial Setup

The first time either start script is run, it will download and compile besu and teku. If you already have these elsewhere you can set either the `BESU` or `TEKU` env var to the actual executable to use for one or both of them (e.g. `BESU=<besu-source-dir>/build/install/besu/bin/besu`).

## Start Besu

To start besu, run `./startBesu.sh`

## Start Teku

To start Teku, run `./startTeku.sh`

## Network Config

The network is configured to start Altair from genesis and activate the merge at epoch 1.  The execution layer begins as a Clique network and transitions to PoS at total difficulty 50. This means there is a reasonable period of time where the beacon chain has activated the merge fork but has yet to begin including execution payloads.
