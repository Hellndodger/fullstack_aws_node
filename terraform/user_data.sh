#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

docker run -d -p 3000:3000 hellndodger/aws:latest
