#!/bin/bash
DOCKER_IMAGE="/tmp/dockerimg-`date +%F`.tgz"
WORKSPACE="/var/lib/jenkins/workspace/Alpha-Sankatmochan"
cd $WORKSPACE
git checkout $GIT_TAG
sudo docker build -t boutiqaat/sankatmochan:$GIT_TAG .
sudo rm -rf $DOCKER_IMAGE
sudo docker save -o $DOCKER_IMAGE boutiqaat/sankatmochan:$GIT_TAG
sudo chmod a+r $DOCKER_IMAGE
/bin/echo $DOCKER_IMAGE
/bin/echo $GIT_TAG > /var/lib/jenkins/workspace/sankatmochan_tag.txt
for server in `echo $Server_IP |awk -F, '{for(i=1;i<=NF;i++){ print $i;}}'`
do
scp -o StrictHostKeyChecking=no $DOCKER_IMAGE /var/lib/jenkins/workspace/sankatmochan_tag.txt ec2-user@$server:/tmp
ssh -o StrictHostKeyChecking=no ec2-user@$server 'docker load -i /tmp/dockerimg-`date +%F`.tgz;rm -f /tmp/dockerimg-`date +%F`.tgz'
ssh -o StrictHostKeyChecking=no ec2-user@$server 'sh /etc/boutiqaat/sankatmochan/container.start'
done

##