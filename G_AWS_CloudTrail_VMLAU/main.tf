provider "aws" {
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "terraform_remote_state" "c-aws-iam-jhwau" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "c-aws-iam-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

resource "terraform_remote_state" "f-aws-cloudwatch-jhwau" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "f-aws-cloudwatch-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

resource "terraform_remote_state" "b-aws-s3-jhwau" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "b-aws-s3-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

resource "aws_cloudtrail" "jhwau_cloudtrail_aem" {
    name = "jhwau-cloudtrail-aem"
    s3_bucket_name = "${terraform_remote_state.b-aws-s3-jhwau.output.jhwau_aws_logs_id}"
    s3_key_prefix = "aem"
    include_global_service_events = false
    cloud_watch_logs_role_arn = "${terraform_remote_state.c-aws-iam-jhwau.output.jhwau_iam_role_cloudtrail}"
    cloud_watch_logs_group_arn = "${terraform_remote_state.f-aws-cloudwatch-jhwau.output.jhwau_cloudwatch_log_aem}"
}

//Outputs
