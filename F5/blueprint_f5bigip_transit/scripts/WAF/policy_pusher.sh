#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

#prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

if [[ $# == 0 ]];
then
     echo -e "\033[92m---------------------  How to use ------------------------------\033[0m"
     echo -e "\033[92m| You should type what you want to deploy policy file           |\033[0m" 
     echo -e "\033[92m| Ex)./policy_pusher.sh afm.json or asm.json                    |\033[0m"
     echo -e "\033[92m----------------------------------------------------------------\033[0m"
  exit 1;
else
    echo -e "\033[32m...Deploying $1 policy at bigip1-0....... \033[0m "
    token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
     curl -k -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$1 https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
    echo -e "\033[32m ---------------------\033[0m "

   echo -e "\033[32m...Deploying $1 policy at bigip2-0....... \033[0m "
   token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
   curl -k -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$1 https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
    echo -e "\033[32m ---------------------\033[0m "

fi
