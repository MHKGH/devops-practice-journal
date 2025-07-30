output "bucket_id" {
  value = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}