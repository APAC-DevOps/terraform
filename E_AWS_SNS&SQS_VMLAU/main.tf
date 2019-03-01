provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_sqs_queue" "jhwau_kellogg_project_sqs_queue" {
  name = "jhwau-kellogg-project-sqs-queue"
  /*delay_seconds = 90
  max_message_size = 204800
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10*/

}

resource "aws_sns_topic" "jhwau_aem_asg_sns_topic" {
  name = "jhwau-aem-asg-sns-topic"
  display_name = "AEMNode"
}

resource "aws_sns_topic_subscription" "jhwau_aem_asg_sns_topic_subscription" {
    topic_arn = "${aws_sns_topic.jhwau_aem_asg_sns_topic.arn}"
    protocol  = "sqs"
    endpoint  = "${aws_sqs_queue.jhwau_kellogg_project_sqs_queue.arn}"
}

output "jhwau_kellogg_project_sqs_queue_arn" {
  value = "${aws_sqs_queue.jhwau_kellogg_project_sqs_queue.arn}"
}

output "jhwau_kellogg_project_sqs_queue_id" {
  value = "${aws_sqs_queue.jhwau_kellogg_project_sqs_queue.id}"
}

output "jhwau_aem_asg_sns_topic_arn" {
  value = "${aws_sns_topic.jhwau_aem_asg_sns_topic.arn}"
}

output "jhwau_aem_asg_sns_topic_id" {
  value = "${aws_sns_topic.jhwau_aem_asg_sns_topic.id}"
}

output "jhwau_aem_asg_sns_topic_subscription_arn" {
  value = "${aws_sns_topic_subscription.jhwau_aem_asg_sns_topic_subscription.arn}"
}

output "jhwau_aem_asg_sns_topic_subscription_id" {
  value = "${aws_sns_topic_subscription.jhwau_aem_asg_sns_topic_subscription.id}"
}
