#!/bin/bash

# 로그 파일 설정 및 초기화
LOG_FILE="/var/log/user-data.log"
echo "User Data script started at $(date)" > $LOG_FILE

#시스템 업데이트
sudo apt-get update -y && sudo apt-get upgrade -y

# docker 설치
## 필수 패키지 설치
sudo apt-get install -y apt-transport-https ca-certificates 
	curl software-properties-common
## docker GPG 키 시스템에 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
## docker 레파지토리 추가
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
## docker 설치
sudo apt-get update
sudo apt install -y docker-ce

# Aws cli설치
if ! command -v aws &> /dev/null
then
  curl "https://awscli.amazonaws.com/aws-cli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

#cloudwatch 설치
echo "Installing cloudwatch Agent..." >> $LOG_FILE 2>&1echo "Step 1: Installing Ruby and Wget..." >> $LOG_FILE 2>&1
sudo yum install -y amazon-cloudwatch-agent >> $LOG_FILE 2>&1

echo "Installing AWS CodeDeploy Agent..." >> $LOG_FILE 2>&1
echo "Step 1: Installing Ruby and Wget..." >> $LOG_FILE 2>&1
sudo apt-get install -y ruby wget >> $LOG_FILE 2>&1
echo "Step 2: Changing directory to /home/ubuntu..." >> $LOG_FILE 2>&1
cd /home/ubuntu >> $LOG_FILE 2>&1
echo "Step 3: Downloading CodeDeploy install script..." >> $LOG_FILE 2>&1
wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install >> $LOG_FILE 2>&1
echo "Step 4: Setting execute permissions for the install script..." >> $LOG_FILE 2>&1
chmod +x ./install >> $LOG_FILE 2>&1
echo "Step 5: Running the install script..." >> $LOG_FILE 2>&1
sudo ./install auto >> $LOG_FILE 2>&1
echo "Step 6: Starting the CodeDeploy agent..." >> $LOG_FILE 2>&1
sudo systemctl start codedeploy-agent >> $LOG_FILE 2>&1
echo "Step 7: Enabling the CodeDeploy agent to start on boot..." >> $LOG_FILE 2>&1
sudo systemctl enable codedeploy-agent >> $LOG_FILE 2>&1
echo "AWS CodeDeploy Agent installation completed." >> $LOG_FILE 2>&1
