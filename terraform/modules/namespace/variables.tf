variable "namespace" {
  description = "Kubernetes namespace name"
  type        = string
}

variable "labels" {
  description = "Labels to apply to namespace"
  type        = map(string)
  default     = {}
}
