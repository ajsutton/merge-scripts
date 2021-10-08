# Multinode Local Testnet Setup

## Initial Setup

The first time either start script is run, it will download and compile an awful lot of stuff. Go get a coffee.

## Start

Start the network by running `./start.sh` in this directory.  It will generate a consensus layer genesis and startup the clients.

## Results

Testnet started with validators evenly shared between the four nodes (Geth+Teku, Besu+Teku, Geth+Lighthouse, Besu+Lighthouse). 
Started from phase0 genesis, to Altair at epoch 1 and merge at epoch 2. TTD set to 300.

All nodes stayed in sync through the process and were successfully able to attest and produce blocks with the chain finalizing post-merge.

There were a few issues identified during the testing:

 * Teku & Lighthouse didn't allow subscriptions to the merge gossip topics due to an issue handling two future forks being scheduled. The [Lighthouse PR](https://github.com/sigp/lighthouse/pull/2688) is yet to merge.
 * Besu had disabled the NEW_BLOCK_HASH and NEW_BLOCK eth66 messages so was unable to follow the pre-merge chain. [PR to fix this](https://github.com/hyperledger/besu/pull/2866) is yet to be merged.
 * Unresolved so far, there appears to be an issue with execution payload creation by Besu (I think) when a transaction is included.
   The resulting block was rejected by all nodes and the transaction included in a later block successfully without creating any chain splits/forks. 