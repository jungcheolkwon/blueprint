# blueprint
This module is for F5 BIG-IP integrate to Microsoft Cloud Adoption Framework(Landingzones) for Azure.
It means that most of variables and modules are depended on Landingzones modules so it might be not working if landingzones modules are updated.
You may have issues when you try to test if landingzones module has updated or modified.

# Prerequisites
First of all, you need to install docker and Visual Studio Code( on your local laptop with this guide( https://github.com/aztfmod/rover ).

# Download source files (your local laptop)
Then download Azure landingzone source files from here( https://github.com/aztfmod ) with this module( git@github.com:jungcheolkwon/blueprint.git ).
Move to your local directory where you want to download them. Example will use /Users/F5_user/Docker

```sh
$ cd ~/Docker
$ git clone https://github.com/Azure/caf-terraform-landingzones.git
$ cd landingzones/landingzones/landingzone_vdc_demo/
$ git clone https://github.com/jungcheolkwon/blueprint.git
```

# Build landingzone with BIG-IP (in rover container)
After download the source files, open workspace from VSC.
![example](https://github.com/jungcheolkwon/blueprint/blob/master/images/openworkspace0.png)<br>
![example](https://github.com/jungcheolkwon/blueprint/blob/master/images/openworkspace1.png)
You can see bash prompt after rover container is up then move to blueprint directory.
![example](https://github.com/jungcheolkwon/blueprint/blob/master/images/broughtup-docker.png)
![example](https://github.com/jungcheolkwon/blueprint/blob/master/images/movedtovdc-demo.png)
run the copytoeach.sh script and if you see the 'Enter admin password for BIG-IP' message, type your BIGIP admin password.
![example](https://github.com/jungcheolkwon/blueprint/blob/master/images/runcopy.png)
You need to login your Azure account with rover login and you will see your account info after run the command.
After finish login, you need to run launchpad(https://github.com/aztfmod/level0/tree/master/launchpads/launchpad_opensource_light) command to manage the foundations of landing zone environnement like:
 - Secure remote Terraform states storage for multiple subscriptions.
 - Managing the transition from manual to automation environnement.<br><br>

Azure Cloud Adoption Framework landingzones detail documents are here(https://github.com/Azure/caf-terraform-landingzones/tree/master/documentation)
Next, you need to run rover landingzone_caf_foundations to  sets the basics of operations, accounting and auditing and security for a subscription.
The last step in this stage, you need to run rover landingzone_vdc_demo to bring up demo environment with BIG-IP in the environment.


```sh
$ cd /tf/caf/landingzones/landingzone_vdc_demo/blueprint
$ ./copytoeach.sh
$ rover login
$ launchpad /tf/launchpads/launchpad_opensource_light apply [-var 'location=southeastasia']
$ rover /tf/caf/landingzones/landingzone_caf_foundations apply
$ rover /tf/caf/landingzones/landingzone_vdc_demo apply
```

# Configure BIG-IP (in rover container)
You need to change the file "bigip_post.tf0" to "bigip_post.tf" via mv command or in VSC then run rover again
At this step, BIG-IP user's password will be changed and sync-group, install AS3 rpm, create VS and pool with members, afm/asm provisioned, awaf policy will be pushed then ready to service

```sh
$ cd /tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts
$ mv bigip_post.tf0 bigip_post.tf
$ rover /tf/caf/landingzones/landingzone_vdc_demo apply
```

# Check Service and Policy
You can test service with curl command and see the applied policy with API command

```sh
$ curl http://test-domain
$ policy_cheker.sh

```

# Destroy landingzone (in rover container)
```sh
$ rover /tf/caf/landingzones/landingzone_vdc_demo destroy -force
$ rover /tf/caf/landingzones/landingzone_caf_foundations destroy -force
```
