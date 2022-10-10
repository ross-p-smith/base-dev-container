variable "location" {
  type        = string
  description = "The location of the Azure resources"
}

variable "project_name" {
  type        = string
  description = "The project name - normal used as a suffix in resource names"
}

variable "deployer_display_name" {
  type        = string
  description = "The individual who deployed the Azure resources"
}

variable "branch_id" {
  type        = string
  description = "The branch the Azure resources were deployed from"
}
