$environment = $OctopusParameters["Octopus.Environment.Name"]

# exit if environment is Sandbox (sit)
if($environment -eq "sit") { Exit }

write-host "*******************************************************************"
write-host " START init.ps1"
write-host "*******************************************************************"

###############################################################################
# Get all relevant parameters from octopus (variable set dataART)
###############################################################################

$workdirPath = $pwd.ToString()

$artifactoryPW = $args[0]
$login = $OctopusParameters["artifactory.login"]
$registry = $OctopusParameters["artifactory.registry"]
$projectName = $OctopusParameters["Octopus.Project.Name"]
$releaseNumber = $OctopusParameters["Octopus.Release.Number"]
$containerName = "dataArt.$($projectName).$($releaseNumber).$($environment)"

###############################################################################
# Stop and delete containers
###############################################################################

write-host "docker prune: $containerName"

if ($(docker container ls -aq -f name="$containerName").length -gt 0){ docker container stop $($containerName) }
docker container prune -f

write-host "docker prune complete: $containerName" 

###############################################################################
# Login to artifactory, pull and start XSA_CLI_DEPLOY container
###############################################################################

write-host "login: -u $login -p $artifactoryPW   $registry"

docker login -u $login -p $artifactoryPW   $registry

Write-host "login complete - now pull"

docker pull artifactory.azure.dsb.dk/docker/xsa_cli_deploy

Write-host "pull complete - now run"

docker run -v C:\Octopus\Work:/data --name $containerName --rm -t -d artifactory.azure.dsb.dk/docker/xsa_cli_deploy

write-host "*******************************************************************"
write-host " STOP init.ps1"
write-host "*******************************************************************"