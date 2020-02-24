
## Create step ##
1. rover login
2. launchpad /tf/launchpads/launchpad_opensource_light apply 

3. rover /tf/caf/landingzones/landingzone_caf_foundations apply

4. rover /tf/caf/landingzones/landingzone_vdc_demo apply

5. cd landingzones/landingzone_vdc_demo/
6. git clone https://github.com/jungcheolkwon/blueprint.git

7. cd blueprint
8. ./copytoeach.sh 
9. cd ../blueprint_f5bigip_transit/scripts/

## Destroy step ##
1. rover /tf/caf/landingzones/landingzone_vdc_demo destroy -force
2. rover /tf/caf/landingzones/landingzone_caf_foundations destroy -force
