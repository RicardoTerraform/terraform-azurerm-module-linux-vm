data "template_cloudinit_config" "init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/test.sh")
  }

  # dynamic "part" {
  #   for_each = var.metrics ? ["true"] : []
  #   content {
  #     content_type = "text/x-shellscript"
  #     content      = file("${path.module}/scripts/configure-docker.sh")
  #   }
  # }

  dynamic "part" {
    for_each = toset(var.vm_custom_data_script)

    content {
      content_type = "text/x-shellscript"
      content      = file("./${each.key}")
    }
  }
}
