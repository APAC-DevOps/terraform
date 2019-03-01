provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "jhwau_aws_logs" {
    bucket = "jhwau-aws-logs"
    force_destroy = true
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::jhwau-aws-logs"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::jhwau-aws-logs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
			       "Sid": "",
			          "Effect": "Allow",
			             "Principal": {
				                 "AWS": "arn:aws:iam::014461671369:user/wujianhua@outlook.jp"
			                      },
			          "Action": "s3:*",
			          "Resource": [
				        "arn:aws:s3:::jhwau-aws-logs",
				        "arn:aws:s3:::jhwau-aws-logs/*"
			             ]
		    },
		    {
			      "Sid": "",
			      "Effect": "Allow",
			      "Principal": {
				    "AWS": "arn:aws:iam::783225319266:root"
			      },
			      "Action": "s3:PutObject",
			      "Resource": "arn:aws:s3:::jhwau-aws-logs/aws-asg/AWSLogs/014461671369/*"
		    }
    ]
}
POLICY
}


//Outputs
output "jhwau_aws_logs_arn" {
  value = "${aws_s3_bucket.jhwau_aws_logs.arn}"
}

output "jhwau_aws_logs_id" {
  value = "${aws_s3_bucket.jhwau_aws_logs.id}"
}
