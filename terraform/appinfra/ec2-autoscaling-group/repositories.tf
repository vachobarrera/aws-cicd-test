resource "aws_ecrpublic_repository" "mytest_ecr" {
  repository_name = "mytest_ecr"
  catalog_data {
    operating_systems = ["Linux"]
  }
}