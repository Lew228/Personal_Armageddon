#!/bin/bash
dnf update -y
dnf install -y python3 python3-pip git
pip3 install flask pymysql boto3