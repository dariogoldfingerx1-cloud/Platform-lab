resource "aws_iam_role" "codebuild" {
  name = "platform-lab-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codebuild.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "platform-lab-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      # Terraform state
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration"
        ]
        Resource = "arn:aws:s3:::platform-lab-tfstate-007"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::platform-lab-tfstate-007/platform-lab/codepipeline.tfstate*"
      },

      # CodePipeline artifact bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = aws_s3_bucket.artifacts.arn
      },

      # Manage the artifact S3 bucket
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.artifacts.arn
      },

      # Read/manage CodeBuild projects
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetProjects",
          "codebuild:CreateProject",
          "codebuild:UpdateProject",
          "codebuild:DeleteProject"
        ]
        Resource = [
          aws_codebuild_project.terraform_plan.arn,
          aws_codebuild_project.terraform_apply.arn
        ]
      },

      # Manage CodePipeline
      {
        Effect = "Allow"
        Action = [
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:CreatePipeline",
          "codepipeline:UpdatePipeline",
          "codepipeline:DeletePipeline"
        ]
        Resource = aws_codepipeline.platform.arn
      },

      # IAM roles used by this infrastructure
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.codebuild.arn,
          aws_iam_role.codepipeline.arn,
          "arn:aws:iam::126588786443:role/platform-lab-dev-role"
        ]
      },

      # GitHub connection
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:126588786443:connection/2b751be4-29ea-48b2-82db-b01bd2b1c8b6"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "platform-lab-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = [
          aws_codebuild_project.terraform_plan.arn,
          aws_codebuild_project.terraform_apply.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codeconnections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:126588786443:connection/2b751be4-29ea-48b2-82db-b01bd2b1c8b6"
      }
    ]
  })
}