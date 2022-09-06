#!/bin/sh


#to get meta-data information
curl http://169.254.169.254/latest/meta-data/ 



Examples:
InstanceID=$(curl -sL http://169.254.169.254/latest/meta-data/instance-id)
AMI_used=$(curl -sL http://169.254.169.254/latest/meta-data/ami-id)
SG_attached=$(curl -sL http://169.254.169.254/latest/meta-data/security-groups)
privateIP=$(curl -sL http://169.254.169.254/latest/meta-data/local-ipv4)


echo "The Instance id is: "${InstanceID}"."
echo "The ami-id is: "${AMI_used}"."
echo "The security-groups are: "${SG_attached}"."
echo "The local-ip is: "${privateIP}"."