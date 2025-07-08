locals {
  bootstrap_user_data = var.bootstrap_user_data_file != "" ? base64encode(file(var.bootstrap_user_data_file)) : ""
  master_user_data    = var.master_user_data_file    != "" ? base64encode(file(var.master_user_data_file))    : ""
  worker_user_data    = var.worker_user_data_file    != "" ? base64encode(file(var.worker_user_data_file))    : ""
}

resource "aws_instance" "bootstrap" {
  count                  = var.create_bootstrap ? 1 : 0
  ami                    = var.bootstrap_ami_id
  instance_type          = var.bootstrap_instance_type
  subnet_id              = var.bootstrap_subnet_id
  vpc_security_group_ids = [var.instance_security_group]
  user_data_base64       = local.bootstrap_user_data

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.resource_prefix}-Bootstrap"
  }
}

resource "aws_instance" "master" {
  count                  = var.create_masters ? 3 : 0
  ami                    = var.master_ami_id
  instance_type          = var.master_instance_type
  subnet_id              = var.master_subnet_ids[count.index]
  vpc_security_group_ids = [var.instance_security_group]
  user_data_base64       = local.master_user_data

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.resource_prefix}-master-${count.index + 1}"
  }
}

resource "aws_instance" "worker" {
  count                  = var.create_workers ? 2 : 0
  ami                    = var.worker_ami_id
  instance_type          = var.worker_instance_type
  subnet_id              = var.worker_subnet_ids[count.index]
  vpc_security_group_ids = [var.instance_security_group]
  user_data_base64       = local.worker_user_data

  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.resource_prefix}-worker-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "bootstrap_6443" {
  count            = var.create_bootstrap && length(aws_instance.bootstrap) > 0 ? 1 : 0
  target_group_arn = var.target_group_6443_arn
  target_id        = aws_instance.bootstrap[0].private_ip
  port             = 6443
  depends_on       = [aws_instance.bootstrap]
}

resource "aws_lb_target_group_attachment" "bootstrap_22623" {
  count            = var.create_bootstrap && length(aws_instance.bootstrap) > 0 ? 1 : 0
  target_group_arn = var.target_group_22623_arn
  target_id        = aws_instance.bootstrap[0].private_ip
  port             = 22623
  depends_on       = [aws_instance.bootstrap]
}

resource "aws_lb_target_group_attachment" "bootstrap_80" {
  count            = var.create_masters && var.create_workers && length(aws_instance.bootstrap) > 0 ? 1 : 0
  target_group_arn = var.target_group_80_arn
  target_id        = aws_instance.bootstrap[0].private_ip
  port             = 80
  depends_on       = [aws_instance.bootstrap, aws_instance.master, aws_instance.worker]
}

resource "aws_lb_target_group_attachment" "bootstrap_443" {
  count            = var.create_masters && var.create_workers && length(aws_instance.bootstrap) > 0 ? 1 : 0
  target_group_arn = var.target_group_443_arn
  target_id        = aws_instance.bootstrap[0].private_ip
  port             = 443
  depends_on       = [aws_instance.bootstrap, aws_instance.master, aws_instance.worker]
}

resource "aws_lb_target_group_attachment" "master_6443" {
  count            = var.create_masters ? length(aws_instance.master) : 0
  target_group_arn = var.target_group_6443_arn
  target_id        = aws_instance.master[count.index].private_ip
  port             = 6443
  depends_on       = [aws_instance.master]
}

resource "aws_lb_target_group_attachment" "master_22623" {
  count            = var.create_masters ? length(aws_instance.master) : 0
  target_group_arn = var.target_group_22623_arn
  target_id        = aws_instance.master[count.index].private_ip
  port             = 22623
  depends_on       = [aws_instance.master]
}

resource "aws_lb_target_group_attachment" "master_80" {
  count            = var.create_masters ? length(aws_instance.master) : 0
  target_group_arn = var.target_group_80_arn
  target_id        = aws_instance.master[count.index].private_ip
  port             = 80
  depends_on       = [aws_instance.master]
}

resource "aws_lb_target_group_attachment" "master_443" {
  count            = var.create_masters ? length(aws_instance.master) : 0
  target_group_arn = var.target_group_443_arn
  target_id        = aws_instance.master[count.index].private_ip
  port             = 443
  depends_on       = [aws_instance.master]
} 
