variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
# variable "AWS_REGION" {}

variable "environment" {
  default = "dev"
}

# variable "default_vpc_id" {
#   default = "vpc-0d7572c32c89d9d9f"
# }

variable "system" {
  default = "Retail Reporting"
}

variable "subsystem" {
  default = "CliXX"
}

variable "availability_zone" {
  default = "us-east-1c"
}

variable "subnets_cidrs" {
  type = list(string)
  default = [
    "172.31.80.0/20"
  ]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_key.pub"
}

variable "OwnerEmail" {
  default = "ayanfeafelumo@gmail.com"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-stack-1.0"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
} 

variable "project" {
  default =  "Stack"
}

variable "stack_controls" {
  type = map(string)
  default = {
    ec2_create  = "Y"
    blog_create = "Y"
    ebs_create  = "Y"
  }
}

variable "EC2_Components" {
  type = map(string)
  default = {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = "true"
    instance_type         = "t2.micro"
  }
}

variable "num_ebs_volumes" {
  description = "Number of EBS volumes to create"
  default     = 3  
}

variable "ebs_volumes" {
  description = "Map of availability zones and corresponding sizes for EBS volumes"
  type        = map
  default     = {
    "us-east-1c" = 8
    "us-east-1c" = 8
    "us-east-1c" = 8
  }
}

variable "EBS_Components" {
  type = map(string)
  default = {      
    volume_type      = "gp2"
    volume_size      = 8
  }
}

variable "cidr" {
    description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
    type        = string
    default     = "10.0.0.0/16"
}

variable "cidr_private_subnet" {
    description = "CIDR block for private subnets"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_public_subnet" {
    description = "CIDR block for public subnets"
    type        = list(string)
    default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_tenancy" {
    description = "A tenancy option for instances launched into the VPC"
    type        = string
    default     = "default"
}

variable "enable_dns_hostnames" {
    description = "Should be true to enable DNS hostnames in the VPC"
    type        = bool
    default     = true
}

variable "enable_dns_support" {
    description = "Should be true to enable DNS support in the VPC"
    type        = bool
    default     = true
}

variable "subnet_availability_zone" {
    type        = list(string)
    default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "access_ports" {
  type    = list(number)
  default = [80, 22, 3306, 2049] # 22 -> ssh, 80 -> http, 3306 -> Aurora/MySQL, 2049 -> EFS mount
}

variable "block_device_config" {
  type    = list(object({
    device_name  = string
    volume_size  = number
  }))
  default = [
  {
    device_name = "/dev/sdf"
    volume_size = 8
  },
  {
    device_name = "/dev/sdg"
    volume_size = 8
  },
  {
    device_name = "/dev/sdh"
    volume_size = 8
  },
  {
    device_name = "/dev/sdi"
    volume_size = 8
  },
  {
    device_name = "/dev/sdj"
    volume_size = 8
  }
  ]
}

variable "user_data" {
  default = "./scripts/bootstrapCliXX"
  
}

variable "efs_mounts" {
  default =  2
}