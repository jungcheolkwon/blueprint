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
token2=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)

if ( [[ "$1" = "module" ]] && [[ "$2" = "enable" ]] )
then
  module=$3
  #for bigip1
  echo -e "\033[32m ----- $3 enable at bigip1-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "nominal"}' https://$ip:8443/mgmt/tm/sys/provision/$module | jq -r .

  #for bigip2
  echo -e "\033[32m ----- $3 enable at bigip2-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token2" -X PATCH -d '{"level": "nominal"}' https://$ip:9443/mgmt/tm/sys/provision/$module | jq -r .

elif ( [[ "$1" = "module" ]] && [[ "$2" = "disable" ]] )
then
  module=$3
  #for bigip1
  echo -e "\033[32m ----- $3 disable at bigip1-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "none"}' https://$ip:8443/mgmt/tm/sys/provision/$module | jq -r .

  #for bigip2
  echo -e "\033[32m ----- $3 disable at bigip2-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token2" -X PATCH -d '{"level": "none"}' https://$ip:9443/mgmt/tm/sys/provision/$module | jq -r .

elif ( [[ "$1" = "create" ]] && [[ "$2" = "parent" ]] )
then
  #for bigip1
  echo -e "\033[32m..... Creating ASM Parent Policy at bigip1-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @parent_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r .
  ./phash.sh

  #for bigip2
  echo -e "\033[32m..... Creating ASM Parent Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token2" -X POST --data-binary @parent_policy.json https://$ip:9443/mgmt/tm/asm/policies | jq -r .

elif ( [[ "$1" = "create" ]] && [[ "$2" = "child" ]] )
then
  #for bigip1
  echo -e "\033[32m..... Creating ASM Child Policy at bigip1-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @child_policy.json https://$ip:8443/mgmt/tm/asm/policies | jq -r . > forchildhash
  ./chash.sh

  #for bigip2
  echo -e "\033[32m..... Creating ASM Child Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token2" -X POST --data-binary @child_policy.json https://$ip:9443/mgmt/tm/asm/policies | jq -r . > forchildhash

elif ( [[ "$1" = "delete" ]] && [[ "$2" = "parent" ]] )
then
  #for bigip1
  echo -e "\033[32m.... Deleting ASM Parent Policy at bigip1-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token" -X DELETE https://$ip:8443/mgmt/tm/asm/policies/$hashp | jq -r .

  #for bigip2
  echo -e "\033[32m.... Deleting ASM Parent Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token2" -X DELETE https://$ip:9443/mgmt/tm/asm/policies/$hashp | jq -r .
  
elif ( [[ "$1" = "delete" ]] && [[ "$2" = "child" ]] )
then
  #for bigip1
  echo -e "\033[32m.... Deleting ASM Child Policy at bigip1-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token" -X DELETE https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

  #for bigip2
  echo -e "\033[32m.... Deleting ASM Child Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token2" -X DELETE https://$ip:9443/mgmt/tm/asm/policies/$hashc | jq -r .
  
elif ( [[ "$1" = "delete" ]] && [[ "$2" = "vs" ]] )
then
  #for bigip1
  echo -e "\033[32m.... Deleting ASM Policy from VS at bigip1-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X PATCH --data-binary @VS.del.json https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

  #for bigip2
  echo -e "\033[32m.... Deleting ASM Policy from VS at bigip2-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token2" -X PATCH --data-binary @VS.del.json https://$ip:9443/mgmt/tm/asm/policies/$hashc | jq -r .
  
elif ( [[ "$1" = "apply" ]] && [[ "$2" = "vs" ]] )
then
  #for bigip1
  echo -e "\033[32m..... Appying ASM Policy to VS at bigip1-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X PATCH --data-binary @VS.json https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

  #for bigip2
  echo -e "\033[32m..... Appying ASM Policy to VS at bigip2-0 ....... \033[0m "
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token2" -X PATCH --data-binary @VS.json https://$ip:9443/mgmt/tm/asm/policies/$hashc | jq -r .
  
elif ( [[ "$1" = "check" ]] && [[ "$2" = "parent" ]] )
then
  #for bigip1
  echo -e "\033[32m.... Retrieving an ASM Parent Policy at bigip1-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies/$hashp | jq -r .

  #for bigip2
  echo -e "\033[32m.... Retrieving an ASM Parent Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token2" -X GET https://$ip:9443/mgmt/tm/asm/policies/$hashp | jq -r .
  
elif ( [[ "$1" = "check" ]] && [[ "$2" = "child" ]] )
then
  #for bigip1
  echo -e "\033[32m.... Retrieving an ASM Child Policy at bigip1-0....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/asm/policies/$hashc | jq -r .

  #for bigip2
  echo -e "\033[32m.... Retrieving an ASM Child Policy at bigip2-0 ....... \033[0m "
  curl -sk -H "X-F5-Auth-Token: $token2" -X GET https://$ip:9443/mgmt/tm/asm/policies/$hashc | jq -r .
  
elif ( [[ "$1" = "check" ]] && [[ "$2" = "module" ]] && [[ "$3" = "" ]] )
then
  #for bigip1
  echo -e "\033[32m ----- all enabled module at bigip1-0 -------------------------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/sys/provision | jq -r .

  #for bigip2
  echo -e "\033[32m ----- all enabled module at bigip2-0 -------------------------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token2" -X GET https://$ip:9443/mgmt/tm/sys/provision | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "module" ]] && ([[ "$3" = "afm" ]] || [[ "$3" = "asm" ]] || [[ "$3" = "ltm" ]] || [[ "$3" = "gtm" ]] || [[ "$3" = "pem" ]] || [[ "$3" = "sslo" ]] || [[ "$3" = "swg" ]] || [[ "$3" = "apm" ]]) )
then
  #for bigip1
  echo -e "\033[32m ----- $3 status at bigip1-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/sys/provision/$3 | jq -r .

  #for bigip2
  echo -e "\033[32m ----- $3 status at bigip2-0 ------\033[0m "
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token2" -X GET https://$ip:9443/mgmt/tm/sys/provision/$3 | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "web" ]] )
then
  #for bigip1
	echo -e "\033[32m ----- Checking LTM ASM Profile Web Security at bigip1-0 ----\033[0m "
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/ltm/profile/web-security | jq -r .

  #for bigip2
	echo -e "\033[32m ----- Checking LTM ASM Profile Web Security at bigip2-0 ----\033[0m "
	curl -sk -H "X-F5-Auth-Token: $token2" -X GET https://$ip:9443/mgmt/tm/ltm/profile/web-security | jq -r .

fi
