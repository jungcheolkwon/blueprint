#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

echo -e "\033[32m..... Creating ASM Parent Policy ....... \033[0m "
curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/parent_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r .id > $dir/blueprint_f5bigip_transit/scripts/hashp
sleep 3

echo -e "\033[32m..... Creating ASM Child Policy ....... \033[0m "
curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/child_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r .id > $dir/blueprint_f5bigip_transit/scripts/hashc
sleep 5