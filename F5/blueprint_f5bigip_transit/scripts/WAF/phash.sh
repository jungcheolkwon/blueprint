#!/bin/bash

#edited by JC
#j.kwon@f5.com

name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"


prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

#curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies | jq -r .items[].generalReference | awk -F ":" '{print $3}' | awk -F "/" '{print $8}' > hashp
curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies | jq -r .items[].id > hashp

#sed -i '1d;$d' hashp
