#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# Source .env file
. .env

COUNT=`curl -s "https://indexer.q.org/blocks?sort=-block&page%5Blimit%5D=101"|jq '[.data[]|select(.attributes.miner=="'$VALIDATOR'")]|length'`

re='^[0-9]+$'
if ! [[ "$COUNT" =~ $re ]] ; then
  echo q_mined_blocks 0 >/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
else
  echo q_mined_blocks $COUNT >/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
fi
echo $COUNT
mv /var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp /var/lib/node_exporter/textfile_collector/q-monitoring.prom
