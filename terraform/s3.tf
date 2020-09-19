variable s3_name {
    default = "aws-webapp-bucket"
}

data "template_file" "bucket_policy" {
  template = file("s3-bucket-policy/${local.s3_name}")
}

resource "aws_s3_bucket" "s3_bucket" { 
  bucket        = local.s3_name
  policy        = data.template_file.bucket_policy.rendered
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = var.versioning
  }

  # At a minimum, these tags are required.
  tags = {
    Name      = local.s3_name
  }

}
