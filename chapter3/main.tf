provider "aws" {
  region = "us-west-2"
  profile = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "jg-tutorial-terraform-state"

  # 실수로 S3 버킷을 삭제하는 것을 방지
  lifecycle {
    prevent_destroy = true
  }

  # 상태 파일의 버전 관리 활성화
  versioning {
    enabled = true
  }

  # 서버측 암호화 활성화
  server_side_encryption_configuration {
    rule{
        apply_server_side_encryption_by_default{
            sse_algorithm = "AES256"
        }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "jg-tutorial-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}

# 나머지 구성은, backend.hc1 파일에 저장
terraform {
  backend "s3"{
      key = "global/s3/terraform.tfstate"
  }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value= aws_dynamodb_table.terraform_locks
  description = "The name of the DynamoDB table"  
}
