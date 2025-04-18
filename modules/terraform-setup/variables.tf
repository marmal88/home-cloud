variable "role_name" {
  description = "value"
  type        = string
  default     = "terraform-role"
}

variable "policy_arn" {
  description = "The ARN of the policy to attach"
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# variable "tags" {
#   description = "tags for terraform invoked resources"
#   type        = string
# }
