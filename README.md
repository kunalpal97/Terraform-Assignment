# Azure Infrastructure Deployment with Terraform

## 1. Project Overview

This project provisions a complete Azure infrastructure using **Terraform**.

The infrastructure is designed with a basic **public/private subnet architecture**:

* A Virtual Network (VNet)
* One public subnet
* One private subnet
* A Network Security Group (NSG) for each subnet
* One public Linux VM
* One private Linux VM
* A static Public IP for the public VM
* SSH key authentication
* NGINX automatically installed on the public VM
* Controlled SSH connectivity from the public subnet to the private subnet

The main objective is to understand how infrastructure can be created, configured, connected, and managed using **Infrastructure as Code (IaC)** rather than manually creating resources through the Azure Portal.

---

# 2. Architecture

The final architecture looks like this:

```text
                         INTERNET
                            |
              +-------------+-------------+
              |                           |
           HTTP :80                    SSH :22
              |                           |
              v                           v
    +---------------------------------------------+
    |              PUBLIC SUBNET                  |
    |              10.0.1.0/24                    |
    |                                             |
    |              Public VM                     |
    |              vm-pubic                      |
    |              Private IP: 10.0.1.4          |
    |              Public IP: 20.207.198.105     |
    |              NGINX :80                     |
    +------------------------+--------------------+
                             |
                             | SSH :22
                             | Allowed from
                             | 10.0.1.0/24
                             v
    +---------------------------------------------+
    |              PRIVATE SUBNET                 |
    |              10.0.2.0/24                    |
    |                                             |
    |              Private VM                     |
    |              vm-private                     |
    |              Private IP: 10.0.2.4           |
    |              NO PUBLIC IP                   |
    +---------------------------------------------+
                             |
                             | Outbound HTTPS
                             v
                         INTERNET
```

## Network design

### VNet

```text
10.0.0.0/16
```

The VNet provides the overall private network.

### Public subnet

```text
10.0.1.0/24
```

The public VM is placed inside this subnet.

The public VM has:

* Private IP
* Public IP
* NGINX
* Internet-facing HTTP access
* SSH access

### Private subnet

```text
10.0.2.0/24
```

The private VM is placed inside this subnet.

The private VM has:

* Private IP only
* No Public IP
* No direct inbound Internet access
* SSH access from the public subnet
* Outbound Internet connectivity

---

# 3. Technologies Used

| Technology       | Purpose                         |
| ---------------- | ------------------------------- |
| Azure            | Cloud infrastructure            |
| Terraform        | Infrastructure as Code          |
| AzureRM Provider | Terraform → Azure communication |
| TLS Provider     | SSH key generation              |
| Ubuntu 22.04     | VM operating system             |
| NGINX            | Web server                      |
| SSH              | Secure VM administration        |
| Azure VNet       | Private networking              |
| Azure NSG        | Network traffic control         |

---

# 4. Project Folder Structure

The project is organized into reusable Terraform modules.

```text
terraform/
│
├── detail.txt
├── .gitignore
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── networking/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── ssh-key/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── vm/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── .terraform/
├── .terraform.lock.hcl
├── terraform.tfstate
└── terraform.tfstate.backup
```

---

# 5. Terraform File Responsibilities

## Root `main.tf`

The root `main.tf` acts as the **main orchestration layer**.

It creates the Resource Group and calls the Terraform modules.

The major modules are:

```text
module.networking
module.ssh_key
module.vm
```

The root module passes values between these modules.

For example:

```text
networking module
       |
       | subnet IDs
       v
     VM module
```

and:

```text
SSH module
     |
     | public SSH key
     v
   VM module
```

This is one of the important concepts in modular Terraform.

---

# 6. Terraform Provider Configuration

The `providers.tf` file defines the Azure provider.

The project uses:

```text
AzureRM provider
```

with a version constraint around the 4.x provider family.

Terraform therefore knows that Azure resources such as:

```text
azurerm_resource_group
azurerm_virtual_network
azurerm_subnet
azurerm_network_security_group
azurerm_linux_virtual_machine
azurerm_network_interface
azurerm_public_ip
```

are being managed through Azure.

---

# 7. Terraform Initialization

The first major Terraform command used was:

```bash
terraform init
```

Terraform initialization performs several important tasks.

It:

1. Initializes the working directory.
2. Downloads required providers.
3. Initializes modules.
4. Creates/updates the provider lock file.
5. Prepares Terraform to execute the configuration.

