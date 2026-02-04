# 1. Tokyo-Specific Launch Template
resource "aws_launch_template" "shinjuku_lt" {
  # No provider alias needed if Tokyo is your default, 
  # otherwise use provider = aws.tokyo
  name_prefix   = "shinjuku-lt-"
  image_id      = "ami-0d52744d6551d851e" # Example Amazon Linux 2023 ID for ap-northeast-1
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.shinjuku_ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "DB_ENDPOINT=${aws_db_instance.shinjuku_medical_db.address}" >> /etc/environment
              echo "DB_NAME=medical_records" >> /etc/environment
              # Start your app logic here
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "shinjuku-medical-node" }
  }
}

# 2. Tokyo-Specific ASG
resource "aws_autoscaling_group" "shinjuku_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 1
  # Pointing to Tokyo Subnets
  vpc_zone_identifier = [aws_subnet.chewbacca_private_subnet01.id, aws_subnet.chewbacca_private_subnet02.id]

  launch_template {
    id      = aws_launch_template.shinjuku_lt.id
    version = "$Latest"
  }
}