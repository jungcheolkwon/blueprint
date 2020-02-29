resource "null_resource" "bigip_post" {

#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/getip-ch-pwd.sh"
#  }
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/sync-group.sh"
#  }
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/install_as3.rpm.sh"
#  } 
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/as3_http.sh"
#  } 
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/afm_provision.sh"
#  } 
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/upload_index.sh"
#  } 
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/asm_provision.sh"
#  } 
#
#  provisioner "local-exec" {
#    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/policy_push_parenet_child.sh"
#  } 

  provisioner "local-exec" {
    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/policy_push_vs.sh"
  } 

  provisioner "local-exec" {
    command = "/tf/caf/landingzones/landingzone_vdc_demo/blueprint_f5bigip_transit/scripts/policy_push_afm.sh"
  } 

}
