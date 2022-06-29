# //////////////////////////////
# VARIABLES
# //////////////////////////////
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "bucket_name" {
  default = "mdm-terraform-state"
}

# //////////////////////////////
# PROVIDER
# //////////////////////////////
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

# //////////////////////////////
# TERRAFORM USER
# //////////////////////////////
resource "aws_iam_user" "terraform_user" {
  name = "terraform"
  force_destroy = true
}

resource "aws_iam_access_key" "terraform_access_key" {
  user = aws_iam_user.terraform_user.name  
}



resource "aws_iam_user_policy" "terraform_s3" {
  name = "terraform_access_s3"
  user = aws_iam_user.terraform_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# If the iam user already exists, we bring it in with a data call. Otherwise,
# we have to create it. Once created, we need to log into the panel and generate
# a new key to embed into the command.sh file
/* data "aws_iam_user" "terraform_user" {
  user_name = "terraform"
} */


# //////////////////////////////
# S3 BUCKET
# //////////////////////////////

resource "aws_s3_bucket" "tfremotestate" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_terraform_on_bucket" {
  bucket = aws_s3_bucket.tfremotestate.id
  policy = data.aws_iam_policy_document.allow_terraform_on_bucket.json
}

data "aws_iam_policy_document" "allow_terraform_on_bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_user.terraform_user.arn}"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.tfremotestate.arn,
      "${aws_s3_bucket.tfremotestate.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.tfremotestate.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.tfremotestate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfremotestate" {
  bucket = aws_s3_bucket.tfremotestate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# //////////////////////////////
# DYNAMODB TABLE
# //////////////////////////////
resource "aws_dynamodb_table" "tf_db_statelock" {
  name           = "tfstatelock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# //////////////////////////////
# IAM POLICY
# //////////////////////////////
resource "aws_iam_user_policy" "terraform_user_dbtable" {
  name   = "terraform"
  user   = aws_iam_user.terraform_user.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.tf_db_statelock.arn}"
            ]
        }
  ]
}
EOF
}
