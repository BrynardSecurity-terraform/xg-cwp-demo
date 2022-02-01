data "aws_ami" "latest-windows-server-2016" {
  count         = var.windows_server == "1" ? 1 : 0
  most_recent   = true
  owners        = ["801119661308"]

  filter {
    name        = "virtualization-type"
    values      = ["hvm"]
  }
}

resource "aws_instance" ""
