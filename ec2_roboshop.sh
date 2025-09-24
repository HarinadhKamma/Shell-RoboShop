#!/bin/bash

ami_id="ami-09c813fb71547fc4f"
sg_id="sg-03fb0717f5b080d3c"
zone_id="Z0584855OLUDIFKCOOVC"
record_name="haridevops.shop"

for instance in $@
do 
    instance_id=$(aws ec2 run-instances --image-id $ami_id --instance-type t3.micro --security-group-ids $sg_id  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]"  --query 'Instances[0].InstanceId' --output text)
     
    if [ $instance != "frontend" ];then
        ip=$(aws ec2 describe-instances  --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        ip=$(aws ec2 describe-instances  --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
      echo "$instance: $ip"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $zone_id \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$record_name'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$ip'"
            }]
        }
        }]
    }
    '
done