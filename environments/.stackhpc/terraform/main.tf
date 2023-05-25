variable "environment_root" {
    type = string
    description = "Path to environment root, automatically set by activate script"
}

variable "cluster_name" {
    type = string
    description = "Name for cluster, used as prefix for resources - set by environment var in CI"
}

variable "create_nodes" {
    description = "Whether to create nodes (servers) or just ports and other infra"
    type = bool # can't use bool as want to pass from command-line
    default = true
}

variable "cluster_image" {
    description = "single image for all cluster nodes - a convenience for CI"
    type = string
    default = "openhpc-230525-1029-0e6fddd8" # https://github.com/stackhpc/ansible-slurm-appliance/pull/252
    # default = "Rocky-8-GenericCloud-Base-8.7-20221130.0.x86_64.qcow2"
    # default = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2"
}

module "cluster" {
    source = "../../skeleton/{{cookiecutter.environment}}/terraform/"

    cluster_name = var.cluster_name
    cluster_net = "demo-net"
    cluster_subnet = "demo-subnet"
    vnic_type = "normal"
    key_pair = "slurm-app-ci"
    control_node = {
        flavor: "m1.small"
        image: var.cluster_image
    }
    login_nodes = {
        login-0: {
            flavor: "m1.small"
            image: var.cluster_image
        }
    }
    compute_types = {
        small: {
            flavor: "m1.small"
            image: var.cluster_image
        }
        extra: {
            flavor: "m1.medium"
            image: var.cluster_image
        }
    }
    compute_nodes = {
        compute-0: "small"
        compute-1: "small"
    }
    create_nodes = var.create_nodes
    
    environment_root = var.environment_root
    # Can reduce volume size a lot for short-lived CI clusters:
    state_volume_size = 10
    home_volume_size = 5
}
