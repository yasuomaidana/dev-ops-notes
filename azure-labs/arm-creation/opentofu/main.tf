resource "azurerm_resource_group" "vm_lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_security_group" "vm_lab" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.vm_lab.location
  resource_group_name = azurerm_resource_group.vm_lab.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vm_lab" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.vm_lab.location
  resource_group_name = azurerm_resource_group.vm_lab.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "vm_lab" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.vm_lab.name
  virtual_network_name = azurerm_virtual_network.vm_lab.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "vm_lab" {
  subnet_id                 = azurerm_subnet.vm_lab.id
  network_security_group_id = azurerm_network_security_group.vm_lab.id
}

resource "azurerm_public_ip" "vm_lab" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.vm_lab.location
  resource_group_name = azurerm_resource_group.vm_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [var.availability_zone]
  tags                = var.tags
}

resource "azurerm_network_interface" "vm_lab" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.vm_lab.location
  resource_group_name = azurerm_resource_group.vm_lab.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm_lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_lab.id
    primary                       = true
  }
}

resource "azurerm_linux_virtual_machine" "vm_lab" {
  name                = var.vm_name
  location            = azurerm_resource_group.vm_lab.location
  resource_group_name = azurerm_resource_group.vm_lab.name
  size                = var.vm_size
  zone                = var.availability_zone
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_lab.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_public_key
  }

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  boot_diagnostics {}

  tags = var.tags
}
