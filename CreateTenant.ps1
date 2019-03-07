cls
# NOTE: this script will fail if the Tenants feature is not enabled on your Octopus Server
Set-ExecutionPolicy Unrestricted
# You can this dll from your Octopus Server/Tentacle installation directory or from
# https://www.nuget.org/packages/Octopus.Client/
cd "C:\Program Files\Octopus Deploy\Tentacle"
$hostip = (Invoke-WebRequest -UseBasicParsing ipinfo.io/ip).Content
.\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
.\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
.\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10943" --console
.\Tentacle.exe configure --instance "Tentacle" --trust "9D1E9229C199A51FF3F0E4DB16012BB543F31CAC" --console

.\Tentacle.exe register-with --instance "Tentacle" --server "https://p1octopus.eastus.cloudapp.azure.com" --apikey=API-FEBPOHPCCPGEUIWIYAAN7GF4 --publicHostName=$hostip --server-comms-port "10943" --force --environment P1Records  --role "P1Records-DB", --role "P1Records-RDW" --role "P1Records-App1"
.\Tentacle.exe service --instance "Tentacle" --install --start --console

set-location c:\Octopus
#Install-Package -Name "Octopus.Client" -Verbose -Force
Add-Type -Path 'Octopus.Client.dll' 

$apikey = 'API-FEBPOHPCCPGEUIWIYAAN7GF4' # Get this from your profile
$octopusURI = 'https://p1octopus.eastus.cloudapp.azure.com' # Your Octopus Server address
#
$endpoint = New-Object Octopus.Client.OctopusServerEndpoint $octopusURI, $apiKey
$repository = New-Object Octopus.Client.OctopusRepository $endpoint


$tagSetEditor = $repository.TagSets.FindByName("P1Records")




$project = $repository.Projects.FindByName("P1Records Install")
$project1 = $repository.Projects.FindByName("P1Records Upgrade")
$project2 = $repository.Projects.FindByName("P1Records App Cleanup")
$project3 = $repository.Projects.FindByName("P1Records DB Cleanup")
$project4 = $repository.Projects.FindByName("P1Records DB Cleanup")
$environment = $repository.Environments.FindByName("P1Records")
$MACHINE =  $repository.Machines.FindByName( $env:COMPUTERNAME)

$tenantEditor = $repository.Tenants.CreateOrModify( $env:COMPUTERNAME)

$tenantEditor.WithTag($tagSetEditor.Tags[0])
$tenantEditor.WithTag($tagSetEditor.Tags[1])
$tenantEditor.ConnectToProjectAndEnvironments($project, $environment)
$tenantEditor.ConnectToProjectAndEnvironments($project1, $environment)
$tenantEditor.ConnectToProjectAndEnvironments($project2, $environment)
$tenantEditor.ConnectToProjectAndEnvironments($project3, $environment)
$tenantEditor.ConnectToProjectAndEnvironments($project4, $environment)
$tenantEditor.Save()

# initialize the array
[PsObject[]]$people = @()
$people += $tenantEditor.Instance
$MACHINE.TenantIds.Add($tenantEditor.Instance.Id)
$repository.Machines.Modify($MACHINE)
#$tenantVariableResource = $repository.Tenants.GetVariables(
#var property = new PropertyValueResource("it works");
#var id = tenantVariableResource.ProjectVariables["MyProject"].Templates.FirstOrDefault().Id;
#var projectVariables = tenantVariableResource.ProjectVariables["MyProject"].Variables["MyEnvironment"];
#if (projectVariables.ContainsKey(id)) projectVariables.Remove(id);
#projectVariables.Add(id, property);
#repository.Tenants.ModifyVariables(tenant, tenantVariableResource)
Set-Location "C:\Program Files\Octopus Deploy\Tentacle"

.\Tentacle.exe service --instance "Tentacle" --reconfigure --start --console
