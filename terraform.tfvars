vpc_cidr = "10.0.0.0/16"
subset_public_cidr = ["10.0.1.0/24","10.0.2.0/24"]
subset_private_cidr = ["10.0.3.0/24","10.0.4.0/24"]
subset_database_cidr = ["10.0.5.0/24","10.0.6.0/24"]
subnet_public_id = ["aws_subnet.public-subnet-1.id","aws_subnet.public-subnet-1.id","aws_subnet.database-pubilc-subnet.id"]
ec2_Bastion = "t2.micro"

subnet_private_id = ["aws_subnet.private-subnet-1.id","aws_subnet.private-subnet-2.id","aws_subnet.database-private-subnet.id"]