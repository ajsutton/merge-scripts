# Beku Local Testnet Setup

## Initial Setup

Download and compile besuy and teku by running the `./prep.sh` script. This only needs to be done once.  Afterwards you can update to more recent versions by running `git pull && ./gradlew installDist` in either the `besu` or `teku` directory.

## Start Besu

To start besu, run `./startBesu.sh`

## Start Teku

To start Teku, run `./startTeku.sh`

## Network Config

The network is configured to start Altair from genesis and activate the merge at epoch 1.  The execution layer begins as a Clique network and transitions to PoS at total difficulty 50. This means there is a reasonable period of time where the beacon chain has activated the merge fork but has yet to begin including execution payloads.
