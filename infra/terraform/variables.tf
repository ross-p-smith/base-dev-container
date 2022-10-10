variable "deployer_display_name" {
  type        = string
  description = "The individual who deployed the Azure resources"
}

variable "branch_id" {
  type        = string
  description = "The branch the Azure resources were deployed from"
}
