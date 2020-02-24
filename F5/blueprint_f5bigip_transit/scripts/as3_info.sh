#!/bin/bash

#edited by JC
#j.kwon@f5.com

dir=$(pwd)
name=$(cat ~/.ssh/.user)
password=$(cat ~/.ssh/.password)

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit


for i in bigip1-0 bigip2-0
do 
  if [ $i == "bigip1-0" ]
  then
	echo -e "\033[32m bigip1-0 -------------------------\033[0m "
        ip=$(az vm show -d -g $rg -n $i --query publicIps -o tsv)

        token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

        curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET  https://$ip:8443/mgmt/shared/appsvcs/info | jq -r .
  else
	echo ""
	echo -e "\033[32m bigip2-0 -------------------------\033[0m "
        ip=$(az vm show -d -g $rg -n $i --query publicIps -o tsv)
        token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

        curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET  https://$ip:8443/mgmt/shared/appsvcs/info | jq -r .
fi
done
