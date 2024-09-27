#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg
source ~/.bash_profile
json=~/logs/report-$folder

node=$(mantrachaind config get client node | cut -d / -f 3 | sed 's/"//g')

status_json=$(curl -s $node/status | jq .result.sync_info)
pid=$(pgrep $BINARY)
version=$($BINARY version)
chain=$($BINARY status | jq -r .node_info.network)
foldersize1=$(du -hs $DATA | awk '{print $1}')
latestBlock=$(echo $status_json | jq -r .latest_block_height)
catchingUp=$(echo $status_json | jq -r .catching_up)
votingPower=$($BINARY status 2>&1 | jq -r .ValidatorInfo.VotingPower)
wallet=$(echo $PASS | $BINARY keys show $KEY -a)
valoper=$(echo $PASS | $BINARY keys show $KEY -a --bech val)
moniker=$($BINARY query staking validator $valoper -o json | jq -r .validator.description.moniker)
pubkey=$($BINARY tendermint show-validator --log_format json | jq -r .key)
delegators=$($BINARY query staking delegations-to $valoper -o json | jq '.delegation_responses | length')
jailed=$($BINARY query staking validator $valoper -o json | jq -r .jailed)
if [ -z $jailed ]; then jailed=false; fi
tokens=$($BINARY query staking validator $valoper -o json | jq -r .validator.tokens | awk '{print $1/1000000}')
balance=$($BINARY query bank balances $wallet -o json 2>/dev/null \
      | jq -r '.balances[] | select(.denom=="'$DENOM'")' | jq -r .amount)
active=$($BINARY query tendermint-validator-set | grep -c $pubkey)
threshold=$($BINARY query tendermint-validator-set -o json | jq -r .validators[].voting_power | tail -1)

if $catchingUp
 then 
  status="syncing"
  message="height=$latestBlock"
 else 
  if [ $active -eq 1 ]; then status=active; else status=inactive; fi
fi

if $jailed
 then
  status="error"
  message="jailed"
fi 

if [ -z $pid ];
then status="error";
 message="process not running";
fi

cat >$json << EOF
{ 
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
    "id":"$folder",
    "machine":"$MACHINE",
    "owner":"$OWNER",
    "grp":"validator" 
  },
  "fields": {
    "version":"$version",
    "chain":"$chain",
    "status":"$status",
    "message":"$message",
    "rpc":"$rpc",
    "folder1":"$foldersize1",
    "moniker":"$moniker",
    "key":"$KEY",
    "wallet":"$wallet",
    "valoper":"$valoper",
    "pubkey":"$pubkey",
    "catchingUp":"$catchingUp",
    "jailed":"$jailed",
    "active":$active,
    "local_height":$latest_block,
    "network_height":$network_height,
    "votingPower":$votingPower,
    "tokens":$tokens,
    "threshold":$threshold,
    "delegators":$delegators,
    "balance":$balance 
  }
}
EOF

cat $json
