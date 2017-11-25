variable "environment" {}

variable "version" {}

variable "cluster_id" {}

variable "task_definitions_name" {
  default = "task-definitions"
  description = "The name of task definitions."
}

variable "service_name" {
  description = "The name of the service."
}

variable "container_name" {
  default = "ecs-mongo-task-as1"
}

variable "zone_id" {}

variable "cluster_ec2_private_dns" {}

variable "root_password" {}

variable "init_password" {}
