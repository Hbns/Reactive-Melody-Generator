#!/bin/bash

# Define the number of nodes to start
NUM_NODES=3

# Start each node in a separate terminal
for ((i=1; i<=$NUM_NODES; i++)); do
    konsole --new-tab --hold -e "iex --name node$i@home -S mix" &
done
# Give some time for iex to start in each tab
sleep 3

# Run the Supercollider command in each iex session
for ((i=1; i<=$NUM_NODES; i++)); do
    -e "Supercollider.start(ip: '192.168.178.25')" &
done