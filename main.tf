resource "aws_vpc" "project" {
cidr_block = var.vpc_cidr
instance_tenancy = "default"
enable_dns_hostnames = "true"
enable_dns_support = "true"
tags = {
    Name = "project-vpc"
  }
}
resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_public_cidr[0]
    map_public_ip_on_launch = "true"
}
resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_public_cidr[1]
    map_public_ip_on_launch = "true"
}
resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_private_cidr[0]
}
resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_private_cidr[1]
}
resource "aws_subnet" "database-pubilc-subnet" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_database_cidr[0]
    map_public_ip_on_launch = "true"
    }
resource "aws_subnet" "database-private-subnet" {
    vpc_id = aws_vpc.project.id
    cidr_block = var.subset_database_cidr[1]
}
resource "aws_internet_gateway" "project-igw" {
    vpc_id = aws_vpc.project.id
}
resource "aws_route_table" "routing" {
    vpc_id = aws_vpc.project.id
    tags = {
    Name = "routing"
  } 
}
resource "aws_route" "route" {
  route_table_id            = aws_route_table.routing.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.project-igw.id}"
  depends_on                = [aws_route_table.routing]
}
resource "aws_route_table_association" "association-1" {
    subnet_id = var.subnet_public_id[0]
    route_table_id = aws_route_table.routing.id
}
resource "aws_route_table_association" "association-2" {
    subnet_id = var.subnet_public_id[1]
    route_table_id = aws_route_table.routing.id
}
resource "aws_route_table_association" "association-3" {
    subnet_id = var.subnet_public_id[2]
    route_table_id = aws_route_table.routing.id
}
/*
resource "aws_nat_gateway" "project-ngw" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.public-subnet-1.id
}
resource "aws_route_table" "routing-private" {
    vpc_id = aws_vpc.project.id
    tags = {
    Name = "routing-private"
  }  
}
resource "aws_route" "route-ngw" {
  route_table_id            = aws_route_table.routing-private.id
  gateway_id = "${aws_internet_gateway.project-igw.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on                = [aws_route_table.routing-private]
}
resource "aws_route_table_association" "association-4" {
    subnet_id = var.subnet_private_id[0]
    route_table_id = aws_route_table.routing-private.id
}
resource "aws_route_table_association" "association-5" {
    subnet_id = var.subnet_private_id[1]
    route_table_id = aws_route_table.routing-private.id
}
resource "aws_route_table_association" "association-6" {
    subnet_id = var.subnet_private_id[2]
    route_table_id = aws_route_table.routing-private.id
}
resource "aws_vpc_endpoint" "project-s3" {
  vpc_id       = aws_vpc.project.id
  service_name = "com.amazonaws.us-west-2.s3"
}
resource "aws_security_group" "project-security" {
  name        = "project-security"
  vpc_id      = aws_vpc.project.id

  ingress {
      description      = "TLS from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}
data "aws_ami" "Bastion" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values =["amzn2-ami-hvm-*-gp2"]
  }
}
resource  "aws_instance" "Bastion-ec2" {
ami = data.aws_ami.Bastion.id
instance_type = var.ec2_Bastion
subnet_id = aws_subnet.public-subnet-1.id
vpc_security_group_ids = ["aws_security_group.project-security.id"]
key_name = "Bastion"
depends_on = [
  aws_security_group.project-security
]
tags = {
    Name = "Bastion-ec2"
  }
}
data "aws_subnet_ids" "project-sub-vpc" {
  vpc_id = "${aws_vpc.project.id}"
   depends_on = [
    aws_vpc.project
  ]
}

data "aws_subnet" "project-subid" {
  depends_on = [
  data.aws_subnet_ids.project-sub-vpc
  ]
  for_each = data.aws_subnet_ids.project-sub-vpc.ids
  id = each.value
}
resource "aws_launch_template" "project-launch" {
  name   = "project-launch"
  image_id      = data.aws_ami.Bastion.id
  instance_type = var.ec2_Bastion
}

resource "aws_autoscaling_group" "autoscaling" {
  name = "autoscaling"
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.project-launch.id
    version = "$Latest"
  }
  vpc_zone_identifier = [ for i in data.aws_subnet.project-subid: i.id ]
   depends_on = [
    data.aws_subnet.project-subid
  ]
}

resource "aws_s3_bucket" "bucket-avi" {
  bucket = "my-test-bucket"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name        = "My bucket"
  }
}
resource "aws_sqs_queue" "project_queue" {
  name                      = "project-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  
  tags = {
    Environment = "testing"
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"
  runtime = "nodejs12.x"
  environment {
    variables = {
      foo = "bar"
    }
  }
}
resource "aws_iam_role" "iam_for_lambda_1" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_1" {
  filename      = "lambda_function.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"
  runtime = "nodejs12.x"
  
}

resource "aws_lambda_event_source_mapping" "lambda_sqs" {
  event_source_arn = aws_sqs_queue.project_queue.arn
  function_name    = aws_lambda_function.lambda.arn
}
resource "aws_lambda_event_source_mapping" "lambda_s3" {
  event_source_arn = aws_sqs_queue.project_queue.arn
  function_name    = aws_lambda_function.lambda.arn
}
*/
