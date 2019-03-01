provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "aws_eip" "ec2_public_ip" {
  instance = "${aws_instance.jhwtestbox.id}"
  depends_on = ["aws_instance.jhwtestbox"]
}

resource "aws_instance" "jhwtestbox" {
  ami = "${lookup(var.aws_ami, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${var.aws_key_pair}"
  tags {
    Name = "JHWAUTestEC2"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.jhwtestbox.public_ip} >> file.txt"
    command = "echo ${aws_instance.jhwtestbox.id} >> file.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /opt/jhwsydney"
    ]
  }

}
