resource "aws_autoscaling_group" "liberdade_asg" {
  provider         = aws.saopaulo
  desired_capacity = 2
  max_size         = 4
  min_size         = 1
  #vpc_zone_identifier = [aws_subnet.liberdade_private_subnet01.id, aws_subnet.liberdade_private_subnet02.id]
  vpc_zone_identifier = [ #needed for CLI checks, will be commented out in production
    aws_subnet.liberdade_public_subnet01.id,
    aws_subnet.liberdade_public_subnet02.id
  ]

  launch_template {
    id      = aws_launch_template.liberdade_lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "liberdade_lt" {
  provider      = aws.saopaulo
  name_prefix   = "liberdade-lt-"
  image_id      = "ami-0af6e9042ea5a4e3e" # Example Amazon Linux 2023 in sa-east-1
  instance_type = "t3.micro"

  iam_instance_profile { #needed for ssm for CLI checks
    name = aws_iam_instance_profile.ssm_profile.name
  }
  #vpc_security_group_ids = [aws_security_group.liberdade_ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Injecting the Tokyo RDS Address
              echo "DB_ENDPOINT=${aws_db_instance.shinjuku_medical_db.address}" >> /etc/environment
              echo "DB_NAME=medical_records" >> /etc/environment
              # ... additional app setup commands ...
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "liberdade-medical-node" }
  }

  network_interfaces { #needed for CLI checks, will be commented out in production
    associate_public_ip_address = true
    security_groups             = [aws_security_group.liberdade_ec2_sg.id]
  }
}