resource "helm_release" "argocd" {

  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "7.6.10"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600

  values = [
    file("${path.module}/yaml/argocd-values.yaml")
  ]

  depends_on = [helm_release.cert_manager]
}
