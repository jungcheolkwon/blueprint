#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://clouddocs.f5.com/training/community/programmability/html/class3/module1/lab2.html

if [ $# == 0 ]
then
     echo -e "\033[92m---------------------  How to use ------------------------------\033[0m"
     echo -e "\033[92m| You should type what you want to deploy policy file           |\033[0m" 
     echo -e "\033[92m| Ex)./afm_manager.sh module[policy/check]                      |\033[0m"
     echo -e "\033[92m| Ex)./afm_manager.sh module enable[disable] afm[asm]           |\033[0m"
     echo -e "\033[92m| Ex)./afm_manager.sh policy add[del]                           |\033[0m"
     echo -e "\033[92m| Ex)./afm_manager.sh check module[policy]                      |\033[0m"
     echo -e "\033[92m| Ex)./afm_manager.sh check module or [afm/asm]                 |\033[0m"
     echo -e "\033[92m| Ex)./afm_manager.sh check policy                              |\033[0m"
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
#if [ $1 == module ]
if ( [[ "$1" = "module" ]] && [[ "$2" = "enable" ]] )
then
  #if [ $2 == enable ]
  #then
	module=$3
	#for bigip1
	echo -e "\033[32m ----- $3 enable at bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "nominal"}' https://$ip:8443/mgmt/tm/sys/provision/$module | jq -r .

	#for bigip2
	echo -e "\033[32m ----- $3 enable at bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "nominal"}' https://$ip:9443/mgmt/tm/sys/provision/$module | jq -r .

 # elif [ $2 == disable ]
elif ( [[ "$1" = "module" ]] && [[ "$2" = "disable" ]] )
then
  module=$3
  #for bigip1
  echo -e "\033[32m ----- $3 disable at bigip1-0 ------\033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "none"}' https://$ip:8443/mgmt/tm/sys/provision/$module | jq -r .

  #for bigip2
  echo -e "\033[32m ----- $3 disable at bigip2-0 ------\033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X PATCH -d '{"level": "none"}' https://$ip:9443/mgmt/tm/sys/provision/$module | jq -r .
 # fi

elif ( [[ "$1" = "policy" ]] && [[ "$2" = "add" ]] )
then
  echo -e "\033[32mDeploying AFM policy at bigip1-0 ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
  echo -e "\033[32m ---------------------\033[0m "

  echo -e "\033[32mDeploying AFM policy at bigip2-0 ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
  echo -e "\033[32m ---------------------\033[0m "

elif ( [[ "$1" = "policy" ]] && [[ "$2" = "del" ]] )
then
	echo -e "\033[32mDeleting AFM Policy at bigip1-0 ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.rm.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .

	echo -e "\033[32mDeleting AFM Policy at bigip2-0 ....... \033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @afm.rm.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "policy" ]] )
then
  echo -e "\033[32m ----- bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/security/firewall/policy | jq -r .

	echo -e "\033[32m ----- bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/security/firewall/policy | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "module" ]] && [[ "$3" = "" ]] )
then
	#for bigip1
	echo -e "\033[32m ----- all enabled module at bigip1-0 -------------------------\033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/sys/provision | jq -r .

	#for bigip2
	echo -e "\033[32m ----- all enabled module at bigip2-0 -------------------------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/sys/provision | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "module" ]] && ([[ "$3" = "afm" ]] || [[ "$3" = "asm" ]] || [[ "$3" = "ltm" ]] || [[ "$3" = "gtm" ]] || [[ "$3" = "pem" ]] || [[ "$3" = "sslo" ]] || [[ "$3" = "swg" ]] || [[ "$3" = "apm" ]]) )
then
  #for bigip1
  echo -e "\033[32m ----- $3 status at bigip1-0 ------\033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/sys/provision/$3 | jq -r .

	#for bigip2
	echo -e "\033[32m ----- $3 status at bigip2-0 ------\033[0m "
  token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
  curl -sk -H "Content-Type: application/json" -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/sys/provision/$3 | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "address-list" ]] )
then
  #for bigip1-0
	echo -e "\033[32m ----- bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/security/firewall/address-list | jq -r .

  echo -e "\033[32m ----- bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/security/firewall/address-list | jq -r .

elif ( [[ "$1" = "check" ]] && [[ "$2" = "rules" ]] )
then
  policy=$3
  #for bigip1-0
	echo -e "\033[32m ----- $3's rules at bigip1-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:8443/mgmt/tm/security/firewall/policy/$policy/rules | jq -r .

  #for bigip2-0
  echo -e "\033[32m ----- $3's rules at bigip2-0 ------\033[0m "
	token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)
	curl -sk -H "X-F5-Auth-Token: $token" -X GET https://$ip:9443/mgmt/tm/security/firewall/policy/$policy/rules | jq -r .

fi
