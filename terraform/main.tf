module "app_infra_ec2_autoscaling_group" {
    count = var.infra_type == "ec2_autoscaling_group" ? 1 : 0
    source = "./app_infra/ec2_autoscaling_group"
    instance_type = var.instance_type
    region = var.region
    project_name = var.project_name
}

module "app_infra_ec2_cluster" {
    count = var.infra_type == "ecs_cluster" ? 1 : 0
    source = "./app_infra/ecs_cluster"
    instance_type = var.instance_type
    region = var.region
    project_name = var.project_name
}

module "cicd_infra_ec2" {
    count = var.infra_type == "ec2_autoscaling_group" ? 1 : 0
    source = "./cicd_ec2_infra"
    instance_type = var.instance_type
    region = var.region
    project_name = var.project_name
    infra_type = var.infra_type

    depends_on = [
        module.app_infra_ec2_autoscaling_group
    ]
}

module "cicd_infra_ecs" {
    count = var.infra_type == "ecs_cluster" ? 1 : 0
    source = "./cicd_ecs_infra"
    instance_type = var.instance_type
    region = var.region
    project_name = var.project_name
    infra_type = var.infra_type

    depends_on = [
        module.app_infra_ec2_cluster
    ]
}