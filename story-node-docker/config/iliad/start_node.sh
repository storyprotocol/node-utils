#!/bin/sh

echo "Initializing iliad beacon node"
/story-node/iliad/iliad init --network testnet --home /story-node/iliad --force


echo "Starting Story's iliad beacon node"
/story-node/iliad/iliad run --home="/story-node/iliad"
