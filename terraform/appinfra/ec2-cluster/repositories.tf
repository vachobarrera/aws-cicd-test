resource "aws_ecrpublic_repository" "mytest_ecr" {
  repository_name = "${var.project_name}ecr"
  catalog_data {
    operating_systems = ["Linux"]
  }
}