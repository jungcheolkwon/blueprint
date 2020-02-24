#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

#if [[ $# == 0 ]];
#then
#     echo -e "\033[92m-------------------------  How to use ---------------------------------------------\033[0m"
#     echo -e "\033[92m| ./provision_module.sh afm or asm                                                |\033[0m"
#     echo -e "\033[92m| You should type what you want to provision module name.                         |\033[0m" 
#     echo -e "\033[92m| Ex)./provision_module.sh afm or asm                                             |\033[0m"
#     echo -e "\033[92m-----------------------------------------------------------------------------------\033[0m"
#      exit 1;
#fi

name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)
module=asm

token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{ "name":"API_ASM_POLICY_TEST", "description":"Test ASM policy", "applicationLanguage":"utf-8", "type":"parent", "enforcementMode":"transparent", "protocolIndependent":"true", "learningMode":"disabled", "serverTechnologyName": "Unix/Linux" }' https://$ip:8443/mgmt/tm/$module/policies | jq -r .
