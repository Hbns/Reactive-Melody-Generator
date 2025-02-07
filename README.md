# Reactive Melody Generator

Reactive Melody Generator, Reacts on input and send osc messages to SuperColider.
![rmg](https://github.com/hbns/Reactive-Melody-Generator/blob/main/loophaai.png?raw=true)

## Make cluster environment

Make a cluster by running 'StartNodes.sh 1 5' (first node 1, last node 5) in terminal.
Select masternode eg: node1. run 'Code.eval_file("connect_nodes.exs")' to connect masternode to all nodes.

--Cluster is ready

## Read .Yaml file to load configuration into cluster.
In folder pyDsl run 'python3 deploy.py config.yaml'
This will make a json file in same folder, containing yaml deployment information.
Run 'Distribution.read_and_handle_deployment_info' in Elixir, It will read the jason file and send configuration to the nodes.

## sc needs to be running in order to hear the sound...

open supercollider and boot server (ctrl-b), open synthdef and load it (ctrl-enter)



