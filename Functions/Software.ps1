$bios = Get-CimInstance -ClassName Win32_BIOS
function Get-SerialNumber {
    return $bios.SerialNumber
}
function Get-BiosVersion {
    return $bios.SMBIOSBIOSVersion
}

function Get-WindowsVersion{
    return (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId

}
