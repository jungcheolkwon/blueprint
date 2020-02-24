#https://github.com/Azure/terraform-azurerm-loadbalancer
#https://www.terraform.io/docs/providers/azurerm/r/loadbalancer_rule.html

resource "azurerm_public_ip" "lb_f5" {
  name                  = "Azure-LB-Public-IP"
  allocation_method     = var.public_ip_address_allocation
  resource_group_name   = var.resource_group_name
  location              = var.location
  tags                  = var.tags
}

resource "azurerm_lb" "lb_f5" {
  name                  = "AzureLoadBalancer"
  location              = var.location
  resource_group_name   = var.resource_group_name
  tags                  = var.tags

  frontend_ip_configuration {
      name                 = "lb_vip"
      public_ip_address_id = azurerm_public_ip.lb_f5.id
  }
}

resource "azurerm_lb_probe" "probe" {
  resource_group_name   = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb_f5.id
  name                = "HTTP-PROBE"
  port                = 80
}

resource "azurerm_lb_rule" "rules" {
  resource_group_name   = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb_f5.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.F5.id
  frontend_ip_configuration_name = "lb_vip"
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_lb_backend_address_pool" "F5" {
  resource_group_name       = var.resource_group_name
  loadbalancer_id           = azurerm_lb.lb_f5.id
  name                = "BackendPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "F5" {
  network_interface_id    = element(azurerm_network_interface.F5.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5[0].ip_configuration.*.name,0)
  backend_address_pool_id = azurerm_lb_backend_address_pool.F5.id
}

resource "azurerm_network_interface_backend_address_pool_association" "F5n" {
  network_interface_id = element(azurerm_network_interface.F5n.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5n[0].ip_configuration.*.name,0)
  backend_address_pool_id = azurerm_lb_backend_address_pool.F5.id
}

resource "azurerm_lb_nat_rule" "SSH1" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb_f5.id
  name                           = "SSH1"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "lb_vip"
#  ip_configuration_name          = element(azurerm_network_interface.F5[0].ip_configuration.*.name,0)
}

resource "azurerm_lb_nat_rule" "SSH2" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb_f5.id
  name                           = "SSH2"
  protocol                       = "Tcp"
  frontend_port                  = 222
  backend_port                   = 22
  frontend_ip_configuration_name = "lb_vip"
#  ip_configuration_name          = element(azurerm_network_interface.F5n[0].ip_configuration.*.name,0)
}

resource "azurerm_lb_nat_rule" "WEB1" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb_f5.id
  name                           = "WEB1"
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "lb_vip"
#  ip_configuration_name          = element(azurerm_network_interface.F5[0].ip_configuration.*.name,0)
}

resource "azurerm_lb_nat_rule" "WEB2" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb_f5.id
  name                           = "WEB2"
  protocol                       = "Tcp"
  frontend_port                  = 9443
  backend_port                   = 8443
  frontend_ip_configuration_name = "lb_vip"
#  ip_configuration_name          = element(azurerm_network_interface.F5n[0].ip_configuration.*.name,0)
}

resource "azurerm_network_interface_nat_rule_association" "SSH1" {
  network_interface_id    = element(azurerm_network_interface.F5.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5[0].ip_configuration.*.name,0)
  nat_rule_id             = azurerm_lb_nat_rule.SSH1.id
}

resource "azurerm_network_interface_nat_rule_association" "WEB1" {
  network_interface_id    = element(azurerm_network_interface.F5.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5[0].ip_configuration.*.name,0)
  nat_rule_id             = azurerm_lb_nat_rule.WEB1.id
}

resource "azurerm_network_interface_nat_rule_association" "SSH2" {
  network_interface_id    = element(azurerm_network_interface.F5n.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5n[0].ip_configuration.*.name,0)
  nat_rule_id             = azurerm_lb_nat_rule.SSH2.id
}

resource "azurerm_network_interface_nat_rule_association" "WEB2" {
  network_interface_id    = element(azurerm_network_interface.F5n.*.id, 0)
  ip_configuration_name   = element(azurerm_network_interface.F5n[0].ip_configuration.*.name,0)
  nat_rule_id             = azurerm_lb_nat_rule.WEB2.id
}
