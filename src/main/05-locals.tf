locals {
  project = format("%s-%s", var.app_name, var.env_short)

  ecs_cluster_name = format("%s-ecs-cluster", local.project)
  ecs_task_name    = format("%s-mockec-task", local.project)

  mockec_container_port = 80

  logs = {
    mock = "/ecs/mockec"
  }

}