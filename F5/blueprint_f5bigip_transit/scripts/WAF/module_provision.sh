#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

if [[ $# == 0 ]];
then
     echo -e "\033[92m--------------------  How to use ----------------------------------------\033[0m"
     echo -e "\033[92m| You should type what you want to provision module name.               |\033[0m" 
     echo -e "\033[92m| Ex)./module_provision.sh afm or asm                                   |\033[0m"
     echo -e "\033[92m-------------------------------------------------------------------------\033[0m"

     exit 1;
else
	module=$1

	#for bigip1
	echo -e "\033[32m ----- bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "nominal"}' https://$ip:8443/mgmt/tm/sys/provision/$module | jq -r .

	#for bigip2
	echo -e "\033[32m ----- bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)

	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "nominal"}' https://$ip:9443/mgmt/tm/sys/provision/$module | jq -r .
fi
