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
              # 1. Wait for Ubuntu's background updates to finish
              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
                echo "Waiting for other package managers..."
                sleep 5
              done

              # 2. Use a specific user-friendly install command
              export DEBIAN_FRONTEND=noninteractive
              apt-get update -y
              apt-get install -y python3-pip python3-flask python3-pymysql

              # 3. Create the app as root (to avoid permission issues)
              cat << 'APP' > /root/app.py
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/records/save/', methods=['POST', 'GET'])
def save_record():
    return jsonify({
        "status": "Success", 
        "region": "Sao Paulo", 
        "node": "Ubuntu-Private-Vault"
    }), 200

if __name__ == '__main__':
    # Listen on all IPs on Port 80
    app.run(host='0.0.0.0', port=80)
APP

              # 4. Start it explicitly with sudo/root
              sudo python3 /root/app.py > /root/app.log 2>&1 &
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