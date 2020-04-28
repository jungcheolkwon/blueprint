#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

if [[ $# == 0 ]];
then
     echo -e "\033[92m-------------------------  How to use ---------------------------\033[0m"
     echo -e "\033[92m| policy_applyVS.sh is able to apply application security to VS  |\033[0m"
     echo -e "\033[92m| Ex)./policy_applyVS.sh add[del]                                |\033[0m"
     echo -e "\033[92m-----------------------------------------------------------------\033[0m"
     exit 1;
fi

name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP
hashp=$(cat hashp)
hashc=$(cat hashc)

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)
token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

if [ $1 == add ]
then
     echo -e "\033[32m..... Appying ASM Policy to VS ....... \033[0m "
     curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X PATCH --data-binary @VS.json https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

elif [ $1 == del ]
then
	echo -e "\033[32m.... Removing ASM Policy from VS ....... \033[0m "
	curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X PATCH --data-binary @VS.del.json https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .
fi