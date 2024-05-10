#/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$folder/cfg

#init node and wallet
$BINARY init $MONIKER --chain-id=$CHAIN --home $DATA
{ echo $PWD; sleep 1; echo $PWD } | $BINARY keys add $KEY

# genesis
read -p "Server to fetch genesis and seeds from? "  seed; 
curl -s $seed/$CHAIN/genesis > $DATA/config/genesis.json

#seeds
sed -i 's|seeds =.*|seeds = "'$(curl -s $seed/$CHAIN/seeds)'"|g' $DATA/config/config.toml

#min gas
sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "$GAS_PRICE"/g' $DATA/config/app.toml
