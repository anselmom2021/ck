# Login and set the Subscription to use
#az login

# Define zone name and add it to DNS
$zone="devcirclek.westeurope.aroapp.io"

#Add-DnsServerPrimaryZone -Name $Zone -ZoneFile ($Zone + ".dns")

# Define RG and Cluster name
$ARO_RG="eur-modrse-ocp-rg"
$ARO_Name="aro-dev-weu-ocp"
$ARO_Location="westeurope"
$ARO_VNetName="dev-arocluster-weu-vnet"
$ARO_VNet_Subnet_CP="master"
$ARO_VNet_Subnet_WRK="worker"
$ARO_Service_Principal= "eur-modrse-dev-sp"
$ARO_Vault_Name= "eur-modrse-dev-infra-kv"
$ARO_Vault_Secret = "eur-modrse-dev-sp-secret"
$ARO_Client_ID=""
$ARO_Client_Secret=""

# Create RG
az group create --location $ARO_Location --resource-group $ARO_RG

# Create VNET
az network vnet create -g $ARO_RG -n $ARO_VNetName --address-prefixes 10.0.0.0/24

# Create Subnets
az network vnet subnet create -g $ARO_RG --vnet-name $ARO_VNetName -n $ARO_VNet_Subnet_CP --address-prefixes 10.0.0.0/26
az network vnet subnet create -g $ARO_RG --vnet-name $ARO_VNetName -n $ARO_VNet_Subnet_WRK --address-prefixes 10.0.0.64/26

# Disable link service network policies
az network vnet subnet update -g $ARO_RG --vnet-name $ARO_VNetName -n $ARO_VNet_Subnet_CP --disable-private-link-service-network-policies true
az network vnet subnet update -g $ARO_RG --vnet-name $ARO_VNetName -n $ARO_VNet_Subnet_WRK --disable-private-link-service-network-policies true

# Get ARO Service Principal Client ID and Secret
$ARO_Client_ID = (az ad sp list --display-name $ARO_Service_Principal --query "[0].appId").Replace("`"","")
$ARO_Client_Secret = (az keyvault secret show --name $ARO_Vault_Secret --vault-name $ARO_Vault_Name --query "value").Replace("`"","")

# Register ARO Providers for Openshift
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait

# Get latest ARO available version
$ARO_Version = (az aro get-versions --location $ARO_Location)[((az aro get-versions --location $ARO_Location).count)-2].Replace("`"","").Trim()

# Create ARO
az aro create --resource-group $ARO_RG --name $ARO_Name --vnet $ARO_VNetName `
     --master-subnet $ARO_VNet_Subnet_CP --worker-subnet $ARO_VNet_Subnet_WRK `
     --domain $zone `
     --location $ARO_Location `
     --pull-secret "@~/Downloads/pull-secret.txt" `
     --client-id $ARO_Client_ID `
     --client-secret $ARO_Client_Secret `
     --worker-count 3 `
     --worker-vm-size "Standard_D8s_v3" `
     --master-vm-size "Standard_D8s_v3" `
     --apiserver-visibility Public `
	 --ingress-visibility Public `
     --version $ARO_Version `
     --no-wait 

     #--worker-count 4 
	
    #--pull-secret @pull-secret.txt 
    # [--master-vm-size]
    # [--worker-count]
    # [--worker-vm-disk-size-gb]
    # [--worker-vm-size]
    # [--ingress-visibility] 
    # [--apiserver-visibility]
    # https://docs.microsoft.com/de-de/cli/azure/aro


# Get our endpoints
#az aro show -n $ARO_Name -g $ARO_RG --query '{api:apiserverProfile.ip, ingress:ingressProfiles[0].ip}'

# Save them in variables
#$API_IP=(az aro show -n $ARO_Name -g $ARO_RG --query '{api:apiserverProfile.ip}' -o tsv)
#$INGRESS_IP=(az aro show -n $ARO_Name -g $ARO_RG --query '{ingress:ingressProfiles[0].ip}' -o tsv)

# And create DNS records
#Add-DnsServerResourceRecordA -IPv4Address $API_IP -ZoneName $Zone -Name "api"
#Add-DnsServerResourceRecordA -IPv4Address $INGRESS_IP -ZoneName $Zone -Name "*.apps"

# Check out in Azure
#Start-Process ("https://portal.azure.com/#@"+ (az account show --query tenantId -o tsv) + "/resource" + (az group show -n $ARO_RG --query id -o tsv))

# But where are all the resources!?
#az aro show -n $ARO_Name -g $ARO_RG --query clusterProfile

#Start-Process ("https://portal.azure.com/#@"+ (az account show --query tenantId -o tsv) + "/resource" + (az aro show -n $ARO_Name -g $ARO_RG --query clusterProfile.resourceGroupId -o tsv))

# ARO Clusters are not automatically added to the Red Hat Console:
#Start-Process https://console.redhat.com/openshift/

# Delete ARO cluster
y