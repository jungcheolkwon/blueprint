#https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest
#az vm image list --all -p canonical -l southeastasia

#F5 BIG-IP Creating
resource "azurerm_virtual_machine" "F5m" {
  count                 = var.mb_instances
  name                  = "${var.m_hostname}-${count.index}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  tags                  = var.tags
  network_interface_ids = ["${element(azurerm_network_interface.F5m.*.id, count.index)}"]
  vm_size               = var.m_size
  delete_os_disk_on_termination = var.delete_os_disk_on_termination

  storage_os_disk {
    name              = "${var.m_hostname}-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = var.os_version
  }

  plan {
    name      = var.os_sku
    publisher = var.os_publisher
    product   = var.os_offer
  }

  os_profile {
    computer_name  = "${var.m_hostname}-${count.index}"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("${var.ssh_key}")
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.F5m.primary_blob_endpoint
  }

}

resource "azurerm_public_ip" "F5m" {
  count                 = var.mb_public_ip
  name                  = "${var.m_hostname}-${count.index}"
  allocation_method     = var.public_ip_address_allocation
#  domain_name_label     = "${element(var.public_ip_dns, count.index)}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  tags                  = var.tags
}

resource "random_id" "F5m" {
  keepers = {
    vm_hostname = var.m_hostname
    resource_group_name = var.resource_group_name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "F5m" {
  name                     = "diag${random_id.F5m.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  tags                     = var.tags
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_network_interface" "F5m" {
  count                     = var.mb_interfaces
  name                      = "${var.m_hostname}-NIC-${count.index}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  #network_security_group_id = var.network_security_group_id

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.F5m.*.id) > 0 ? element(concat(azurerm_public_ip.F5m.*.id, list("")), count.index) : ""
  }
}
