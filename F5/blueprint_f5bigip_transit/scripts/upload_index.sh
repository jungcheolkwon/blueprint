#!/bin/bash

#edited by JC
#j.kwon@f5.com

dir=$(pwd)
prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit

for i in ubuntu-transit-0 ubuntu-transit-1 ubuntu-transit-2
do
        ip=$(az vm show -d -g $rg -n $i --query publicIps -o tsv)
  if [ $i == ubuntu-transit-0 ]
  then
        sed -i 's/WebServer[0-9]!!/WebServer1!!/g' $dir/blueprint_f5bigip_transit/scripts/index.html
        cat $dir/blueprint_f5bigip_transit/scripts/index.html | ssh -o StrictHostKeyChecking=no azureuser@$ip "sudo tee /usr/share/nginx/html/index.html"
  elif [ $i == ubuntu-transit-1 ]
  then
        sed -i 's/WebServer[0-9]!!/WebServer2!!/g' $dir/blueprint_f5bigip_transit/scripts/index.html
        cat $dir/blueprint_f5bigip_transit/scripts/index.html | ssh -o StrictHostKeyChecking=no azureuser@$ip "sudo tee /usr/share/nginx/html/index.html"
  else
        sed -i 's/WebServer[0-9]!!/WebServer3!!/g' $dir/blueprint_f5bigip_transit/scripts/index.html
        cat $dir/blueprint_f5bigip_transit/scripts/index.html | ssh -o StrictHostKeyChecking=no azureuser@$ip "sudo tee /usr/share/nginx/html/index.html"
  fi
done
