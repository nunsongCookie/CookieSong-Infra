variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "public_subnet_names" {
  type    = list(string)
  default = ["song-s-an2-pub-az1", "song-s-an2-pub-az2"]
}

variable "private_subnet_web_cidr" {
  type    = list(string)
  default = ["10.0.64.0/19", "10.0.96.0/19"]
}

variable "private_subnet_web_names" {
  type    = list(string)
  default = ["song-s-an2-pri-az1-front", "song-s-an2-pri-az2-front"]
}

variable "private_subnet_was_cidr" {
  type    = list(string)
  default = ["10.0.128.0/19", "10.0.160.0/19"]
}

variable "private_subnet_was_names" {
  type    = list(string)
  default = ["song-s-an2-pri-az1-back", "song-s-an2-pri-az2-back"]
}

variable "private_subnet_rds_cidr" {
  type    = list(string)
  default = ["10.0.192.0/19", "10.0.224.0/19"]
}

variable "private_subnet_rds_names" {
  type    = list(string)
  default = ["song-s-an2-pri-az1-rds", "song-s-an2-pri-az2-rds"]
}

variable "availability_zone_list" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}


