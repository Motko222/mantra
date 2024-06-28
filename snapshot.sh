#!/bin/bash

sudo systemctl stop mantrachaind

# Back up priv_validator_state.json if needed
cp ~/.mantrachain/data/priv_validator_state.json  ~/.mantrachain/priv_validator_state.json

cd $HOME
sudo rm -rf ~/.mantrachain/data
sudo rm -rf ~/.mantrachain/wasm

curl -o - -L https://config-t.noders.services/mantra/data.tar.lz4 | lz4 -d | tar -x -C ~/.mantrachain
curl -o - -L https://config-t.noders.services/mantra/wasm.tar.lz4 | lz4 -d | tar -x -C ~/.mantrachain

# Replace with the backed-up priv_validator_state.json
cp ~/.mantrachain/priv_validator_state.json  ~/.mantrachain/data/priv_validator_state.json

sudo systemctl restart mantrachaind
sudo journalctl -fu mantrachaind --no-hostname -o cat
