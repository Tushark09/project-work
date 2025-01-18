# Bypass execution policy for this script
Set-ExecutionPolicy Bypass -Scope Process -Force

# Configuration
$desiredHostname = "${hostname}"
$dcIP = "${dc_ip}"
$domainName = "${domain_name}"
$username = "$domainName\${domain_join_username}"
$password = ConvertTo-SecureString "${domain_join_password}" -AsPlainText -Force
$env = "${env}"
$partitionConfig = '${partition_config}'
$dnsServer = "${dns_server}"
$deploymentGroupName = "${deployment_group_name}"
$azureDevOpsUrl = "${azure_devops_url}"
$azureDevOpsPat = "${azure_devops_pat}"

# File paths
$logFile = "C:\Windows\Logs\startup_${env}_log.txt"
$phase1CompleteFlag = "C:\Windows\Logs\phase1_${env}_complete.flag"
$phase2CompleteFlag = "C:\Windows\Logs\phase2_${env}_complete.flag"
$domainUnjoinedFlag = "C:\Windows\Logs\domain_${env}_unjoined.flag"

# Function to log messages
function Log-Message {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -Append -FilePath $logFile
    Write-Host $message
}

# Log the environment
Log-Message "Current environment: $env"

# New Unjoin-Domain function
function Unjoin-Domain {
    Log-Message "Starting Unjoin-Domain function"
    try {
        Log-Message "Attempting to unjoin domain using current user credentials"
        $result = Start-Process -FilePath "netdom.exe" -ArgumentList "remove $env:COMPUTERNAME /Force" -PassThru -Wait -NoNewWindow
        if ($result.ExitCode -ne 0) {
            Log-Message "Failed to unjoin domain with current user. Exit code: $($result.ExitCode)"
            Log-Message "Prompting for domain admin credentials"
            $cred = Get-Credential -Message "Enter domain admin credentials to unjoin domain"
            $result = Start-Process -FilePath "netdom.exe" -ArgumentList "remove $env:COMPUTERNAME /Force" -Credential $cred -PassThru -Wait -NoNewWindow
            if ($result.ExitCode -ne 0) {
                throw "Netdom command failed with exit code: $($result.ExitCode)"
            }
        }
        Log-Message "Successfully unjoined the domain"
        return $true
    }
    catch {
        Log-Message "Error in Unjoin-Domain function: $_"
        return $false
    }
}

# Function to check hostname and domain
function Check-HostnameAndDomain {
    $currentHostname = $env:COMPUTERNAME
    $computerSystem = Get-CimInstance Win32_ComputerSystem

    if ($currentHostname -ne $desiredHostname) {
        Log-Message "Current hostname ($currentHostname) does not match desired hostname ($desiredHostname)."
        
        # Remove all flags
        if (Test-Path $phase1CompleteFlag) { 
            Remove-Item $phase1CompleteFlag -Force
            Log-Message "Removed Phase 1 flag."
        }
        if (Test-Path $phase2CompleteFlag) { 
            Remove-Item $phase2CompleteFlag -Force
            Log-Message "Removed Phase 2 flag."
        }
        if (Test-Path $domainUnjoinedFlag) { 
            Remove-Item $domainUnjoinedFlag -Force
            Log-Message "Removed domain unjoin flag."
        }

        if ($computerSystem.PartOfDomain) {
            Log-Message "Machine is domain-joined. Unjoining domain."
            
            # Unjoin domain
            $unjoinSuccess = Unjoin-Domain
            if ($unjoinSuccess) {
                Log-Message "Successfully unjoined the domain."
                New-Item -Path $domainUnjoinedFlag -ItemType File -Force | Out-Null
                Log-Message "Domain unjoin flag created."
                Log-Message "Restarting system after domain unjoin..."
                Restart-Computer -Force
                exit
            } else {
                Log-Message "Failed to unjoin domain."
                return $false
            }
        } else {
            Log-Message "Machine is not domain-joined. Proceeding with hostname change."
            return $true
        }
    } else {
        if (Test-Path $domainUnjoinedFlag) { 
            Remove-Item $domainUnjoinedFlag -Force
            Log-Message "Removed domain unjoin flag as hostname is correct."
        }
        Log-Message "Hostname matches desired hostname. No changes needed."
        return $false
    }
}