For this project, Terraform installed/reused:

```text
hashicorp/azurerm
hashicorp/tls
```

The `.terraform.lock.hcl` file records provider dependency selections.

---

# 8. Terraform Formatting

The following command was used:

```bash
terraform fmt
```

Purpose:

* Formats Terraform files.
* Makes the code consistent.
* Improves readability.
* Helps maintain a standard Terraform codebase.

Example:

```bash
terraform fmt
```

If files are changed, Terraform reports which files were formatted.

---

# 9. Terraform Validation

The configuration was validated using:

```bash
terraform validate
```

The successful result was:

```text
Success! The configuration is valid.
```

This confirms that Terraform can parse the configuration and that the configuration is structurally valid.

Important:

`terraform validate` does **not** mean that Azure resources have been successfully created.

It validates the Terraform configuration itself.

---

# 10. Networking Module

The `networking` directory contains the network infrastructure.

```text
networking/
├── main.tf
├── variables.tf
└── outputs.tf
```

The networking module is responsible for creating:

* VNet
* Public subnet
* Private subnet
* Public NSG
* Private NSG
* NSG rules
* NSG/subnet associations

---

# 11. Virtual Network

The VNet provides the private networking environment.

The project uses:

```text
VNet: vnet-terraform-assign
Address space: 10.0.0.0/16
```

The VNet contains two subnets.

```text
10.0.0.0/16
│
├── 10.0.1.0/24
│   └── Public subnet
│
└── 10.0.2.0/24
    └── Private subnet
```

This allows the two VMs to communicate through Azure's private network.

---

# 12. Public Subnet

The public subnet is:

```text
snet-public
10.0.1.0/24
```

The public VM is placed here.

The public VM has:

```text
Private IP: 10.0.1.4
Public IP: 20.207.198.105
```

The public IP makes the VM reachable from the Internet for the allowed ports.

---

# 13. Private Subnet

The private subnet is:

```text
snet-private
10.0.2.0/24
```

The private VM is placed here.

Its private IP is:

```text
10.0.2.4
```

There is intentionally **no Public IP attached to the private VM**.

Therefore, users on the Internet cannot directly connect to:

```text
10.0.2.4
```

The private VM can instead be accessed through the public VM.

This creates a basic bastion/jump-host style access pattern.

---

# 14. Network Security Groups

Two NSGs were created.

```text
nsg-public
nsg-private
```

NSGs are used to control inbound and outbound network traffic associated with Azure network interfaces/subnets.

---

# 15. Public NSG Rules

The public NSG contains rules for:

### SSH

```text
Protocol: TCP
Port: 22
Direction: Inbound
Access: Allow
```

This allows SSH access to the public VM.

### HTTP

```text
Protocol: TCP
Port: 80
Direction: Inbound
Access: Allow
```

This allows users to access NGINX over HTTP.

The HTTP flow is:

```text
Internet
   |
   | TCP :80
   v
Public IP
   |
   v
Public VM
   |
   v
NGINX
```

---

# 16. Private NSG Rule

The private NSG contains an SSH rule allowing traffic from:

```text
10.0.1.0/24
```

to:

```text
TCP port 22
```

This is important.

It means the private VM's SSH access is restricted to the public subnet.

Conceptually:

```text
Public subnet
10.0.1.0/24
       |
       | SSH :22
       v
Private VM
10.0.2.4
```

The Internet does not directly have an inbound route to the private VM.

---

# 17. NSG/Subnet Association

Creating an NSG alone is not enough.

The NSG must be associated with the appropriate subnet.

The project therefore creates:

```text
Public subnet
      |
      v
nsg-public

Private subnet
      |
      v
nsg-private
```

This is handled through:

```text
azurerm_subnet_network_security_group_association
```

---

# 18. SSH Key Module

The `ssh-key` module is responsible for generating an SSH key pair.

```text
ssh-key/
├── main.tf
├── variables.tf
└── outputs.tf
```

The project uses the Terraform TLS provider.

A 4096-bit RSA key is generated.

Conceptually:

```text
Terraform
   |
   v
tls_private_key
   |
   +------ Public key
   |
   +------ Private key
```

The public key is passed to both VMs.

The private key remains available through Terraform state/output.

---

# 19. Why SSH Keys Are Used

Password authentication is disabled for the Linux VMs.

