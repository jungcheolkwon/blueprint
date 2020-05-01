#!/bin/bash -x

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

dir=$(pwd)
echo "$dir"
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP
hashc=$(cat $dir/blueprint_f5bigip_transit/scripts/hashc)

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
token2=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)

echo -e "\033[32mAppying ASM Policy to VS bigip1-0 ....... \033[0m "
curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X PATCH --data-binary @$dir/blueprint_f5bigip_transit/scripts/VS.json.org https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

#echo -e "\033[32mAppying ASM Policy to VS bigip2-0 ....... \033[0m "
#curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token2" -X PATCH --data-binary @$dir/blueprint_f5bigip_transit/scripts/VS.json.org https://$ip:9443/mgmt/tm/asm/policies/$hashc | jq -r .
