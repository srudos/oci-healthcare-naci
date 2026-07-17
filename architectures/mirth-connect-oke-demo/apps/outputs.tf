output "mirth_helm_release_info" {
  description = "Mirth Connect Helm release info"
  value = {
    status   = helm_release.mirth_connect.status
    metadata = helm_release.mirth_connect.metadata
  }
}
