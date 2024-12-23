# WEB Repository
resource "aws_ecr_repository" "web_repo" {
  name = "web-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "web-repo"
  }
}

# WAS Repository
resource "aws_ecr_repository" "was_repo" {
  name = "was-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "was-repo"
  }
}

output "ecr_repository_arns" {
  value = {
    web = aws_ecr_repository.web_repo.arn
    was = aws_ecr_repository.was_repo.arn
  }
}