Install-WindowsFeature -name Web-Server -IncludeManagementTools
$service = gwmi win32_service  -filter "name='OctopusDeploy Tentacle'"
$service.change($null,$null,$null,$null,$null,$null,".\ut05testservice","G00dj0b!westvalley")
Restart-Service -Name 'OctopusDeploy Tentacle'
$env:computername 