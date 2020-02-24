#!/bin/bash 

#edited by JC
#j.kwon@f5.com

dir=$(pwd)
prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit
echo "$prefix" > /tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/prefix
lb_name=Azure-LB-Public-IP

for i in bigip1-0 bigip2-0
do 
  ip=$(az network public-ip show -n $lb_name -g $rg --query ipAddress -o tsv)

  if [ $i == "bigip1-0" ]
  then
	echo -e "\033[32m starting script for $i's user password updating \033[0m "
	$dir/blueprint_f5bigip_transit/scripts/ch_pwd.sh $ip

	echo -e "\033[32m $i's user password is just updated. \033[0m "
  else
	echo -e "\033[32m starting script for $i's user password updating \033[0m "
	$dir/blueprint_f5bigip_transit/scripts/ch_pwd2.sh $ip

	echo -e "\033[32m $i's user password is just updated. \033[0m "
fi
done

