resource "aws_spot_instance_request" "ec2-spot" {
  count = var.INSTANCE_COUNT
  ami           = data.aws_ami.ami.id
  instance_type = var.INSTANCE_TYPE
  tags = {
    Name = "${var.COMPONENT}-${var.ENV}-${count.index+1}"
  }
 subnet_id = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[count.index]
  #creates ec2 spot instance in that particular vpc and private subnet id getting data from data.tf remote state resource
  wait_for_fulfillment = true
  vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_ec2_tag" "spot-instances" {
  count = length(aws_spot_instance_request.ec2-spot)
  resource_id = aws_spot_instance_request.ec2-spot.*.spot_instance_id[count.index]
  key         = "Name"
  value       = "${var.COMPONENT}-${var.ENV}-${count.index+1}"
}




