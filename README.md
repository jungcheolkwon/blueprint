# blueprint
This module is for F5 BIG-IP integrate to Microsoft Landingzone.

# Prerequisites
First of all, you need to install docker and Visual Studio Code( on your local laptop with this guide( https://github.com/aztfmod/rover ).

# Download source files (your local laptop)
Then download Azure landingzone source files from here( https://github.com/aztfmod ) with this module.
Move to your local directory where you want to download them. Example will use /Users/F5_user/Docker

```sh
$ cd ~/Docker
$ git clone https://github.com/aztfmod/landingzones.git
$ cd landingzones/landingzones/landingzone_vdc_demo/
$ git clone https://github.com/jungcheolkwon/blueprint.git
```

# Build landingzone with BIG-IP (in rover container)
After download the source files, open workspace from VSC.
You can see bash prompt after rover container is up then move to blueprint directory.
run the copytoeach.sh script and if you see the 'Enter admin password for BIG-IP' message, type your password.

```sh
$ cd /tf/caf/landingzones/landingzone_vdc_demo/blueprint
$ ./copytoeach.sh
$ rover login
$ launchpad /tf/launchpads/launchpad_opensource_light apply 
$ rover /tf/caf/landingzones/landingzone_caf_foundations apply
$ rover /tf/caf/landingzones/landingzone_vdc_demo apply
```

# Configure BIG-IP (in rover container)
Change the file "bigip_post.tf0" to "bigip_post.tf" via command or in VSC then run rover again

```sh
$ cd /tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts
$ mv bigip_post.tf0 bigip_post.tf
$ rover /tf/caf/landingzones/landingzone_vdc_demo apply
```

# Destroy landingzone (in rover container)
```sh
$ rover /tf/caf/landingzones/landingzone_vdc_demo destroy -force
$ rover /tf/caf/landingzones/landingzone_caf_foundations destroy -forc
```
