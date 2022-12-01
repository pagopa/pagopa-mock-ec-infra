resource "aws_iam_role" "task_execution" {
  name               = "EcsTaskMockExecutionRole"
  description        = format("Execution role of %s task", local.ecs_task_name)
  assume_role_policy = data.aws_iam_policy_document.task_execution.json
  tags               = { Name = format("%s-execution-task-role", local.project) }
}

resource "aws_iam_role_policy_attachment" "task_cms_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_cloudwatch_log_group" "mockec" {
  name              = local.logs.mock
  retention_in_days = var.logs_tasks_retention
}

resource "aws_ecs_task_definition" "mockec" {
  family                   = local.ecs_task_name
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task_execution.arn
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = local.ecs_task_name
      image     = "nginx:latest"
      cpu       = 512
      memory    = 1024
      essential = true # if true and if fails, all other containers fail. Must have at least one essential
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  lifecycle {
  }
}

resource "aws_security_group" "service" {

  name = "ECS Service Security group."

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

## Service
resource "aws_ecs_service" "mockec" {
  name                   = format("%s-srv", local.project)
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.mockec.arn
  launch_type            = "FARGATE"
  desired_count          = 1
  enable_execute_command = false

  load_balancer {
    target_group_arn = module.alb_mockec.target_group_arns[0]
    container_name   = aws_ecs_task_definition.mockec.family
    container_port   = local.mockec_container_port
  }


  network_configuration {
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.service.id]
  }

}