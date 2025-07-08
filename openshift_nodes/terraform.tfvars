create_bootstrap               = true                                       # initial enable to create the bastion host and then disable once cluster is built
create_masters                 = false                                      # enable only when you see "Waiting up to 20m0s for the Kubernetes API" in the bootstrap node
create_workers                 = false                                      # enable only when you want to build the worker nodes

bootstrap_user_data_file       = "ignitions/merge-bootstrap.ign"
resource_prefix                = "<Your-Resource-Prefix>"
bootstrap_ami_id               = "ami-05483066c3caaccf5"
bootstrap_subnet_id            = "<Public-Subnet1-ID-Created-During-Infra-Build>"

instance_security_group        = "<Security-Group-ID-Created-During-Infra-Build>"

master_ami_id                  = "ami-05483066c3caaccf5"
master_subnet_ids              = ["subnet-XXXXXXXX", "subnet-XXXXXXXXXX", "subnet-XXXXXXXX"]
master_user_data_file          = "ignitions/master.ign"

worker_ami_id                  = "ami-05483066c3caaccf5"
worker_subnet_ids              = ["subnet-XXXXXXXX", "subnet-XXXXXXXXXX"]
worker_user_data_file          = "ignitions/worker.ign"

# Below details should be get post the infra build
target_group_22623_arn         = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
target_group_443_arn           = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
target_group_6443_arn          = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
target_group_80_arn            = "arn:aws:elasticloadbalancing:us-east-1:036990103311:targetgroup/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
