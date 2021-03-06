#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_BESU="true"
cd "${SCRIPTDIR}"
source ../prep.sh

rm -rf /tmp/besu
$BESU --config-file besu-config.toml
