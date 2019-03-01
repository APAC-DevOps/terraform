provider "aws" {
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}


resource "aws_cloudwatch_log_group" "jhwau_cloudwatch_log_aem" {
  name = "jhwau_cloudwatch_log_aem"
}

//Outputs
output "jhwau_cloudwatch_log_aem" {
  value = "${aws_cloudwatch_log_group.jhwau_cloudwatch_log_aem.arn}"
}
