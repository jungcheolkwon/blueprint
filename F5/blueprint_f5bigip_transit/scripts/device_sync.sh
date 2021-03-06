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
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

#waiting for asm provisioning
sleep 60

echo -e "\033[32m. Device syncing ....... \033[0m "
curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command":"run", "utilCmdArgs": "-c \"tmsh run cm config-sync to-group sync-group\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .

curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command":"run", "utilCmdArgs": "-c \"tmsh run cm config-sync to-group datasync-global-dg force-full-load-push\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .

curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command":"run", "utilCmdArgs": "-c \"tmsh yes\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .
# run cm config-sync to-group datasync-global-dg force-full-load-push with yes
echo -e "\033[32m ---------------------\033[0m "
