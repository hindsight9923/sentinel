#!/bin/bash

# Script framework credit to Busurnode other contents authored by Misfits (The Expanse)
# Service Name 

SERVICE_NAME=cosmovisor

# RPC Endpoints for the network
SNAP_RPC1="https://rpc-sentinel.busurnode.com:443"
SNAP_RPC2="https://na-rpc-sentinel.busurnode.com:443"

# Fetch block data from RPC
echo "Fetching trusted block data from RPC..."
LATEST_HEIGHT=$(curl -s $SNAP_RPC1/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC1/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo "Update config with latest block from RPC..."
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC1,$SNAP_RPC2\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sentinelhub/config/config.toml

# Stop the cosmovisor service
echo "Stopping the cosmovisor service..."
# Find the PID of the process
pid=$(pgrep -f "$SERVICE_NAME")

# Check if the process is running
if [ -n "$pid" ]; then
    # Kill the process
    kill "$pid"
    echo "Process $SERVICE_NAME killed successfully."
else
    echo "Process $SERVICE_NAME not running."
fi

# Copy the validator state JSON file
echo "Backing up validator state..."
cd $HOME/sentinelhub
cp ~/.sentinelhub/data/priv_validator_state.json ~/.sentinelhub/priv_validator_state.json

# Reset Tendermint state
sentinelhub tendermint unsafe-reset-all --home $HOME/.sentinelhub --keep-addr-book

# Replace priv_validator_state from backup
echo "Recover validator state from backup..."
cp ~/.sentinelhub/priv_validator_state.json ~/.sentinelhub/data/priv_validator_state.json

# Start the cosmovisor service
echo "Starting the cosmovisor service..."
nohup $SERVICE_NAME run start &
echo "Process complete."
echo "****To see the status of the process type cat nohup****"