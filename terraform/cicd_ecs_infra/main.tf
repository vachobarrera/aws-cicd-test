# Bucket s3 ========================================================

resource "aws_s3_bucket" "artifacts" {
  bucket = "artifactsmytests"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "artifacts_acl" {
  bucket = aws_s3_bucket.artifacts.id
  acl    = "private"
}

# Code build for ecs_cluster infra type ========================================================

resource "aws_codebuild_project" "mytest_codebuild_ecs" {
  count = var.infra_type == "ecs_cluster" ? 1 : 0
  name         = "${var.project_name}_codebuild_ecs"
  service_role = aws_iam_role.mytest_codebuild_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/vachobarrera/aws-cicd-test.git"
    buildspec = file("./buildspec.yml")
  }
}

# Code pipeline for ecs_cluster ========================================================

resource "aws_codepipeline" "mytest_pipeline_cluster" {
  count = var.infra_type == "ecs_cluster" ? 1 : 0
  name     = "mytest_pipeline"
  role_arn = aws_iam_role.mytest_codepipeline_role.arn

    artifact_store {
        type     = "S3"
        location = aws_s3_bucket.artifacts.id
    }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId = "vachobarrera/test-aws"
        BranchName       = "beta"
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:166973163752:connection/ad3e4529-15ee-42bf-8f42-9bb092bd7edb"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "${var.project_name}_codebuild_ecs"
      }
    }
  }
}