# Function to set time zone
function Set-VMTimeZone {
    try {
        Set-TimeZone -Id "Eastern Standard Time"
        Log-Message "Time zone successfully set to Eastern Standard Time"
        return $true
    } catch {
        Log-Message "Error setting time zone: $_"
        return $false
    }
}

# Function to set DNS server for all network adapters
function Set-VmDnsServer {
    param (
        [string]$dnsServer
    )
    
    # Get all network adapters
    $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    if ($null -eq $networkAdapters) {
        Log-Message "No active network adapters found."
        return $false
    }
    
    # Set DNS server for each active network adapter
    foreach ($adapter in $networkAdapters) {
        $adapterIndex = $adapter.ifIndex
        Log-Message "Setting DNS server for adapter '$($adapter.Name)' to $dnsServer"
        Set-DnsClientServerAddress -InterfaceIndex $adapterIndex -ServerAddresses $dnsServer
    }
    
    Log-Message "DNS server set to $dnsServer for all active network adapters."
    return $true
}

# Function to check and manage firewall status
function Manage-Firewall {
    try {
        $firewallStatus = Get-NetFirewallProfile | Select-Object -ExpandProperty Enabled
        if ($firewallStatus -contains $true) {
            Log-Message "Firewall is currently enabled. Disabling all profiles..."
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
            Log-Message "Firewall has been disabled."
        } else {
            Log-Message "Firewall is already disabled. No action needed."
        }
        Log-Message "Firewall check complete."
        return $true
    } catch {
        Log-Message "Error managing firewall: $_"
        return $false
    }
}

function Manage-Partitions {
    param (
        [Parameter(Mandatory=$true)]
        [string]$partition_config
    )

    try {
        Log-Message "Starting partition management"
        Log-Message "Partition config: $partition_config"

        if ([string]::IsNullOrEmpty($partition_config) -or $partition_config -eq "[]") {
            Log-Message "Partition config is empty. Skipping partition management."
            return $true
        }

        $partitionConfig = ConvertFrom-Json $partition_config -ErrorAction Stop
        Log-Message "Parsed partition config: $($partitionConfig | ConvertTo-Json -Depth 10)"

        # Get all non-system disks
        $availableDisks = Get-Disk | Where-Object { $_.Number -ne 0 } | Sort-Object Number

        $configIndex = 0
        $allDisksLabeled = $true

        foreach ($disk in $availableDisks) {
            if ($configIndex -ge $partitionConfig.Count) {
                Log-Message "All configurations applied. Exiting loop."
                break
            }

            $diskNumber = $disk.Number
            Log-Message "Processing Disk $diskNumber"

            # Check if disk is already initialized and has partitions
            $existingPartitions = Get-Partition -DiskNumber $diskNumber -ErrorAction SilentlyContinue
            
            if ($disk.PartitionStyle -eq 'RAW') {
                Log-Message "Initializing Disk $diskNumber"
                Initialize-Disk -Number $diskNumber -PartitionStyle GPT -ErrorAction Stop
                Log-Message "Disk $diskNumber initialized successfully"
                $existingPartitions = @()
            }

            # Skip system reserved partition if it exists
            $partitionToCheck = if ($existingPartitions.Count -gt 1) { $existingPartitions[1] } else { $existingPartitions[0] }

            $config = $partitionConfig[$configIndex]
            $desiredLabel = $config.label

            if ($partitionToCheck -and (Get-Volume -Partition $partitionToCheck).FileSystemLabel -eq $desiredLabel) {
                Log-Message "Disk $diskNumber already has the label $desiredLabel. Skipping."
                $configIndex++
                continue
            }

            $allDisksLabeled = $false

            # If disk has unallocated space, create new partition
            if ((Get-Partition -DiskNumber $diskNumber | Measure-Object -Property Size -Sum).Sum -lt $disk.Size) {
                $desiredDriveLetter = $config.drive_letter

                # Check if the desired drive letter is already in use
                $existingVolume = Get-Volume -DriveLetter $desiredDriveLetter -ErrorAction SilentlyContinue
                if ($existingVolume) {
                    Log-Message "Drive letter $desiredDriveLetter is already in use. Attempting to find an available drive letter."
                    $availableDriveLetters = 68..90 | ForEach-Object { [char]$_ } | Where-Object { (Get-Volume -DriveLetter $_ -ErrorAction SilentlyContinue) -eq $null }
                    if ($availableDriveLetters.Count -eq 0) {
                        throw "No available drive letters found."
                    }
                    $desiredDriveLetter = $availableDriveLetters[0]
                    Log-Message "Using alternative drive letter: $desiredDriveLetter"
                }

                Log-Message "Creating new partition on Disk $diskNumber"
                $newPartition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter $desiredDriveLetter -ErrorAction Stop
                
                Log-Message "Formatting volume $desiredDriveLetter with label $desiredLabel"
                Format-Volume -DriveLetter $desiredDriveLetter -FileSystem NTFS -NewFileSystemLabel $desiredLabel -Confirm:$false -ErrorAction Stop
            }
            else {
                Log-Message "Disk $diskNumber has no unallocated space. Skipping partition creation."
            }

            $configIndex++
        }

        if ($allDisksLabeled) {
            Log-Message "All disks are already labeled and partitioned. No changes made."
        }
        else {
            Log-Message "Partition management complete."
        }
        
        return $true
    } catch {
        Log-Message "Error managing partitions: $_"
        Log-Message "Error details: $($_.Exception.Message)"
        Log-Message "Error stack trace: $($_.ScriptStackTrace)"
        return $false
    }
}

