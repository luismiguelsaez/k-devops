
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name = format("%s-%s-role",var.env,var.project)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*" }
      }
    ]
  })
}

resource "aws_iam_group" "this" {
  name = format("%s-%s-group",var.env,var.project)
}

resource "aws_iam_user" "this" {
  name = format("%s-%s-user",var.env,var.project)
}

resource "aws_iam_group_membership" "this" {
  name = format("%s-%s-group-membership",var.env,var.project)

  users = [
    aws_iam_user.this.name,
  ]

  group = aws_iam_group.this.name
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}
