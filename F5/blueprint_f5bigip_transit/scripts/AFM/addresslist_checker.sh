#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module1/lab2.html

name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

	#for bigip1-0
	echo -e "\033[32m ----- bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/security/firewall/address-list | jq -r .

	 echo -e "\033[32m ----- bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/security/firewall/address-list | jq -r .
