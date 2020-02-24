#!/bin/bash 

#edited by JC
#j.kwon@f5.com

dir=$(pwd)
prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
lb_name=Azure-LB-Public-IP

for i in bigip1-0 bigip2-0
do 
  ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

  if [ $i == "bigip1-0" ]
  then
    echo -e "\033[32m.sync-group is configuring on $i \033[0m "
    $dir/blueprint_f5bigip_transit/scripts/sync1.sh "$ip"

  else
    echo -e "\033[32m.sync-group is configuring on $i \033[0m "
    $dir/blueprint_f5bigip_transit/scripts/sync2.sh "$ip"
fi
done

