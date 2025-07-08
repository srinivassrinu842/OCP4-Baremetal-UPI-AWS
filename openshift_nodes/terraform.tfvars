create_bootstrap               = true
create_masters                 = true
create_workers                 = false

bootstrap_user_data_file       = "ignitions/merge-bootstrap.ign"
resource_prefix                = "sreeni-baremetal-upi"
bootstrap_ami_id               = "ami-05483066c3caaccf5"
bootstrap_subnet_id            = "subnet-0dfca36da21a52e5a"

instance_security_group        = "sg-09bb80deab602727f"

master_ami_id                  = "ami-05483066c3caaccf5"
master_subnet_ids              = ["subnet-0ba6a91fdd02cfe57", "subnet-012636337cfd7c2dd", "subnet-0f080bf8608b924cc"]
master_user_data_file          = "ignitions/master.ign"

worker_ami_id                  = "ami-05483066c3caaccf5"
worker_subnet_ids              = ["subnet-0ba6a91fdd02cfe57", "subnet-012636337cfd7c2dd"]
worker_user_data_file          = "ignitions/worker.ign"

target_group_22623_arn         = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/sreeni-baremetal-upi-22623/ec26ac35da7c49dc"
target_group_443_arn           = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/sreeni-baremetal-upi-443/3ecbad0737d34d83"
target_group_6443_arn          = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/sreeni-baremetal-upi-6443/cad3a09566967fa4"
target_group_80_arn            = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/sreeni-baremetal-upi-80/82155ca73f62b33f"
