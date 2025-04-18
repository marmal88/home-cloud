# this file specifies resources spun up to support Terraform operations

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = var.role_name
  policy_arn = var.policy_arn
}
