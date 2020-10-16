variable "domain_name" {
    type = string # It will be your web hosting bucket name
}

variable "logs_bucket" {
    type = string # Bucket name to store cloudfront logs
}

variable "aws_profile" {
    type = string # A AWS profile with access keys configured in your local machine
}