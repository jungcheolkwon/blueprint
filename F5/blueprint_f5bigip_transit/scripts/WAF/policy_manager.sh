#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module2/lab2.html

if [[ $# == 0 ]];
then
     echo -e "\033[92m-------------------------  How to use ---------------------------------------------\033[0m"
     echo -e "\033[92m| policy_manager.sh is able to create/delete/check parent&child policy            |\033[0m"
     echo -e "\033[92m| You should type what you want to do like parent, child, checkc[p], delc[p]      |\033[0m" 
     echo -e "\033[92m| Ex)./policy_manager.sh parent/child/checkp/checkc/delp/delc                     |\033[0m"
     echo -e "\033[92m-----------------------------------------------------------------------------------\033[0m"
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

if [ $1 == parent ]
then
        echo -e "\033[32m..... Creating ASM Parent Policy ....... \033[0m "
	curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @parent_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r .
	./phash.sh

elif [ $1 == checkp ]
then
	echo -e "\033[32m.... Retrieving an ASM Parent Policy ....... \033[0m "
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies/$hashp | jq -r .

elif [ $1 == child ]
then
        echo -e "\033[32m..... Creating ASM Child Policy ....... \033[0m "
	curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @child_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r . > forchildhash
	./chash.sh

elif [ $1 == checkc ]
then
        echo -e "\033[32m.... Retrieving an ASM Parent Policy ....... \033[0m "
        curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

elif [ $1 == delp ]
then
        echo -e "\033[32m.... Deleting ASM Parent Policy ....... \033[0m "
        curl -sk -H "X-F5-Auth-Token: $token" -X DELETE https://$ip:8443/mgmt/tm/asm/policies/$hashp | jq -r .

elif [ $1 == delc ]
then
        echo -e "\033[32m.... Deleting ASM Child Policy ....... \033[0m "
        curl -sk -H "X-F5-Auth-Token: $token" -X DELETE https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

fi
