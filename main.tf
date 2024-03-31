### Declare Key Pair
locals {
  ServerPrefix = ""
}

resource "aws_key_pair" "Stack_KP" {
  key_name   = "ayanfe_kp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_vpc" "stack" {
  cidr_block            =   var.cidr
  instance_tenancy      =   var.instance_tenancy
  enable_dns_hostnames  =   var.enable_dns_hostnames
  enable_dns_support    =   var.enable_dns_support
    
  tags = merge({Name    = "${local.ServerPrefix != "" ? local.ServerPrefix : "Stack_VPC"}"})
}

resource "aws_subnet" "public_stack" {
    count                   =   length(var.cidr_public_subnet)
    vpc_id                  =   aws_vpc.stack.id
    availability_zone       =   var.subnet_availability_zone[count.index]
    cidr_block              =   var.cidr_public_subnet[count.index]
    map_public_ip_on_launch =   true 

    tags = merge({Name    = "${local.ServerPrefix != "" ? local.ServerPrefix : "Stack_Pub_VPC"}${count.index}"})
}

resource "aws_subnet" "private_stack" {
    count                   =   length(var.cidr_private_subnet)
    vpc_id                  =   aws_vpc.stack.id
    availability_zone       =   var.subnet_availability_zone[count.index]
    cidr_block              =   var.cidr_private_subnet[count.index]
    map_public_ip_on_launch =   true

    tags = merge({Name    = "${local.ServerPrefix != "" ? local.ServerPrefix : "Stack_Pri_VPC"}${count.index}"})
}

resource "aws_internet_gateway" "stack" {
    vpc_id                =   aws_vpc.stack.id
    tags = merge({Name    =   "${local.ServerPrefix != "" ? local.ServerPrefix : "Stack_IGW"}"})
}

resource "aws_route_table" "public_stack" {
    vpc_id                =   aws_vpc.stack.id

    #attach IGW for ingress traffic for VPC
    route {
        cidr_block        =   "0.0.0.0/0"
        gateway_id        =   aws_internet_gateway.stack.id
    }

    #attach public subnets to route
    route {
        cidr_block        =   var.cidr
        gateway_id        =   "local"
    }
}

resource "aws_route_table_association" "public_stack" {
    count                 =   length(var.cidr_public_subnet)
    subnet_id             =   aws_subnet.public_stack[count.index].id
    route_table_id        =   aws_route_table.public_stack.id
}

resource "aws_route_table" "private_stack" {
    vpc_id                =   aws_vpc.stack.id

    #attach private subnets to route
    route {
        cidr_block        =   var.cidr
        gateway_id        =   "local"
    }
}

resource "aws_route_table_association" "private_stack" {
    count                 =   length(var.cidr_private_subnet)
    subnet_id             =   aws_subnet.private_stack[count.index].id
    route_table_id        =   aws_route_table.private_stack.id
}


resource "aws_security_group" "stack-sg" {
  vpc_id      = aws_vpc.stack.id
  name        = "terraform_web_DMZ"
  description = "Security group for Application Servers"

  dynamic "ingress" {
    for_each      = var.access_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      description = "Security group for Application Servers"
      cidr_blocks = ["0.0.0.0/0"]
    } 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  timeouts {
    delete = "2m"
  }

  lifecycle {
    create_before_destroy = true
  }
}
  ############# CLIXX ######################
resource "aws_db_instance" "CliXX" {
  snapshot_identifier    = "${data.aws_db_snapshot.clixxdb.id}"
  instance_class         = "db.t2.micro" 
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_stances.name
  vpc_security_group_ids = [aws_security_group.stack-sg.id]
}

resource "aws_efs_file_system" "efs" {
  creation_token = "stack-terra-EFS"
  tags = {
    Name = "stack_EFS"
  }
}

resource "aws_efs_mount_target" "mount" {
  count           = var.efs_mounts
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public_stack[count.index].id
  security_groups = [aws_security_group.stack-sg.id]
}

################## BLOG ####################

resource "aws_db_instance" "Blog" {
  snapshot_identifier    = "${data.aws_db_snapshot.blogdb.id}"
  instance_class         = "db.t2.micro" 
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_stances.name
  vpc_security_group_ids = [aws_security_group.stack-sg.id] 
}

resource "aws_db_subnet_group" "db_stances" {
  name                   =  "stack_databases"
  subnet_ids             =  aws_subnet.private_stack[*].id
}


resource "aws_efs_file_system" "blog_efs" {
  creation_token = "blog-terra-EFS"
  tags = {
    Name = "blog_EFS"
  }
}

resource "aws_efs_mount_target" "blog_mount" {
  count           = var.efs_mounts
  file_system_id  = aws_efs_file_system.blog_efs.id
  subnet_id       = aws_subnet.public_stack[count.index].id
  security_groups = [aws_security_group.stack-sg.id]
}



