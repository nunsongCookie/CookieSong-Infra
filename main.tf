####################################################
# state 파일을 위한 backend 구성
####################################################
# state 파일 저장용 s3 생성
resource "aws_s3_bucket" "terraform_state" {
  bucket = "song-tfstate-s3-an2"
}

# 버킷 버전 관리 활성화
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 서버사이드 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB 테이블 생성 (state locking용)
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

####################################################
# VPC 생성
####################################################
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

# 파일 저장을 위한 s3 생성
resource "aws_s3_bucket" "s3" {
  bucket = "song-s3-an2"
}
####################################################
# ECR 생성
####################################################
module "ecr" {
  source = "./modules/ecr"
}

####################################################
# IAM 생성
####################################################
module "iam" {
  source = "./modules/iam"
  ecr_repository_arns = module.ecr.repository_arns
}

####################################################
# Security Group 생성
####################################################
module "sg-test" {
  source = "./modules/security_group"
  name   = "song-sg-test-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]

  egress_rules = [
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]
}

module "sg-alb" {
  source = "./modules/security_group"
  name   = "song-sg-alb-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "TCP"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    },
    {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "TCP"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]

  egress_rules = [
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]
}

module "sg-pub-nat" {
  source = "./modules/security_group"
  name   = "song-sg-pub-nat-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 22
      to_port                      = 22
      ip_protocol                  = "TCP"
      cidr_ipv4                    = "10.0.0.0/16"
      referenced_security_group_id = null
    }
  ]

  egress_rules = [
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]
}


module "sg-pri-web" {
  source = "./modules/security_group"
  name   = "song-sg-pri-web-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-alb.sg-id
    },
    {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-alb.sg-id
    }
  ]

  egress_rules = [
    {
      from_port                    = 3000
      to_port                      = 3000
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-alb.sg-id
    },
    {
      from_port                    = 8080
      to_port                      = 8080
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-pri-was.sg-id
    },
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]
}

module "sg-pri-was" {
  source = "./modules/security_group"
  name   = "song-sg-pri-was-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 8080
      to_port                      = 8080
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-pri-web.sg-id
    }
  ]

  egress_rules = [
    {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-pri-rds.sg-id
    },
    {
      from_port                    = 8080
      to_port                      = 8080
      ip_protocol                  = "TCP"
      cidr_ipv4                    = "10.0.0.0/16"
      referenced_security_group_id = null
    },
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-pub-nat.sg-id
    }
  ]
}

module "sg-pri-rds" {
  source = "./modules/security_group"
  name   = "song-sg-pri-rds-an2"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "TCP"
      cidr_ipv4                    = null
      referenced_security_group_id = module.sg-pri-was.sg-id
    }
  ]

  egress_rules = [
    {
      from_port                    = 0
      to_port                      = 0
      ip_protocol                  = "all"
      cidr_ipv4                    = "0.0.0.0/0"
      referenced_security_group_id = null
    }
  ]
}

####################################################
# NACL 생성
####################################################
module "nacl-test" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-test-an2"
  subnet_ids = []

  ingress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]

  egress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

module "nacl-alb" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-alb-an2"
  subnet_ids = [module.vpc.public_subnet_ids[1]]

  ingress_rules = [
    {
      rule_number = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = "10.0.0.0/16"
      from_port   = 22
      to_port     = 22
    },
    {
      rule_number = 200
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
  egress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

module "nacl-pub-nat" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-pub-nat-an2"
  subnet_ids = [module.vpc.public_subnet_ids[0]] # song-s-an2-pub-az1

  ingress_rules = [
    {
      rule_number = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = "10.0.0.0/16"
      from_port   = 22
      to_port     = 22
    },
    {
      rule_number = 200
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
  egress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

module "nacl-pri-web" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-pri-web-an2"
  subnet_ids = [module.vpc.private_web_subnet_ids]
  ingress_rules = [
    {
      rule_number = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.public_subnet_ids[1].cidr_block
      from_port   = 80
      to_port     = 80
    },
    {
      rule_number = 200
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.public_subnet_ids[1].cidr_block
      from_port   = 443
      to_port     = 443
    },
    {
      rule_number = 300
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.public_subnet_ids[1].cidr_block
      from_port   = 3000
      to_port     = 3000
    }
  ]
  egress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = module.vpc.private_was_subnet_ids[0].cidr_block
      from_port   = 8080
      to_port     = 8080
    },
    {
      rule_number = 110
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = module.vpc.private_was_subnet_ids[1].cidr_block
      from_port   = 8080
      to_port     = 8080
    }
  ]
}

module "nacl-pri-was" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-pri-was-an2"
  subnet_ids = [module.vpc.private_was_subnet_ids]
  ingress_rules = [
    {
      rule_number = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.private_web_subnet_ids[0].cidr_block
      from_port   = 8080
      to_port     = 8080
    },
    {
      rule_number = 110
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.private_web_subnet_ids[1].cidr_block
      from_port   = 8080
      to_port     = 8080
    },
  ]
  egress_rules = [
    {
      rule_number = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.rds_subnet_ids[0].cidr_block
      from_port   = 3306
      to_port     = 3306
    },
    {
      rule_number = 110
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.rds_subnet_ids[1].cidr_block
      from_port   = 3306
      to_port     = 3306
    },
    {
      rule_number = 200
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = "10.0.0.0/16"
      from_port   = 8080
      to_port     = 8080
    }
  ]
}

module "nacl-rds" {
  source     = "./modules/nacl"
  vpc_id     = module.vpc.vpc_id
  name       = "song-nacl-pri-rds-an2"
  subnet_ids = [module.vpc.rds_subnet_ids]
  ingress_rules = [
    {
      rule_no     = 100
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.private_was_subnet_ids[0].cidr_block
      from_port   = 3306
      to_port     = 3306
    },
    {
      rule_no     = 110
      protocol    = "TCP"
      rule_action = "allow"
      cidr_block  = module.vpc.private_was_subnet_ids[1].cidr_block
      from_port   = 3306
      to_port     = 3306
    }
  ]
  egress_rules = [
    {
      rule_number = 100
      protocol    = "all"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
    }
  ]
}

####################################################
# ASG 생성
####################################################

####################################################
# EC2 생성
####################################################

####################################################
# RDS 생성
####################################################
module "rds" {
  source = "./modules/rds"
  rds_subnet_ids = module.vpc.rds_subnet_ids
}