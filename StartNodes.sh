#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <first_node> <last_node>"
  exit 1
fi

# Assign arguments to variables
first_node=$1
last_node=$2

# Generate commands based on the node range
for ((i=first_node; i<=last_node; i++))
do
  commands+=("iex --name node${i}@0.0.0.0 -S mix")
done

# Open a new terminal window for each command
for ((i=0; i<${#commands[@]}; i++))
do
  gnome-terminal --tab --title="Node $((i+first_node))" -- bash -c "${commands[i]}; exec bash"
done