Instead, authentication is performed using SSH keys.

This is preferable because SSH keys are generally more secure and suitable for automated infrastructure.

The VM receives the public key:

```text
ssh_public_key
```

The administrator retains the private key.

---

# 20. Important SSH Key Security

The generated private key is sensitive.

Terraform state can contain sensitive information produced by resources such as `tls_private_key`.

Therefore:

```text
terraform.tfstate
```

must be treated as sensitive.

Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
*.pem
*.key
```

to a public Git repository.

The `.gitignore` should contain appropriate exclusions.

---

# 21. VM Module

The VM module contains:

```text
vm/
├── main.tf
├── variables.tf
└── outputs.tf
```

The module creates:

* Public IP
* Public NIC
* Private NIC
* Public VM
* Private VM

---

# 22. Public IP

The public VM receives a static Public IP.

Example:

```text
Public IP:
20.207.198.105
```

The Public IP is associated with the public VM's NIC.

This allows Internet traffic to reach the VM.

---

# 23. Network Interfaces

Each VM receives its own Network Interface Card.

```text
Public VM
   |
   v
Public NIC
   |
   v
Public subnet
```

and:

```text
Private VM
   |
   v
Private NIC
   |
   v
Private subnet
```

The public NIC additionally has a Public IP attached.

The private NIC does not.

---

# 24. Virtual Machine Configuration

Both VMs use:

```text
Ubuntu 22.04
```

The Azure Marketplace image is:

```text
Publisher:
Canonical

Offer:
0001-com-ubuntu-server-jammy

SKU:
22_04-lts-gen2

Version:
latest
```

The VM size used in the final configuration was:

```text
Standard_B2ls_v2
```

The values were verified against the Azure region's available VM/image options before deployment.

---

# 25. Public VM

The public VM is:

```text
vm-pubic
```

Note: the project currently uses the spelling `vm-pubic`. This is simply the resource name used in the Terraform variables.

The public VM has:

```text
Private IP:
10.0.1.4

Public IP:
20.207.198.105
```

---

# 26. Private VM

The private VM is:

```text
vm-private
```

Its private IP is:

```text
10.0.2.4
```

It does not have a public IP.

Therefore:

```text
Internet
   X
   |
   v
10.0.2.4
```

is not a valid direct access path from the user's laptop.

Instead:

```text
Laptop
   |
   v
Public VM
   |
   v
Private VM
```

is used.

---

# 27. Automatic NGINX Installation

NGINX is automatically installed on the public VM during VM provisioning.

Terraform uses cloud-init/custom data.

The VM executes commands equivalent to:

```bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
```

Therefore, NGINX does not need to be manually installed after every deployment.

This is an important Infrastructure-as-Code principle:

> Infrastructure provisioning should be repeatable and automated.

---

# 28. Terraform Module Dependency Flow

The root module connects everything together.

The dependency flow is approximately:

```text
Resource Group
      |
      v
Networking Module
      |
      +---- Public Subnet ID
      |
      +---- Private Subnet ID
      |
      v
SSH Key Module
      |
      +---- SSH Public Key
      |
      v
VM Module
      |
      +---- Public NIC
      +---- Private NIC
      +---- Public IP
      +---- Public VM
      +---- Private VM
```

Terraform automatically determines the resource creation order based on references between resources.

---

# 29. Terraform Initialization and Module Installation

When the VM module was added to `main.tf`, running validation initially produced:

```text
Error: Module not installed
```

Terraform indicated that the new module needed initialization.

The solution was:

```bash
terraform init
```

Terraform then reported:

```text
- vm in vm
```

and initialized the module.

After that:

```bash
terraform validate
```

returned:

```text
Success! The configuration is valid.
```

This demonstrates an important Terraform workflow:

```text
Change module configuration
        |
        v
terraform init
        |
        v
terraform fmt
        |
        v
terraform validate
```

---

# 30. Terraform Plan

Before applying infrastructure changes, the project used:

```bash
terraform plan
```

Terraform compared:

```text
Desired configuration
        VS
