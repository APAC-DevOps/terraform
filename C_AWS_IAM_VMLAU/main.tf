provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}


resource "aws_iam_role" "jhwau_iam_role_s3" {
    name = "jhwau_iam_role_s3"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sts:AssumeRole" ],
      "Effect": "Allow",
      "Principal": { "Service": [ "ec2.amazonaws.com" ] }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jhwau_iam_role_policy_s3" {
    name = "jhwau_iam_role_policy_s3"
    role = "${aws_iam_role.jhwau_iam_role_s3.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "s3:GetObject", "s3:ListBucket" ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:s3:::jhwau-terraform-state", "arn:aws:s3:::jhwau-terraform-state/*", "arn:aws:s3:::jhwau-kstl-globalservice", "arn:aws:s3:::jhwau-kstl-globalservice/*" ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jhwau_pub_svr_instant_profile" {
    name = "jhwau_pub_svr_instant_profile"
    roles = ["${aws_iam_role.jhwau_iam_role_s3.name}"]
}

resource "aws_iam_role" "jhwau_iam_role_sqs" {
    name = "jhwau_iam_role_sqs"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sts:AssumeRole" ],
      "Effect": "Allow",
      "Principal": { "Service": "autoscaling.amazonaws.com" }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jhwau_iam_role_policy_sqs" {
    name = "jhwau_iam_role_policy_sqs"
    role = "${aws_iam_role.jhwau_iam_role_sqs.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sns:Publish" ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:sns:ap-southeast-2:014461671369:JHWAU-AEM-ASG-INCIDENT" ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "jhwau_iam_role_cloudtrail" {
    name = "jhwau_iam_role_cloudtrail"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sts:AssumeRole" ],
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jhwau_iam_role_policy_cloudtrail" {
    name = "jhwau_iam_role_policy_cloudtrail"
    role = "${aws_iam_role.jhwau_iam_role_cloudtrail.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "logs:CreateLogStream", "logs:PutLogEvents" ],
      "Effect": "Allow",
      "Resource": [ "arn:aws:logs:ap-southeast-2:014461671369:log-group:jhwau_cloudwatch_log_aem:*" ]
    }
  ]
}
EOF
}

//Outputs
output "jhwau_pub_svr_instant_profile" {
  value = "${aws_iam_instance_profile.jhwau_pub_svr_instant_profile.id}"
}

output "jhwau_iam_role_sqs_arn" {
  value = "${aws_iam_role.jhwau_iam_role_sqs.arn}"
}

output "jhwau_iam_role_cloudtrail" {
  value = "${aws_iam_role.jhwau_iam_role_cloudtrail.arn}"
}
