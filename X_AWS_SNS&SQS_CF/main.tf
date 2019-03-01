provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_cloudformation_stack" "SNS_SQS" {
  name = "JHWAU-AWS-SNS-SQS"
  template_body = <<STACK
{
  "Resources" : {
    "AEMASGINCIDENT" : {
			"Type": "AWS::SNS::Topic",
			"Properties": {
				"TopicName": "JHWAU-AEM-ASG-INCIDENT",
				"DisplayName": "JHWAU-AEM-ASG-INCIDENT",
				"Subscription": [
					{ "Endpoint": "wujianhua@outlook.jp", "Protocol": "email" }
				]
			}
		}
  }
}
STACK
}
