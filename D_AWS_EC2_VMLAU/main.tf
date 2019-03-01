provider "aws" {
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "terraform_remote_state" "jhw_vpc" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "a-aws-vpc-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

resource "terraform_remote_state" "jhwau_iam_instance_profile_s3" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "c-aws-iam-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

resource "terraform_remote_state" "e_aws_sns_sqs_jhwau" {
    backend = "s3"
    config {
      bucket = "jhwau-terraform-state"
      key = "e-aws-sns-sqs-jhwau/terraform.tfstate"
      region = "${var.aws_region}"
    }
}

//create AWS ELB
resource "aws_elb" "jhw_au_ec2_aem_elb" {
  name = "jhw-au-ec2-aem-elb"
  security_groups = [ "${terraform_remote_state.jhw_vpc.output.sg_for_public_routing_table_zone_a}", "${terraform_remote_state.jhw_vpc.output.sg_for_public_routing_table_zone_b}"]
  subnets = ["${terraform_remote_state.jhw_vpc.output.jhw_vpc_public_subnet_zone_a}", "${terraform_remote_state.jhw_vpc.output.jhw_vpc_public_subnet_zone_b}" ]
  access_logs {
    bucket = "jhwau-aws-logs"
    bucket_prefix = "aws-asg"
    interval = 60
  }

  listener {
    instance_port = 22
    instance_protocol = "tcp"
    lb_port = 22
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:22"
    interval = 10
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "jhw_au_ec2_aem_elb"
  }
}

//add a Launch Configuration
resource "aws_launch_configuration" "jhw_au_ec2_aem_lc" {
    name_prefix = "jhw-au-ec2-aem-lc"
    image_id = "${lookup(var.aws_ami, var.aws_region)}"
    instance_type = "${var.aws_aem_instance_type}"
    iam_instance_profile = "${terraform_remote_state.jhwau_iam_instance_profile_s3.output.jhwau_pub_svr_instant_profile}"
    key_name = "${var.aws_key_pair}"
    security_groups = [ "${terraform_remote_state.jhw_vpc.output.sg_for_public_routing_table_zone_a}", "${terraform_remote_state.jhw_vpc.output.sg_for_public_routing_table_zone_b}"]
    associate_public_ip_address = false
    user_data =  "#!/bin/bash\ntouch /opt/makefi\naws s3 cp s3://jhwau-kstl-globalservice/rpm/jdk-7u79-linux-x64.rpm .\nchmod +x jdk-7u79-linux-x64.rpm\nrpm -ivh jdk-7u79-linux-x64.rpm"
    lifecycle {
      create_before_destroy = true
    }
}

//create AWS ASG and attach ELB
resource "aws_autoscaling_group" "jhw_au_ec2_aem_asg" {
  name = "jhw-au-ec2-aem-asg"
  max_size = 3
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  #desired_capacity = 2
  availability_zones = ["${lookup(var.aws_availability_zone, var.ap-southeast-2a)}", "${lookup(var.aws_availability_zone, var.ap-southeast-2b)}"]
  launch_configuration = "${aws_launch_configuration.jhw_au_ec2_aem_lc.name}"
  force_delete = false
  load_balancers = [ "${aws_elb.jhw_au_ec2_aem_elb.id}"]
  vpc_zone_identifier = [ "${terraform_remote_state.jhw_vpc.output.jhw_vpc_public_subnet_zone_a}", "${terraform_remote_state.jhw_vpc.output.jhw_vpc_public_subnet_zone_b}" ]
  termination_policies = ["OldestInstance"]

  tag {
    key = "Name"
    value = "JHW_AU_EC2_AEM_SVR"
    propagate_at_launch = true
  }

  wait_for_elb_capacity = 2
}

resource "aws_autoscaling_notification" "jhwau_aem_asg_notification" {

  group_names = [ "${aws_autoscaling_group.jhw_au_ec2_aem_asg.name}" ]

  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  #topic_arn = "${terraform_remote_state.e_aws_sns_sqs_jhwau.output.jhwau_aem_asg_sns_topic_arn}"
  topic_arn = "${var.aws_sns_topic_email_notification}"
}

/*resource "aws_autoscaling_lifecycle_hook" "jhwau_aem_asg_lifecycle"  {
    name = "jhwau-aem-asg-lifecycle"
    autoscaling_group_name = "${aws_autoscaling_group.jhw_au_ec2_aem_asg.name}"
    default_result = "CONTINUE"
    heartbeat_timeout = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_metadata = <<EOF
{
  "JHWAUASGLaunchUP": "AEM Instances Are Lunching"
}
EOF
    notification_target_arn = "${var.aws_sns_topic_email_notification}"
    role_arn = "${terraform_remote_state.jhwau_iam_instance_profile_s3.output.jhwau_iam_role_sqs_arn}"
}*/

resource "aws_autoscaling_policy" "jhwau_aem_asg_policy" {
  name = "jhwau-aem-asg-policy"
  scaling_adjustment = 3
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.jhw_au_ec2_aem_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "jhwau_aem_asg_cloudwatch_cpu_alarm" {
    alarm_name = "jhwau-aem-asg-cloudwatch-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "80"
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.jhw_au_ec2_aem_asg.name}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_autoscaling_policy.jhwau_aem_asg_policy.arn}"]
}
