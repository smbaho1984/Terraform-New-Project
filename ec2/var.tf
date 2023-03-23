#variables for instnace_type
variable "instance_type" {
  description = "The EC2 instance type for the web servers."
  default     = ["t2.micro","t2.medium"]
  type = list
}

#variable for ami 
variable "ami_id" {
  description = "The AMI ID for the web servers."
  default     = {
     "linux":"ami-0c55b159cbfafe1f0"
     "ubuntu":"ami-0c55b159cbfafe1f0"
     "RHEL":"ami-0c55b159cbfafe1f0"
     }
     type = map
}

#variables for autoscaling group size
variable "min_size" {
  description = "The minimum number of instances in the web server autoscaling group."
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances in the web server autoscaling group."
  default     = 4
}

#variable for key pair name
variable "key_name" {
  default = "papy.oregon"
}

#Variables for db-tier. These variable will define all the db configurations

variable "db_name" {
  default = "my_rds_instance"
  type = string
}

variable "db_user" {
  default = "my-db-user"
  type = string
}

variable "db_password" {
  default = "my-db-password1"
}

#variable for db_instance_class
variable "db_class" {
  description = "The RDS instance class for the database."
  default     = "db.t2.micro"
  type = string
}

variable "db_engine" {
  description = "The database engine for the RDS instance."
  default     = ["mysql","Oracle","MariaDB"]
  type = list
}

variable "db_engine_version" {
  description = "The database engine version for the RDS instance."
  default     = "5.7"
  type = string
}

variable "db_allocated_storage" {
  description = "The amount of storage allocated to the RDS instance."
  default     = "20"
  type = string
}