#!/bin/bash

# Service Name (update this if you use service name other than 'sentinelhub', such as 'cosmovisor')
SERVICE_NAME=sentinelhub

SNAP_RPC1="https://rpc-sentinel-testnet.busurnode.com:443"
SNAP_RPC2="https://rpc-sentinel-testnet.busurnode.com:443"

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

# Stop the sentinel service
#echo "Stopping the sentinel service..."
#sudo service $SERVICE_NAME stop

# Copy the validator state JSON file
echo "Backing up validator state..."
cd $HOME
cp ~/.sentinelhub/data/priv_validator_state.json ~/.sentinelhub/priv_validator_state.json

# Reset Tendermint state
sentinelhub tendermint unsafe-reset-all --home $HOME/.sentinelhub --keep-addr-book

# Replace priv_validator_state from backup
echo "Recover validator state from backup..."
cp ~/.sentinelhub/priv_validator_state.json ~/.sentinelhub/data/priv_validator_state.json

# Start the sentinel service
echo "Starting the sentinel service..."
nohup $SERVICE_NAME start &
echo "Process complete."