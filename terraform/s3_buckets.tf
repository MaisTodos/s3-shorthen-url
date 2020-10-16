
resource "aws_s3_bucket" "webhost" {
  bucket = var.domain_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket
  acl    = "private"
}

data "aws_iam_policy_document" "s3_policy" {
    statement {
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.webhost.arn}/*"]

        principals {
            type        = "*"
            identifiers = ["*"]
        }
    }
}

resource "aws_s3_bucket_policy" "webhost" {
    bucket = aws_s3_bucket.webhost.id

    policy = data.aws_iam_policy_document.s3_policy.json
}