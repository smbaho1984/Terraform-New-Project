output "lb_sg_id" {
    value = "aws_security_group.lb_sg.id"
}

output "web_sg_id" {
    value = "aws_security_group.web_sg.id"
}

output "db_sg_id" {
    value = "aws_security_group.db_sg"
}