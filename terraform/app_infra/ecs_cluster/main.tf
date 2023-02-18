# ECS cluster creation ========================================================

resource "aws_ecs_cluster" "mytest_ecs_cluster" {
  name = "${var.project_name}_cluster"
}


# ECS cluster task definition ========================================================

resource "aws_ecs_task_definition" "firstTask" {
  family                   = "firstTask"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "firstTask",
      "image": "${aws_ecrpublic_repository.mytest_ecr.repository_uri}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

# Container deployment ========================================================

resource "aws_ecs_service" "mytest_Container" {
  name            = "${var.project_name}_Container"
  cluster         = aws_ecs_cluster.mytest_ecs_cluster.arn
  task_definition = aws_ecs_task_definition.firstTask.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    subnets          = [aws_subnet.mytest_subnet_1.id, aws_subnet.mytest_subnet_2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mytest_target_group.id
    container_name   = "firstTask"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.mytest_listener]
}