# Function to install Azure Agent
function Install-AzAgent {
    param (
        [string]$DeploymentGroupName
    )
    $ErrorActionPreference = "Stop"
    # Check if the script is running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Run command in an administrator PowerShell prompt"
    }
    # Check PowerShell version
    if ($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))) {
        throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell."
    }
    # Create azagent directory if it doesn't exist
    if (-NOT (Test-Path "$env:SystemDrive\azagent")) {
        mkdir "$env:SystemDrive\azagent"
    }
    cd "$env:SystemDrive\azagent"
    # Create a new folder for the agent
    for ($i = 1; $i -lt 100; $i++) {
        $destFolder = "A" + $i.ToString()
        if (-NOT (Test-Path $destFolder)) {
            mkdir $destFolder
            cd $destFolder
            break
        }
    }
    $agentZip = "$PWD\agent.zip"
    $DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy
    $securityProtocol = @()
    $securityProtocol += [Net.ServicePointManager]::SecurityProtocol
    $securityProtocol += [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = $securityProtocol
    $WebClient = New-Object Net.WebClient
    $Uri = 'https://vstsagentpackage.azureedge.net/agent/3.245.0/vsts-agent-win-x64-3.245.0.zip'
    # Configure proxy if needed
    if ($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri))) {
        $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True)
    }
    # Download the agent
    $WebClient.DownloadFile($Uri, $agentZip)
    # Extract the downloaded zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, "$PWD")
    # Configure the agent
    .\config.cmd --deploymentgroup --deploymentgroupname $DeploymentGroupName --agent $env:COMPUTERNAME --runasservice --work '_work' --url $azureDevOpsUrl --projectname 'QSight' --auth PAT --token $azureDevOpsPat --unattended
    # Clean up
    Remove-Item $agentZip
}

# Function to install Azure Agent and handle logging
function Set-AzureAgent {
    try {
        Install-AzAgent -DeploymentGroupName $deploymentGroupName
        Log-Message "Azure Agent installed successfully for deployment group: $deploymentGroupName"
        return $true
    } catch {
        Log-Message "Error installing Azure Agent: $_"
        return $false
    }
}


# Function to change hostname
function Change-Hostname {
    $currentHostname = $env:COMPUTERNAME
    Log-Message "Current hostname: $currentHostname"
    Log-Message "Desired hostname: $desiredHostname"
    if ($currentHostname -ne $desiredHostname) {
        try {
            Rename-Computer -NewName $desiredHostname -Force -ErrorAction Stop
            Log-Message "Hostname successfully changed to $desiredHostname"
            Log-Message "Hostname change complete. Restart required."
            return $true
        } catch {
            Log-Message "Error changing hostname: $_"
            return $false
        }
    } else {
        Log-Message "Hostname is already $desiredHostname. No change needed."
        return $false
    }
}

