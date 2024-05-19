resource "azurerm_resource_group" "RG" {
  for_each = var.Bastion_map
  name     = each.value.resource_group_name
  location = each.value.resource_group_location
}

resource "azurerm_virtual_network" "Bastion-vnet" {
  for_each            = var.Bastion_map
  name                = each.value.azurerm_virtual_network
  address_space       = ["192.168.1.0/24"]
  location            = each.value.resource_group_location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_subnet" "Bastion-subnet" {
  for_each             = var.Bastion_map
  name                 = each.value.azurerm_bastion_subnet
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.azurerm_virtual_network
  address_prefixes     = ["192.168.1.224/27"]
  depends_on           = [azurerm_virtual_network.Bastion-vnet]
}

resource "azurerm_public_ip" "Bastion-pip" {
  for_each            = var.Bastion_map
  name                = each.value.azurerm_public_ip
  location            = each.value.resource_group_location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

data "azurerm_subnet" "AzureBastionSubnet" {
  for_each            = var.Bastion_map
  name                = each.value.azurerm_bastion_subnet
  virtual_network_name = each.value.azurerm_virtual_network
  resource_group_name  = each.value.resource_group_name

  depends_on = [azurerm_subnet.Bastion-subnet]
}

resource "azurerm_bastion_host" "Bastion-host" {
  for_each            = var.Bastion_map
  name                = each.value.azurerm_Bastion_host_name
  location            = each.value.resource_group_location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.AzureBastionSubnet[each.key].id
    public_ip_address_id = azurerm_public_ip.Bastion-pip[each.key].id
  }
}
