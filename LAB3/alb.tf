# Tokyo ALB (The Hub)
resource "aws_lb" "shinjuku_alb" {
  name               = "shinjuku-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shinjuku_alb_sg.id] # You'll need this SG too
  subnets            = [aws_subnet.chewbacca_public_subnet01.id, aws_subnet.chewbacca_public_subnet02.id]
}

# São Paulo ALB (The Spoke)
resource "aws_lb" "liberdade_alb" {
  provider           = aws.saopaulo
  name               = "liberdade-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.liberdade_alb_sg.id]
  subnets            = [aws_subnet.liberdade_public_subnet01.id, aws_subnet.liberdade_public_subnet02.id]
}