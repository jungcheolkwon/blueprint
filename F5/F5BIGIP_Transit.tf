module "f5bigip" {
  source  = "./blueprint_f5bigip_transit"

resource_group_name       = module.blueprint_networking_shared_transit.resource_group["HUB-NET-TRANSIT"]
location                  = local.global_settings.location_map["region1"]
tags                      = local.global_settings.tags_hub
virtual_network_name      = var.networking_transit.vnet.name
subnet_id                 = module.blueprint_networking_shared_transit.networking_transit_vnet_subnets["NetworkMonitoring"]
network_security_group_id = module.blueprint_networking_shared_transit.networking_transit_vnet_nsg["NetworkMonitoring"]
}
