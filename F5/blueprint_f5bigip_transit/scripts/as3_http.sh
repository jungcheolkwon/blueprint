#!/bin/bash

#edited by JC
#j.kwon@f5.com

#https://github.com/F5Networks/terraform-provider-bigip/tree/master/examples/as3
#https://clouddocs.f5.com/products/big-iq/mgmt-api/v6.0/HowToSamples/bigiq_public_api_wf/t_bigiq_public_api_workflows.html
#https://clouddocs.f5.com/products/big-iq/mgmt-api/v6.0/ApiReferences/bigiq_public_api_ref/r_ip_pool_state.html

dir=$(pwd)
name="$(cat ~/.ssh/.user)"
password="$(cat ~/.ssh/.password)"

prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit

for i in bigip1-0 bigip2-0
do
    ip=$(az network public-ip show -n Azure-LB-Public-IP -g $rg --query ipAddress -o tsv)
    if [ $i == "bigip1-0" ]
    then
      #ip=$(az vm show -d -g $rg -n bigip1-0 --query publicIps -o tsv)
      #ip=$(az network public-ip show -n Azure-LB-Public-IP -g $rg --query ipAddress -o tsv)

      token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:8443/mgmt/shared/authn/login | jq -r .token.token)

      echo -e "\033[32m...Deploying HTTP Virtual Server and Pools $i ....... \033[0m "
      curl -k -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/as3_1.json https://$ip:8443/mgmt/shared/appsvcs/declare | jq -r .
    else
      #ip=$(az vm show -d -g $rg -n bigip2-0 --query publicIps -o tsv)

      token=$(curl -sk -H "Content-Type: application/json" -X POST -d '{"username":"'$name'","password":"'$password'","loginProviderName":"tmos"}' https://$ip:9443/mgmt/shared/authn/login | jq -r .token.token)

      echo -e "\033[32m...Deploying HTTP Virtual Server and Pools $i ....... \033[0m "
      curl -k -H "Content-Type: test/x-yaml" -H "X-F5-Auth-Token: $token" -X POST --data-binary @$dir/blueprint_f5bigip_transit/scripts/as3.json https://$ip:9443/mgmt/shared/appsvcs/declare | jq -r .
    fi
done
