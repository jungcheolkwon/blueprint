#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module1/lab2.html

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

echo -e "\033[32mDeploying afm policy at bigip1-0 ....... \033[0m "
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/afm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
#curl -k -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/afm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
echo -e "\033[32m ---------------------\033[0m "
echo -e "\033[32mDeploying afm policy at bigip1-0 ....... \033[0m "
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/afm.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
echo -e "\033[32m ---------------------\033[0m "

echo -e "\033[32m. Device syncing ....... \033[0m "
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command":"run", "utilCmdArgs": "-c \"tmsh run cm config-sync to-group sync-group\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .
echo -e "\033[32m ---------------------\033[0m "