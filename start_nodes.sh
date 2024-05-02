#!/bin/bash

# Default number of nodes
NUM_NODES=3

# Check if a command line argument is provided for the number of nodes
if [ $# -gt 0 ]; then
    NUM_NODES=$1
fi

# Start the first node in a new terminal window
konsole --new-tab --hold -e "iex --name node1@home -S mix" &

# Start additional nodes in new tabs within the same window
for ((i=2; i<=$NUM_NODES; i++)); do
    konsole --new-tab --hold --title "Node $i" -e "iex --name node$i@home -S mix" &
done



# Give some time for iex to start in each tab
#sleep 3

# Run the Supercollider command in each iex session
#for ((i=1; i<=$NUM_NODES; i++)); do
#    -e "Supercollider.start(ip: '192.168.178.25')" &
#done