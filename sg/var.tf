variable "lb_sg_name" {
    description = "the name prefix for the load balancer security group"
    default = "ls_sg"
    type = string
}


variable "web_sg_name" {
    description = "the name prfix for the web security group"
    default = "ls_sg"
      type = string
}


variable "db_sg_name" {
    description = "the name prefix for the database security group"
    default = "db_sg"
      type = string
}