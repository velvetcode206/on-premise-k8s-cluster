resource "helm_release" "ingress_nginx" {
  name             = "${var.project_prefix}-${var.helm_ingress_nginx_name_suffix}"
  repository       = var.helm_ingress_nginx_repo
  chart            = "ingress-nginx"
  version          = var.helm_ingress_nginx_version
  namespace        = var.helm_ingress_nginx_namespace
  create_namespace = true
  values           = [file(var.helm_ingress_nginx_values_file)]
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
        --timeout=180s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "${var.project_prefix}-${var.helm_kube_prometheus_stack_name_suffix}"
  repository       = var.helm_kube_prometheus_stack_repo
  chart            = "kube-prometheus-stack"
  version          = var.helm_kube_prometheus_stack_version
  namespace        = var.helm_kube_prometheus_stack_namespace
  create_namespace = true
  values           = [file(var.helm_kube_prometheus_stack_values_file)]
  depends_on       = [null_resource.wait_for_ingress_nginx]
}

resource "null_resource" "wait_for_kube_prometheus_stack" {
  triggers = { 
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the monitoring...\n"
      kubectl wait --namespace ${var.helm_kube_prometheus_stack_namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/name=grafana \
        --timeout=180s
    EOF
  }

  depends_on = [helm_release.kube_prometheus_stack]
}