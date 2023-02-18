# codedeploy iam role ========================================================

resource "aws_iam_role" "mytest_codedeploy_iam_role" {
  name = "${var.project_name}_codedeploy_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid  = ""
      Effect  = "Allow"
      Principal = {
        Service  = ["codedeploy.amazonaws.com"]
      }
      Action  = "sts:AssumeRole"
    },]
  })
}

data "aws_iam_policy_document" "mytest_codedeploy_policies" {
  statement {
    sid       = ""
    actions   = ["logs:*", "s3:*", "codedeploy:*", "secretsmanager:*", "iam:*", "aws-marketplace:*","autoscaling:*","codepipeline:*","codebuild:*","codestar-connections:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "mytest_codedeploy_policy" {
  name   = "${var.project_name}_codedeploy_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.mytest_codedeploy_policies.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = aws_iam_policy.mytest_codedeploy_policy.arn
  role       = aws_iam_role.mytest_codedeploy_iam_role.id
}

# codebuild iam role ========================================================

resource "aws_iam_role" "mytest_codebuild_iam_role" {
  name = "mytest_codebuild_iam_role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "codebuild.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
  }
]
}
EOF
}

resource "aws_iam_policy" "mytest_codebuild_policy" {
  name        = "mytest_codebuild_policy"
  path        = "/"
  description = "Codebuild policy"
  policy      = data.aws_iam_policy_document.mytest_codedeploy_policies.json
}

resource "aws_iam_role_policy_attachment" "codebuild-attachment1" {
  policy_arn = aws_iam_policy.mytest_codebuild_policy.arn
  role       = aws_iam_role.mytest_codebuild_iam_role.id
}

resource "aws_iam_role_policy_attachment" "codebuild-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.mytest_codebuild_iam_role.id
}


# codepipeline iam role ========================================================

resource "aws_iam_role" "mytest_codepipeline_role" {
  name = "${var.project_name}_codepipeline_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_policy" "mytest_codepipeline_policy" {
  name   = "mytest_codepipeline_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.mytest_codedeploy_policies.json
}

resource "aws_iam_role_policy_attachment" "pipeline-policy-attachment" {
  policy_arn = aws_iam_policy.mytest_codepipeline_policy.arn
  role       = aws_iam_role.mytest_codepipeline_role.id
}