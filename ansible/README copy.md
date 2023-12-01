
# Enable PowerShell Remoting
Enable-PSRemoting -Force

# Set WinRM service startup type to automatic
Set-Service WinRM -StartupType 'Automatic'

# Configure WinRM settings
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
Set-Item -Path 'WSMan:\localhost\Service\AllowUnencrypted' -Value $true
Set-Item -Path 'WSMan:\localhost\Service\Auth\Basic' -Value $true
Set-Item -Path 'WSMan:\localhost\Service\Auth\CredSSP' -Value $true

# Replace the IP address with your hostname or DNS
$hostnameOrDNS = "ec2-52-55-101-89.compute-1.amazonaws.com"
$cert = New-SelfSignedCertificate -DnsName $hostnameOrDNS -CertStoreLocation "cert:\LocalMachine\My"
$listenerParams = @{
    Address = '*'
    Transport = 'HTTPS'
    Hostname = $hostnameOrDNS
    CertificateThumbprint = $cert.Thumbprint
}
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@$listenerParams"

# Create a firewall rule to allow WinRM HTTPS inbound
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow

# Configure trusted hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Allow Local Account Token Filter Policy
New-ItemProperty -Name LocalAccountTokenFilterPolicy -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -PropertyType DWord -Value 1 -Force

# Set Execution Policy
Set-ExecutionPolicy Unrestricted -Force

# Restart WinRM service
Restart-Service WinRM

# Verify WinRM listener configuration
winrm enumerate winrm/config/Listener

Set-Item WSMan:\localhost\Service\auth\Basic $true
winrm get winrm/config
New-SelfSignedCertificate -DnsName "ec2-52-55-101-89.compute-1.amazonaws.com" -CertStoreLocation Cert:\LocalMachine\My



Step1: Create Certificate
New-SelfSignedCertificate -DnsName "DNS Name" -CertStoreLocation Cert:\LocalMachine\My

Step2:
Whitelist port 5985(winrm-http) and 5986(winrm-https) in the security group of the the windows server.

Step3: Create HTTPS Listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="ec2-52-55-101-89.compute-1.amazonaws.com"; CertificateThumbprint="92DCCC2D346B0DDCD86DD50DEB8B7DFB1B172A4A"}'


Step4:Add  new firewall rule for 5986

netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986


Step5: Check the listener and make sure https listener is there.
winrm e winrm/config/Listener

Check The Service
winrm get winrm/config
Make sure the Basic Auth is set to true, if not then execute below commands.
Set-Item -Force WSMan:\localhost\Service\auth\Basic $true


