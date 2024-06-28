import argparse
from translate import parse_dsl, process_deployments

# Define the argument parser
parser = argparse.ArgumentParser(description='Process cluster deployments')

# Add an argument to the parser for the configuration file path
parser.add_argument('config_file', type=str, help='Path to the deployment configuration file')

# Parse the arguments from the command line
args = parser.parse_args()

# Parse the DSL configuration file to get the deployments
config = parse_dsl(args.config_file)

# Process the deployments
process_deployments(config['deployments'])
