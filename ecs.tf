resource "aws_ecs_cluster" "app" {
  name = "app"
}

resource "aws_ecs_service" "sun_api" {
  desired_count   = 1
  name            = "sun-api"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.sun_api.arn
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id,
    ]

    subnets = [
      aws_subnet.private_d.id,
      aws_subnet.private_e.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sun_api.arn
    container_name   = "sun-api"
    container_port   = "3000"
  }

}

resource "aws_ecs_task_definition" "sun_api" {
  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  family             = "sun-api"
  execution_role_arn = aws_iam_role.sun_api_task_execution_role.arn

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"

  container_definitions = <<TASK_DEFINITION
[
  {
    "name": "sun-api",
    "image": "docker.io/desmith/sun-api:latest",
    "portMappings": [
      {
        "containerPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-group": "/ecs/sun-api",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
TASK_DEFINITION


}


resource "aws_cloudwatch_log_group" "sun_api" {
  name              = "/ecs/sun-api"
  retention_in_days = 90
}
