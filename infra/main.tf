# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.resource_prefix}-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_prefix}-InternetGateway"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.resource_prefix}-PublicSubnet${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"], count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.resource_prefix}-PrivateSubnet${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_prefix}-PublicRouteTable"
  }
}

# Public Route
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public Subnet Associations
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway EIPs
resource "aws_eip" "nat" {
  count = 3
  #vpc   = true
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = 3
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_prefix}-PrivateRouteTable${count.index + 1}"
  }
}

# Private Routes
resource "aws_route" "private_nat" {
  count                  = 3
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Private Subnet Associations
resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  acl           = "public-read"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.main.arn}/*"]
      }
    ]
  })
}

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [for rt in aws_route_table.private : rt.id]
}

# Route53 Private Hosted Zone
resource "aws_route53_zone" "private" {
  name = var.private_domain_name
  vpc {
    vpc_id = aws_vpc.main.id
  }
  comment = "Private hosted zone for ${var.private_domain_name}"
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.resource_prefix}-NLB"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private[*].id
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "${var.resource_prefix}-NLB"
  }
}

# Target Groups
resource "aws_lb_target_group" "tg_6443" {
  name        = "${var.resource_prefix}-6443"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "tg_22623" {
  name        = "${var.resource_prefix}-22623"
  port        = 22623
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "tg_80" {
  name        = "${var.resource_prefix}-80"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    protocol = "TCP"
  }
}

resource "aws_lb_target_group" "tg_443" {
  name        = "${var.resource_prefix}-443"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    protocol = "TCP"
  }
}

# Listeners
resource "aws_lb_listener" "listener_6443" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 6443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_6443.arn
  }
}

resource "aws_lb_listener" "listener_22623" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 22623
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_22623.arn
  }
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_80.arn
  }
}

resource "aws_lb_listener" "listener_443" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_443.arn
  }
}

# Security Group
resource "aws_security_group" "instance" {
  name        = "${var.resource_prefix}-InstanceSecurityGroup"
  description = "Enable SSH access and application ports"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-InstanceSecurityGroup"
  }
}

# Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = var.ec2_instance_ami
  instance_type          = "t3.medium"
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.instance.id]

  root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.resource_prefix}-Bastion"
  }
}

# Route53 DNS Records
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api.${var.ocp4_cluster_name}.${var.private_domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_int" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api-int.${var.ocp4_cluster_name}.${var.private_domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apps" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "*.apps.${var.ocp4_cluster_name}.${var.private_domain_name}"
  type    = "A"
  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = false
  }
} 