# Function to join domain
function Join-Domain {
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    if (-not $computerSystem.PartOfDomain) {
        try {
            Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $dcIP
            Clear-DnsClientCache
            Log-Message "DNS settings updated to point to Domain Controller ($dcIP) and DNS cache cleared"

            $maxAttempts = 30
            $attempt = 0
            do {
                $attempt++
                Log-Message "Attempting to contact DC (Attempt $attempt of $maxAttempts)"
                $pingResult = Test-NetConnection -ComputerName $dcIP -Port 389 -WarningAction SilentlyContinue
                if (-not $pingResult.TcpTestSucceeded) {
                    Start-Sleep -Seconds 10
                }
            } while (-not $pingResult.TcpTestSucceeded -and $attempt -lt $maxAttempts)

            if (-not $pingResult.TcpTestSucceeded) {
                Log-Message "Failed to contact DC after $maxAttempts attempts. Exiting."
                return $false
            }

            $dnsResult = Resolve-DnsName $domainName -ErrorAction Stop
            Log-Message "Successfully resolved $domainName"

            $credential = New-Object System.Management.Automation.PSCredential($username, $password)
            Add-Computer -DomainName $domainName -OUPath "${ou_path}" -Credential $credential -Verbose
            Log-Message "Successfully joined the domain $domainName"
            Log-Message "Domain join complete. Restart required."
            return $true
        } catch {
            Log-Message "Error joining domain: $_"
            return $false
        }
    } else {
        Log-Message "Already part of a domain. Skipping domain join."
        return $true
    }
}

# Main execution logic
$changesRequired = $false

# Check hostname and domain status
$hostnameOrDomainChangeRequired = Check-HostnameAndDomain
if ($hostnameOrDomainChangeRequired) {
    $changesRequired = $true
}

# Execute Phase 1
if (-not (Test-Path $phase1CompleteFlag)) {
    Log-Message "Starting Phase 1: Cloud DNS, Firewall, Partitions, Time Zone, and Hostname"
    $phase1Success = $true
    
    $phase1Success = $phase1Success -and (Set-VMTimeZone)
    $phase1Success = $phase1Success -and (Set-VmDnsServer -dnsServer $dnsServer)
    $phase1Success = $phase1Success -and (Manage-Firewall)
    $phase1Success = $phase1Success -and (Manage-Partitions -partition_config $partitionConfig)
    
    $hostnameChanged = Change-Hostname
    if ($hostnameChanged) {
        Log-Message "Hostname was changed. Creating Phase 1 flag and restarting the system immediately."
        New-Item -Path $phase1CompleteFlag -ItemType File -Force | Out-Null
        Restart-Computer -Force
        exit
    }

    $phase1Success = $phase1Success -and (-not $hostnameChanged)

    if ($phase1Success) {
        New-Item -Path $phase1CompleteFlag -ItemType File -Force | Out-Null
        Log-Message "Phase 1 completed successfully. Flag created."
        $changesRequired = $true
    } else {
        Log-Message "Phase 1 failed. Please check the logs and retry."
        exit 1
    }
} else {
    Log-Message "Phase 1 already completed. Skipping."
}

# Execute Phase 2
if (-not (Test-Path $phase2CompleteFlag)) {
    $computerSystem = Get-CimInstance Win32_ComputerSystem
    if (-not $computerSystem.PartOfDomain) {
        Log-Message "Starting Phase 2: Azure Agent Installation and Domain Join"
        
        # Install Azure Agent first
        $azureAgentSuccess = Set-AzureAgent
        if (-not $azureAgentSuccess) {
            Log-Message "Azure Agent installation failed. Please check the logs and retry."
            exit 1
        }
        Log-Message "Azure Agent installed successfully."
        
        # Proceed with domain join
        $joinSuccess = Join-Domain
        if ($joinSuccess) {
            New-Item -Path $phase2CompleteFlag -ItemType File -Force | Out-Null
            Log-Message "Phase 2 complete. Azure Agent installed and Domain joined successfully. Flag created."
            $changesRequired = $true
        } else {
            Log-Message "Phase 2 failed. Domain join unsuccessful. Please check the logs and retry."
            exit 1
        }
    } else {
        Log-Message "Already part of a domain. Skipping Phase 2."
        New-Item -Path $phase2CompleteFlag -ItemType File -Force | Out-Null
        Log-Message "Phase 2 completion flag created (already in domain)."
    }
} else {
    Log-Message "Phase 2 already completed. Skipping."
}

if ($changesRequired) {
    Log-Message "Changes were made. Restarting the system immediately."
    Log-Message "Script execution complete. Initiating restart..."
    Restart-Computer -Force
} else {
    Log-Message "No changes required. Script execution complete."
}