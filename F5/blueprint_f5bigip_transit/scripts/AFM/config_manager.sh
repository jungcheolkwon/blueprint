#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module1/lab2.html

if [ $# == 0 ]
then
     echo -e "\033[92m---------------------  How to use ------------------------------\033[0m"
     echo -e "\033[92m| You should type what you want to deploy policy file           |\033[0m" 
     echo -e "\033[92m| Ex)./policy_pusher.sh afm.json or asm.json                    |\033[0m"
     echo -e "\033[92m----------------------------------------------------------------\033[0m"
  exit 1;
fi

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

if [ $1 == add ]
then

  echo -e "\033[32mDeploying AFM policy at bigip1-0....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
  echo -e "\033[32m ---------------------\033[0m "

  echo -e "\033[32mDeploying AFM policy at bigip2-0....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
  echo -e "\033[32m ---------------------\033[0m "

elif [ $1 == del ]
then
	echo -e "\033[32m.... Deleting AFM Policy ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
  #curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.rm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
  #curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command": "run", "utilCmdArgs": "-c \"rm /partitions/Sample_net_sec_01\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .
  #curl -sk -H "X-F5-Auth-Token: $token" -H "Content-Type: application/json" -X DELETE https://$ip:8443/mgmt/tm/security/firewall/policy/Sample_net_sec_01/fwFastL4/fwPolicy  | jq -r . 
  #curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.rm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .

	echo -e "\033[32m.... Deleting AFM Policy ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  #curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command": "run", "utilCmdArgs": "-c \"rm /partitions/Sample_net_sec_01\""}' https://$ip:9443/mgmt/tm/util/bash | jq -r .
  #curl -sk -H "X-F5-Auth-Token: $token" -H "Content-Type: application/json" -X DELETE https://$ip:9443/mgmt/tm/security/firewall/policy/Sample_net_sec_01/fwFastL4/fwPolicy  | jq -r .
  #curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.rm.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X POST -d '{"command":"run", "utilCmdArgs": "-c \"tmsh run cm config-sync to-group sync-group\""}' https://$ip:8443/mgmt/tm/util/bash | jq -r .

fi
