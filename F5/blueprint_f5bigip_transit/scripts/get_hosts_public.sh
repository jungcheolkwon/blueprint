#!/bin/bash

#edited by JC
#j.kwon@f5.com

dir=$(pwd)
prefix=$(cd /tf/caf/landingzones/landingzone_vdc_demo && terraform output prefix)
rg=$prefix-hub-network-transit

for i in ubuntu-transit-0 ubuntu-transit-1 ubuntu-transit-2
do 
        ip=$(az vm show -d -g $rg -n $i --query publicIps --out tsv)
        echo -e "\033[32m $i IP is $ip. \033[0m "
done
