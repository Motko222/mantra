#!/bin/bash

sudo systemctl stop mantrachaind

# Back up priv_validator_state.json if needed
cp ~/.mantrachaind/data/priv_validator_state.json  ~/.mantrachaind/priv_validator_state.json

cd $HOME
sudo rm -rf ~/.mantrachaind/data
sudo rm -rf ~/.mantrachaind/wasm

curl -o - -L https://config-t.noders.services/mantra/data.tar.lz4 | lz4 -d | tar -x -C ~/.mantrachaind
curl -o - -L https://config-t.noders.services/mantra/wasm.tar.lz4 | lz4 -d | tar -x -C ~/.mantrachaind

# Replace with the backed-up priv_validator_state.json
cp ~/.mantrachaind/priv_validator_state.json  ~/.mantrachaind/data/priv_validator_state.json

sudo systemctl restart mantrachaind
sudo journalctl -fu mantrachaind --no-hostname -o cat
