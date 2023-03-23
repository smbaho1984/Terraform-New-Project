output "public_subnet_ids" {
  value = "aws_subnet.web.ids"
}

output "private_subnet_ids" {
  value = "aws_subnet.db.ids"
}

output "vpc_id" {
  value = "aws_vpc.main.id"
}
