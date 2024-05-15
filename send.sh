#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

[ -z $1 ] && read -p "From ? " from || from=$1

wallet=$(echo $PSWD | $BINARY keys show $from -a)
balance=$($BINARY query bank balances $wallet -o json 2>/dev/null \
      | jq -r '.balances[] | select(.denom=="'$DENOM'")' | jq -r .amount)

echo Balance $((balance))$DENOM

[ -z $2 ] && read -p "To ? " to || to=$2
[ -z $3 ] && read -p "Amount ? " amount || amount=$3

echo $PSWD | $BINARY tx bank send $from $to $amount$DENOM \
   --gas-prices $GAS_PRICE --gas-adjustment $GAS_ADJ --gas auto -y | tail -1
