resource "helm_release" "ingress_nginx" {
  name             = "${var.project_prefix}-${var.helm_ingress_nginx_name_suffix}"
  repository       = var.helm_ingress_nginx_repo
  chart            = var.helm_ingress_nginx_chart
  version          = var.helm_ingress_nginx_version
  namespace        = var.helm_ingress_nginx_namespace
  create_namespace = true
  values           = [file(var.helm_ingress_nginx_kind_patch_file)]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}