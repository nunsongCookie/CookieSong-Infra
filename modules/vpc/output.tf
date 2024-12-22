output "vpc_id" {
  value = aws_vpc.song-vpc-an2.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_web_subnet_ids" {
  value = aws_subnet.private_web_subnets.*.id
}

output "private_was_subnet_ids" {
  value = aws_subnet.private_was_subnets.*.id
}

output "rds_subnet_ids" {
  value = aws_subnet.private_rds_subnets.*.id
}
