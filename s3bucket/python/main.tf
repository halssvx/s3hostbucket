provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "static_site" {
  bucket = "haalaswebsitebucket"
  force_destroy = true

  website {
    index_document = "index.html"
  }

  tags = {
    Name = "StaticSite"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "website_files" {
  for_each = fileset("${path.module}/", "*.html")

  bucket = aws_s3_bucket.static_site.id
  key    = each.value
  source = "${path.module}/${each.value}"
  content_type = "text/html"
   # acl = "public-read"
}
