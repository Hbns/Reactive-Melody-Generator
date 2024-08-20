!/bin/bash
# Commands to run in each terminal
commands=(
  "iex --name node1@0.0.0.0 -S mix"
  "iex --name node2@0.0.0.0 -S mix"
  "iex --name node3@0.0.0.0 -S mix"
  "iex --name node4@0.0.0.0 -S mix"
  "iex --name node5@0.0.0.0 -S mix"
  "iex --name node6@0.0.0.0 -S mix"
  "iex --name node7@0.0.0.0 -S mix"
  "iex --name node8@0.0.0.0 -S mix"
  "iex --name node9@0.0.0.0 -S mix"
  "iex --name node10@0.0.0.0 -S mix"
  "iex --name node11@0.0.0.0 -S mix"
  "iex --name node12@0.0.0.0 -S mix"
  "iex --name node13@0.0.0.0 -S mix"
  "iex --name node14@0.0.0.0 -S mix"
  "iex --name node15@0.0.0.0 -S mix"
  "iex --name node16@0.0.0.0 -S mix"
  "iex --name node17@0.0.0.0 -S mix"
  "iex --name node18@0.0.0.0 -S mix"
  "iex --name node19@0.0.0.0 -S mix"
  "iex --name node20@0.0.0.0 -S mix"
  
)
# Open a new terminal window for each command
for ((i=0; i<${#commands[@]}; i++))
do
  gnome-terminal --tab --title="Node $((i+1))" -- bash -c "${commands[i]}; exec bash"
done
