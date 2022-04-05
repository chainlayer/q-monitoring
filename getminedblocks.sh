#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# Source .env file
. .env

# Get current blocknumber and amount of signers
TMP=`curl -s -H "Content-type: Application/Json" -X POST --data '{"jsonrpc":"2.0","method":"clique_getSnapshot","params":["latest"],"id":1}' $RPC_URL|jq -r '"\(.result.number) \(.result.signers|length)"'`
LASTDEC=`echo $TMP|awk -F\  '{print $1}'`
NUMVALIDATORS=`echo $TMP|awk -F\  '{print $2}'`
START=$(($LASTDEC - 100))

INTURN=0
OUTTURN=0
SIGNED=0

for (( c=$START; c<=$LASTDEC; c++ ))
do
	BLOCKHEX=0x`echo "obase=16; $c" | bc`
	SIGNER=`curl -s -H "Content-type: Application/Json" -X POST --data '{"jsonrpc":"2.0","method":"clique_getSnapshot","params":["'$BLOCKHEX'"],"id":1}' $RPC_URL|jq -r '.result.recents."'$c'"'`
	DIFF=`curl -s -H "Content-type: Application/Json" -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["'$BLOCKHEX'", false],"id":1}' $RPC_URL|jq -r '"\(.result.difficulty)"'`
	if [ $DIFF == "0x2" ] 
	then
		INTURN=$(($INTURN+1))
	fi
	if [ $DIFF == "0x1" ] 
	then
		OUTTURN=$(($OUTTURN+1))
	fi
	if [ "$SIGNER" == "$VALIDATOR" ]
	then
		SIGNED=$(($SIGNED+1))
	fi
done

EXPECTED=`echo "101 / $NUMVALIDATORS"|bc`
DELTA=$(($SIGNED - $EXPECTED))
>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# How many blocks the validator mined over the past 101 blocks" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_mined_blocks $SIGNED >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# How many blocks the validator should have reasonably mined over the past 101 blocks" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_expected_blocks $EXPECTED >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# How many more or less blocks the validator mined compared to the expectations" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_delta_blocks $DELTA >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# How many blocks were mined in-turn" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_mined_inturn $INTURN >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# How many blocks were mined out-of-turn" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_mined_outturn $OUTTURN >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo "# Number of active validators in the last block" >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
echo q_active_validators $NUMVALIDATORS >>/var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp
mv /var/lib/node_exporter/textfile_collector/q-monitoring.prom.tmp /var/lib/node_exporter/textfile_collector/q-monitoring.prom
