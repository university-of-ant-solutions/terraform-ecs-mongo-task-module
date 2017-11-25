## State storage
terraform {
  backend "s3" {}
}

data "template_file" "task_definitions" {
  template = "${file("${path.module}/templates/mongo_service_task_definitions.json")}"

  vars {
    container_name    = "${local.container_name}"
    root_password     = "${var.root_password}"
    init_password     = "${var.init_password}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "${local.task_definitions_name}" # Task Definition Name
  container_definitions = "${data.template_file.task_definitions.rendered}"
  network_mode = "bridge"
  # placement_constraints: []
  volume {
    name      = "data"
    host_path = "/data/db"
  }
}

resource "aws_ecs_service" "mongo-service" {
  name = "mongo-service"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  deployment_maximum_percent = 200 # allow to create 2 new task before remove old task
  # if new task is failed, all of old task is still run
  deployment_minimum_healthy_percent = 0
}

resource "aws_route53_record" "website_route53_record" {
  zone_id = "${var.zone_id}"
  name = "mongo.auth.dev"
  type = "CNAME"
  ttl     = "300"
  records = ["${var.cluster_ec2_private_dns}"]
}
