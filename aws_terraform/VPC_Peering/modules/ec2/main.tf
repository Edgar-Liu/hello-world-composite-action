data "aws_ami" "amzn2_ami_kernel_5" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230207.0-x86_64-gp2"]    
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "vm" {
  ami           = data.aws_ami.amzn2_ami_kernel_5.id   
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = [ var.security_group_id ]
  subnet_id = var.subnet_id

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }

  user_data = <<EOF
              sudo yum update -y 
              sudo yum install git -y 
              sudo yum install curl 
              sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
              sudo chmod +x ~/.nvm/nvm.sh
              source ~/.bashrc              
              nvm install 16
              nvm use 16
              npm install express 
  EOF

  tags = {
    Name = "${var.proj_name}-${var.vm_name}"
  }
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name_prefix = "ssm_instance_profile_2"
  role = aws_iam_role.ssm_iam_role.name
}

# Provides permission for Session Manager to access your instance with this role
resource "aws_iam_role" "ssm_iam_role" {
  name_prefix = "ssm_iam_role"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", 
    # "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", 
    # "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    ]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  
  # inline_policy {
  #   name = "ssm-s3logs"
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       { 
  #         Effect = "Allow",
  #         Action = [
  #           "s3:PutObject",
  #           # "logs:CreateLogGroup",
  #         ]
  #         Resource = [
  #           "arn:aws:s3:::${aws_s3_bucket.session_manager_logs0000.bucket}/*"
  #         ]
  #       }
  #     ]
  #   })
  # }

  # inline_policy {
  #   name = "ssm-cloudwatchlogs"
  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       { 
  #         Effect = "Allow",
  #         Action = [
  #           "logs:CreateLogGroup",
  #           "logs:CreateLogStream",
  #           "logs:DescribeLogGroups",
  #           "logs:DescribeLogStreams",
  #           "logs:PutLogEvents",
  #         ]
  #         Resource = [
  #           "arn:aws:logs:*",
  #         ]
  #       }
  #     ]
  #   })
  # }
}


# Security group to enable Session Manager with HTTPS access into the instances with the respective security groups
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc_endpoint_sg"
  description = "vpc_endpoint_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [ var.security_group_id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc_endpoint_sg"
  }
}

# Create vpc endpoint for the following 3 services: ssm, ec2messages and ssmmessages
# Associating them to subnets which contains isntances which require Session Manager
resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group_id
  ]

  subnet_ids = [ var.subnet_id ]

  private_dns_enabled = true

  tags = {
    Name = "ssm_vpc_endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group_id
  ]

  subnet_ids = [ var.subnet_id ]

  private_dns_enabled = true

  tags = {
    Name = "ec2messages_vpc_endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages_vpc_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    var.security_group_id
  ]

  subnet_ids = [ var.subnet_id ]

  private_dns_enabled = true

  tags = {
    Name = "ssmmessages_vpc_endpoint"
  }
}

# # # Create vpc endpoint for Session Manager to store logs in S3 or CloudWatch
# # # Associating them to subnets which contains isntances which require Session Manager
# # data "aws_route_table" "selected" {
# #   vpc_id = var.vpc_id
# # }

# resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-1.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = [ 
#     # data.aws_route_table.selected.route_table_id 
#     var.route_table_id
#   ]

#   tags = {
#     Name = "s3_vpc_endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "cloudwatch_vpc_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-1.logs"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     var.security_group_id
#   ]

#   subnet_ids = [ var.subnet_id ]

#   private_dns_enabled = true
# }

# Creates an AWS KMS Key to encrypt log data
resource "aws_kms_key" "session_manager_log_key" {
  description = "Key used to encrypt Session Manager logs" 
  enable_key_rotation = true

  tags = {
      Name = "session_manager_log_key"
  }
}

# # Create a S3 bucket to store Session Manager logs
# resource "aws_s3_bucket" "session_manager_logs0000" {
#   bucket = "session-manager-logs0000"

#   tags = {
#       Name = "session-manager-logs0000"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "session_manager_logs0000" {
#   bucket = aws_s3_bucket.session_manager_logs0000.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_policy" "session_manager_logs0000" {
#   bucket = aws_s3_bucket.session_manager_logs0000.id
#   policy = data.aws_iam_policy_document.session_manager_logs0000.json
# }

# data "aws_iam_policy_document" "session_manager_logs0000" {
#   statement {
#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::052521768820:role/ssm_iam_role"
#       ]
#     }

#     actions = [
#       "s3:PutObject",
#     ]

#     resources = [
#       "arn:aws:s3:::${aws_s3_bucket.session_manager_logs0000.bucket}/*"
#     ]
#   }
# }


# # Create a Cloud Log Watch Group to store Session Manager logs
# resource "aws_cloudwatch_log_group" "session_manager_logs" {
#     name = "session-manager-logs"

#     # kms_key_id = aws_kms_key.session_manager_log_key.id

#     tags = {
#         Name = "session-manager-logs"
#     }
# }


# resource "aws_ssm_document" "update_default_session_manager_prefs" {
#   name            = "SSM-SessionManagerRunShell"
#   document_type   = "Command"

#   content = jsonencode({
#     schemaVersion = "1.0"
#     description = "Document to hold regional settings for Session Manager"
#     sessionType = "Standard_Stream"
#     inputs = {
#         s3BucketName = "${aws_s3_bucket.session_manager_logs0000.bucket}"
#         # s3BucketName = ""
#         s3KeyPrefix = ""
#         s3EncryptionEnabled = false
#         cloudWatchLogGroupName = "${aws_cloudwatch_log_group.session_manager_logs.name}"
#         # cloudWatchLogGroupName = ""
#         cloudWatchEncryptionEnabled = false
#         cloudWatchStreamingEnabled = true
#         idleSessionTimeout = "20"
#         maxSessionDuration = ""
#         # kmsKeyId = "${aws_kms_key.session_manager_log_key.id}"
#         kmsKeyId = ""
#         runAsEnabled = false
#         runAsDefaultUser = ""
#         shellProfile = {
#             windows = ""
#             linux = ""
#         }
#     }
#   })
# }
