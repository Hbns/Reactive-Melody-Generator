import yaml, json

# List of valid values for each field
VALID_TASKS = ["start", "stop", "restart", "deploy"]
VALID_REACTORS = ["p1"]
VALID_NODES = ["node2@0.0.0.0", "node3@0.0.0.0", "node4@0.0.0.0", "node5@0.0.0.0"]
VALID_CONNECTORS = ["f1", "f2", "f3", "f4", "t1", "t2"]
VALID_SINKS = ["s1"]

def parse_dsl(file_path):
    """
    Parse the YAML DSL configuration file.
    """
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

def validate_deployment(deployment):
    """
    Validate a single deployment configuration.
    """
    if deployment['task'] not in VALID_TASKS:
        raise ValueError(f"Invalid task: {deployment['task']}")
    if deployment['reactor'] not in VALID_REACTORS:
        raise ValueError(f"Invalid reactor: {deployment['reactor']}")
    if deployment['node'] not in VALID_NODES:
        raise ValueError(f"Invalid node: {deployment['node']}")
    if deployment['connector1'] not in VALID_CONNECTORS:
        raise ValueError(f"Invalid connector1: {deployment['connector1']}")
    if deployment['connector2'] not in VALID_CONNECTORS:
        raise ValueError(f"Invalid connector2: {deployment['connector2']}")
    if deployment['sinks'] not in VALID_SINKS:
        raise ValueError(f"Invalid sinks: {deployment['sinks']}")
    # print("Configuration has been validated")

def process_deployments(deployments):
    """
    Process a list of deployment configurations.
    """
    valid_deployments = []

    for deployment in deployments:
        try:
            validate_deployment(deployment)
        except ValueError as e:
            print(f"Error: {e}")
            print("Errors encountered, deployment aborted")
            return
        valid_deployments.append(deployment)  
        print(f"Deployment for {deployment['node']} validated successfully")

# Serialize to JSON and write to a file
        with open('deployment_info.json', 'w') as f:
            json.dump(valid_deployments, f)