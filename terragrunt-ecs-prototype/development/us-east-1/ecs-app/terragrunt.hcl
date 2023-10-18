include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

dependency "cluster" {
  config_path = "../ecs-cluster"
}

#dependencies {
#  paths = ["../ecs-cluster"]
#}

#locals {
#  cluster_id      = run_cmd("terragrunt", "output", "cluster_id", "--terragrunt-working-dir", "../ecs-cluster")
#  subnets         = jsondecode(run_cmd("terragrunt", "output", "-json", "subnet_id", "--terragrunt-working-dir", "../network"))
#  security_groups = trimspace(run_cmd("terragrunt", "output", "security_group_id", "--terragrunt-working-dir", "../network"))
#}

inputs = {
  name            = "apache"
  cluster_id      = dependency.cluster.outputs.cluster_id
  desired_count   = 1
  subnets         = [dependency.network.outputs.subnet_id.primaria]
  security_groups = [dependency.network.outputs.security_group_id]
  resources = {
    cpu    = 256
    memory = 512
  }

  container_definitions = <<EOF
    [
      {
        "name": "fargate-app", 
        "image": "public.ecr.aws/docker/library/httpd:latest", 
        "portMappings": [
          {
            "containerPort": 80, 
            "hostPort": 80, 
            "protocol": "tcp"
          }
        ], 
        "essential": true, 
        "entryPoint": [
          "sh",
          "-c"
        ], 
        "command": [
          "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ]
      }
    ]
    EOF
}