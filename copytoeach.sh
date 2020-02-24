#!/bin/bash

cat output.tf.transit >> ../blueprint_networking_shared_transit/output.tf 
cat blueprint.tf.transit >> ../blueprint_networking_shared_transit/blueprint.tf
cp blueprint_networking_shared_transit.sandpit.auto.tfvars ../
cp F5/F5BIGIP_Transit.tf ../
cp -r F5/blueprint_f5bigip_transit ../

cp F5/F5BIGIP_Member_Transit.tf ../
cp -r F5/blueprint_f5bigip_members_transit ../

sudo yum install -y expect

#echo -e "\033[36mEnter your user name for BIG-IP.\033[m"
#read -s user
#echo "$user" > ~/.ssh/.user
echo "admin" > ~/.ssh/.user
echo "------------------------------------"
echo -e "\033[36mEnter admin password for BIG-IP.\033[m"
read -s password
echo "$password" > ~/.ssh/.password


