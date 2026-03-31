module "namespace" {
  source = "../../modules/namespace"
  
  namespace = var.namespace
  labels = {
    environment = "local"
    managed-by  = "terraform"
  }
}
