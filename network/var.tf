#variables for availability zone
variable "availability_zone" {
    description = "Availability zone"
    default = ["us-west-1a","us-west-1b"]
    type = list
}

#Variable for environment
# variable "environment name tags" {
#   description = "The environment name tags."
#   default     = ["Development","test","production"]
#   type        =    list
# }

#variable for CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/24"
  type = string
}

variable "web_subnet_a_cidr_block" {
  description = "The CIDR block for web subnet A."
  default     = "10.0.1.0/27"
  type = string
}

variable "web_subnet_b_cidr_block" {
  description = "The CIDR block for web subnet B."
  default     = "10.0.2.0/27"
  type = string
}

variable "db_subnet_a_cidr_block" {
  description = "The CIDR block for database subnet A."
  default     = "10.0.3.0/27"
  type = string
}

variable "db_subnet_b_cidr_block" {
  description = "The CIDR block for database subnet B."
  default     = "10.0.4.0/27"
  type = string
}