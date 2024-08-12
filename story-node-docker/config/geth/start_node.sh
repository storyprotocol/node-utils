#!/bin/sh

echo "Initializing geth execution node"
/story-node/geth/geth init --datadir="/story-node/geth/data" /story-node/geth/config/genesis.json

echo "Starting geth binary for Story Testnet"
/story-node/geth/geth --config "/story-node/geth/config/geth.toml"
