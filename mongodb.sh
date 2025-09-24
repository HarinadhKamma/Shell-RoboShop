#!/bin/bash

#Red is for ERROR
#Green is for success
#yellow is for skip

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder="/var/log/shell-roboshop"
script_name=$( echo $0 | cut -d "." -f1)
log_file="$logs_folder/$script_name.log"

mkdir -p $logs_folder
echo "script started executing"

#userid=$(id -u)
if [ $(id -u) -ne 0 ]; then
    echo "user don't have root access to install"
    exit 1
fi

 # functions receive inputs through args just like shell script args
validate(){
    if [ $1 -eq 0 ];then
    echo -e " $2.... $G is Success $N"
else
   echo -e " $2.... $R is Fail $N"
   exit 1
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate ?$ "Adding mongo repo"
dnf install mongodb-org -y &>> $log_file
validate ?$ "installing mongodb" 
systemctl enable mongod 
validate ?$ "enable mongodb"
systemctl start mongod 
validate ?$ "start mongodb"

