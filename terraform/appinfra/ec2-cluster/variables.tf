variable "instance_type" {
    description =   "Size"
    type        =   string
    default     =   "t2.micro"
}

variable "region" {
    type    = string
    default = "us-east-1"
}

variable "project_name" {
  type = string
  default = "mytest"
}