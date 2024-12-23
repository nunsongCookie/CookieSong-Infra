# Primary RDS Subnet Group
resource "aws_db_subnet_group" "rds-az1-subnet-group" {
  name        = "song-s-an2-pri-az1-rds"
  subnet_ids  = [var.rds_subnet_ids[0]]

  tags = {
    Name = "song-s-an2-pri-az1-rds"
    Resource = "rds"
  }
}

# Primary RDS Instance
resource "aws_db_instance" "rds-az1" {
  identifier           = "song-rds-an2-az1"
  db_name              = "song_mysql_an2_az1"
  instance_class       = "db.t2.micro"
  engine               = "mysql"
  username             = "admin"
  password             = "cookiesong!"
  storage_type         = "gp3"
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.rds-az1-subnet-group.name

  availability_zone       = "ap-northeast-2a"
  backup_retention_period = 3

  tags = {
    Name = "song-rds-an2-az1"
    Resource = "rds"
  }
}

# Secondary RDS Subnet Group
resource "aws_db_subnet_group" "rds-az2-subnet-group" {
  name        = "song-s-an2-pri-az2-rds"
  subnet_ids  = [var.rds_subnet_ids[1]]

  tags = {
    Name = "song-s-an2-pri-az2-rds"
    Resource = "rds"
  }
}

# Secondary RDS Instance
resource "aws_db_instance" "rds-az2" {  
  identifier           = "song-rds-an2-az2"
  db_name              = "song_mysql_an2_az2"  
  instance_class       = "db.t2.micro"
  engine               = "mysql"
  username             = "admin"
  password             = "cookiesong!"
  storage_type         = "gp3"
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.rds-az2-subnet-group.name 

  availability_zone       = "ap-northeast-2c"
  backup_retention_period = 3

  tags = {
    Name = "song-rds-an2-az2"
    Resource = "rds"
  }
}
