resource "aws_iam_role" "codebuild" {
  name = "platform-lab-application-codebuild-role"

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
  name = "platform-lab-application-codebuild-policy"
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

      # Application Terraform state
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::platform-lab-tfstate-007/platform-lab/terraform.tfstate*"
      },
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

      # Application artifacts
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
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.artifacts.arn
      },

      # Lambda
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:DeleteFunction",
          "lambda:ListVersionsByFunction",
          "lambda:TagResource",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:UntagResource"
        ]
        Resource = "arn:aws:lambda:us-east-1:126588786443:function:platform-lab-dev"
      },

      # IAM role used by Lambda
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
          "iam:DetachRolePolicy"
        ]
        Resource = "arn:aws:iam::126588786443:role/platform-lab-dev-role"
      },

      # Attach Lambda execution policy
      {
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = "arn:aws:iam::126588786443:role/platform-lab-dev-role"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline" {
  name = "platform-lab-application-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codepipeline.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "platform-lab-application-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      # Application artifact bucket
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

      # CodeBuild
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

      # GitHub CodeConnection
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