Current Terraform state
```

and displayed the changes.

For example, when the VM module was introduced, Terraform planned:

```text
5 to add
0 to change
0 to destroy
```

The planned resources included:

* Public VM
* Private VM
* Public NIC
* Private NIC
* Public IP

This is an important safety feature because `terraform plan` allows changes to be reviewed before they are applied.

---

# 31. Terraform Apply

After reviewing the plan:

```bash
terraform apply
```

was executed.

Terraform requested confirmation:

```text
Do you want to perform these actions?
```

and:

```text
Only 'yes' will be accepted to approve.
```

After entering:

```text
yes
```

Terraform provisioned the resources.

The final VM deployment reported:

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

---

# 32. Terraform State

Terraform tracks managed infrastructure in:

```text
terraform.tfstate
```

The state contains information Terraform uses to understand which real Azure resources correspond to the Terraform configuration.

The project verified the state using:

```bash
terraform state list
```

The state contained resources such as:

```text
azurerm_resource_group.terraform_task

module.networking.azurerm_virtual_network.main

module.networking.azurerm_subnet.public

module.networking.azurerm_subnet.private

module.networking.azurerm_network_security_group.public

module.networking.azurerm_network_security_group.private

module.ssh_key.tls_private_key.main

module.vm.azurerm_linux_virtual_machine.public

module.vm.azurerm_linux_virtual_machine.private

module.vm.azurerm_network_interface.public

module.vm.azurerm_network_interface.private

module.vm.azurerm_public_ip.public
```

This confirms that Terraform is managing the deployed infrastructure.

---

# 33. Terraform Outputs

The root module exposes useful values through outputs.

The final outputs were:

```text
private_vm_private_ip = 10.0.x.x

public_ip_address = 20.x.x.x

public_vm_private_ip = 10.x.x.x
```

These were retrieved using:

```bash
terraform output
```

Outputs are useful because users do not have to manually search Azure Portal for resource values.

---

# 34. SSH Private Key Output

The generated private key is exposed through a sensitive Terraform output.

It can be retrieved with:

```bash
terraform output -raw ssh_private_key_pem
```

The private key was then saved locally:

```bash
terraform output -raw ssh_private_key_pem > terraform-vm-key.pem
```

The key permissions were restricted:

```bash
chmod 600 terraform-vm-key.pem
```

This is important because SSH refuses to use private keys with overly permissive file permissions.

---

# 35. Connecting to the Public VM

The public VM was accessed using:

```bash
ssh -i terraform-vm-key.pem azure-assignment-user@20.207.198.105
```

Successful login produced:

```text
azure-assignment-user@vm-pubic:~$
```

This confirmed that:

* The VM exists.
* The Public IP works.
* SSH port 22 is reachable.
* The SSH key is valid.
* The administrator username is correct.

---

# 36. Verifying NGINX

The public VM was configured to automatically install NGINX.

The application was tested externally using:

```bash
curl http://20.x.x.x
```

The response contained:

```text
Welcome to nginx!
```

This confirmed:

```text
Internet
   |
   | HTTP :80
   v
Azure Public IP
   |
   v
Public NIC
   |
   v
Public VM
   |
   v
NGINX
```

The web server is therefore successfully reachable from the Internet.

---

# 37. Connecting to the Private VM

The private VM does not have a Public IP.

Therefore, direct SSH from the laptop to:

```text
10.x.x.x
```

does not work.

Instead, SSH agent forwarding was used.

From the local machine:

```bash
eval "$(ssh-agent -s)"
ssh-add terraform-vm-key.pem
```

Then the public VM was accessed with:

```bash
ssh -A -i terraform-vm-key.pem azure-assignment-user@20.x.x.x
```

From the public VM:

```bash
ssh azure-assignment-user@10.x.x.x
```

The result was:

```text
azure-assignment-user@vm-private:~$
```

This successfully demonstrated:

```text
Laptop
   |
   | SSH
   v
Public VM
   |
   | SSH
   v
Private VM
```

---

# 38. Why SSH Agent Forwarding Was Used

The private SSH key was not copied onto the public VM.

Instead, SSH agent forwarding allows the public VM to use the SSH authentication capability from the user's local machine.

This is preferable to manually copying the private key onto the public VM.

Conceptually:

```text
Laptop
  |
  | Private key stays here
  |
  | SSH agent forwarding
  v
Public VM
  |
  | Authentication request
  v
Private VM
```

The private key itself does not need to be stored on the public VM.

---

# 39. Testing Private VM Internet Access

Inside the private VM, the following command was executed:

```bash
curl -I https://google.com
```

The response was:

```text
HTTP/2 301
location: https://www.google.com/
```

This confirms that the private VM has outbound Internet connectivity.

This is an important networking distinction.

The private VM:

```text
CAN:
- Make outbound Internet connections.

