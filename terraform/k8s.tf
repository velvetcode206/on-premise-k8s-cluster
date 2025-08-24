resource "kubernetes_namespace" "required" {
  for_each = toset(var.k8s_namespaces)

  metadata {
    name = each.key
  }
}