/*
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_security_group" "web_traffic" {
  description = "Allow access to incoming web type traffic"
  vpc_id = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4443
    to_port = 4443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "web_traffic_sg_id" {
  value = "${aws_security_group.web_traffic.id}"
}