CANNOT:
- Be directly accessed from the public Internet through a Public IP.
```

Having outbound Internet access does not automatically make the VM Internet-facing.

---

# 40. Verifying Private VM Network Configuration

The command:

```bash
ip addr
```

showed:

```text
eth0
inet 10.0.2.4/24
```

This confirms that the private VM is using the private subnet.

The hostname was checked using:

```bash
hostname
```

and returned:

```text
vm-private
```

This confirmed that the session was running on the intended private VM.

---

# 41. Final Testing Summary

The following tests were successfully completed.

## Test 1 — Terraform validation

```bash
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

---

## Test 2 — Infrastructure deployment

```bash
terraform apply
```

Result:

```text
Apply complete!
```

---

## Test 3 — Terraform state

```bash
terraform state list
```

Confirmed all expected resources are managed by Terraform.

---

## Test 4 — Public IP

```bash
terraform output
```

Returned:

```text
20.x.x.x
```

---

## Test 5 — NGINX

```bash
curl http://20.x.x.x
```

Returned:

```text
Welcome to nginx!
```

---

## Test 6 — Public VM SSH

```bash
ssh -i terraform-vm-key.pem azure-assignment-user@20.x.x.x
```

Successful.

---

## Test 7 — Public VM → Private VM

```bash
ssh azure-assignment-user@10.x.x.x
```

Successful after configuring SSH agent forwarding.

---

## Test 8 — Private VM outbound Internet

```bash
curl -I https://google.com
```

Successful.

---

## Test 9 — Private VM IP

```bash
ip addr
```

Confirmed:

```text
10.0.2.4/24
```

---

# 42. Terraform Workflow Used

The overall workflow followed was:

```text
1. Write Terraform configuration
          |
          v
2. terraform init
          |
          v
3. terraform fmt
          |
          v
4. terraform validate
          |
          v
5. terraform plan
          |
          v
6. Review planned changes
          |
          v
7. terraform apply
          |
          v
8. Verify terraform state
          |
          v
9. Check terraform outputs
          |
          v
10. Test actual infrastructure
```

This is the core Terraform workflow to remember.

---

# 43. Production-Oriented Considerations

The current project is suitable as a learning/assignment implementation, but several improvements would normally be considered for production.

## SSH access

The current public NSG allows SSH from:

```text
0.0.0.0/0
```

This means any Internet source can attempt to connect to port 22.

For production, SSH should preferably be restricted to:

* Known administrator IP ranges
* VPN
* Azure Bastion
* Private connectivity
* A controlled jump host

---

## Terraform state

For production Terraform deployments, local state is generally not preferred.

A remote backend such as Azure Storage can be used for:

* Centralized state
* State locking
* Team collaboration
* Backup
* Better security controls

---

## Secrets

Private keys and secrets should not be casually exposed through Terraform outputs.

Production environments should consider:

* Azure Key Vault
* Managed identities
* Secure CI/CD secrets
* Short-lived credentials

---

## VM provisioning

For larger production environments, VM initialization may be handled through:

* Cloud-init
* Azure VM extensions
* Configuration management
* Immutable images
* Packer
* CI/CD

The current project uses cloud-init/custom data to install NGINX, which is appropriate for this assignment.

---

# 44. Why Modules Were Used

Instead of putting everything into one `main.tf`, the infrastructure was divided into logical modules.

```text
networking
ssh-key
vm
```

This improves:

* Reusability
* Maintainability
* Readability
* Separation of concerns
* Scalability

For example:

```text
networking/
```

only deals with networking.

```text
ssh-key/
```

deals with SSH key generation.

```text
vm/
```

deals with compute resources.

The root module connects them together.

---

# 45. Separation of Concerns

The project follows this logical separation:

```text
Root
 |
 +-- Resource Group
 |
 +-- Networking
 |     |
 |     +-- VNet
 |     +-- Subnets
 |     +-- NSGs
 |     +-- NSG Rules
 |
 +-- SSH Key
 |     |
 |     +-- RSA Key Pair
 |
 +-- VM
       |
       +-- Public IP
       +-- NICs
       +-- Public VM
       +-- Private VM
       +-- NGINX
```

This makes the Terraform configuration easier to understand and modify.

---

# 46. Important Terraform Concepts Learned

This project demonstrates several important Terraform concepts:

