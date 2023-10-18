include {
  path = find_in_parent_folders()
}

inputs = {
  vpc_cidr = "10.1.0.0/16"
  subnets = {
    primaria   = "10.1.1.0/24",
    secundaria = "10.1.2.0/24",
  }
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}