### Providers

Terraform providers allow Terraform to communicate with external platforms.

Example:

```text
AzureRM
TLS
```

### Resources

Resources represent actual infrastructure objects.

Examples:

```text
azurerm_virtual_network
azurerm_subnet
azurerm_linux_virtual_machine
azurerm_public_ip
```

### Variables

Variables allow configuration values to be separated from resource definitions.

Examples:

```text
location
vm_size
resource_group_name
vnet_address_space
```

### Modules

Modules organize infrastructure into reusable components.

### Outputs

Outputs expose useful resource information.

### State

Terraform state tracks the relationship between Terraform configuration and real infrastructure.

### Dependencies

Terraform determines resource dependencies through references.

---

# 47. Final Infrastructure

At the end of the deployment, the following infrastructure was running:

```text
Azure Subscription
       |
       v
Resource Group
rg-terraform-assign
       |
       v
VNet
vnet-terraform-assign
10.0.0.0/16
       |
       +------------------------+
       |                        |
       v                        v
Public Subnet             Private Subnet
10.0.1.0/24               10.0.2.0/24
       |                        |
       v                        v
Public VM                 Private VM
vm-pubic                  vm-private
10.0.1.4                  10.0.2.4
       |                        |
       |                        X
       v                    No Public IP
20.207.198.105
       |
       v
NGINX
```

---

# 48. Final Verification

The infrastructure was successfully verified from both Terraform and the operating-system level.

Terraform verification:

```bash
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
```

Application verification:

```bash
curl http://20.x.x.x
```

SSH verification:

```bash
ssh -i terraform-vm-key.pem azure-assignment-user@20.x.x.x
```

Private network verification:

```bash
ssh azure-assignment-user@10.0.2.4
```

Internet connectivity verification:

```bash
curl -I https://google.com
```

Network verification:

```bash
ip addr
```

Hostname verification:

```bash
hostname
```

All major tests completed successfully.

---

# 49. Cleanup

When the infrastructure is no longer required, Terraform can remove the resources it manages using:

```bash
terraform destroy
```

Terraform will show the resources that are going to be destroyed and request confirmation.

Only enter:

```text
yes
```

after reviewing the destruction plan.

This is particularly important when working with paid Azure resources.

---
<!-- 
# 50. Project Completion Status

## Infrastructure

```text
[✓] Resource Group
[✓] Virtual Network
[✓] Public Subnet
[✓] Private Subnet
[✓] Public NSG
[✓] Private NSG
[✓] NSG Rules
[✓] NSG Associations
[✓] SSH Key Pair
[✓] Public IP
[✓] Public NIC
[✓] Private NIC
[✓] Public VM
[✓] Private VM
[✓] NGINX
```

## Validation

```text
[✓] terraform init
[✓] terraform fmt
[✓] terraform validate
[✓] terraform plan
[✓] terraform apply
[✓] terraform state list
[✓] terraform output
```

## Connectivity

```text
[✓] Internet → Public VM
[✓] HTTP → NGINX
[✓] Laptop → Public VM
[✓] Public VM → Private VM
[✓] Private VM → Internet
[✓] Private VM has no Public IP
```

---

# 51. Short Project Explanation

If asked to explain this project technically:

> "I built an Azure infrastructure using Terraform with a modular architecture. I created a Resource Group and a VNet with separate public and private subnets. Each subnet has its own Network Security Group with controlled inbound rules. I provisioned two Ubuntu Linux VMs: a public VM with a static Public IP and NGINX, and a private VM without a Public IP. The public VM is Internet-accessible over HTTP and SSH, while the private VM can only be reached through the public subnet over SSH. I used Terraform's TLS provider to generate an RSA SSH key pair and passed the public key to both VMs. NGINX is installed automatically during VM provisioning using cloud-init/custom data. Finally, I validated the Terraform configuration, applied the infrastructure, checked Terraform state and outputs, and tested HTTP, SSH, private network connectivity, and outbound Internet access from the private VM."

---

# 52. Key Takeaway

The most important concept demonstrated by this project is:

```text
Infrastructure
      +
Networking
      +
Security
      +
Compute
      +
Automation
      +
Testing
      =
Infrastructure as Code
```

Terraform allows the entire infrastructure to be represented as code, making it reproducible, reviewable, version-controllable, and easier to maintain than manually creating each Azure resource through the Portal. -->
