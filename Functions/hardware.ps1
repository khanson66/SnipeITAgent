function Get-Network {
    $output = ""
    foreach ($net in Get-NetAdapter -Physical | Where-Object -FilterScript { $_.ifDesc -notmatch "Loopback*" }) {
        $output += $net.Name + " (" + $net.LinkLayerAddress.Replace("-", ":") + ")" 
        if ($net.DeviceWakeUpEnable) {
            $output += " WoL Enabled"
        }
        $output += "`n"
    }
    return $output.trim("`n")
}

function get-cpu {
    $cpu = Get-CimInstance -ClassName CIM_Processor
    $output = ""
    foreach ($c in $cpu) {
        $output += $cpu.Name + "`n"
    }
    return $output.trim("`n")
}


function Get-Memory {

    $MemoryType = @{
        0  = "Unknown"
        20 = "DDR"
        21 = "DDR2"
        22 = "DDR2 FB-DIMM"
        24 = "DDR3"
        23 = "FBD2"
        25 = "DDR4"
        26 = "DDR4"
    }
    $output = ""
    $CIMMemory = Get-CIMINStance CIM_PhysicalMemory
    foreach ($mem in $CIMMemory) {
        $PhysicalMemory = [Math]::Round((($mem | Measure-Object -Property capacity -sum).sum / 1GB), 2)
        $MemoryTypeCode = $mem.SMBIOSMemoryType
        
        $output += "$PhysicalMemory GB" + " " + $MemoryType[[int]$MemoryTypeCode] + " @ " + $mem.ConfiguredClockSpeed + "`n"
    }
    return $output.trim("`n")
    
}


function Get-Diskinfo {

    $output = ""
    Get-CimInstance Win32_Diskdrive -PipelineVariable disk -Filter "MediaType=`"Fixed hard disk media`"" |
    Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition -PipelineVariable partition |
    Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk | Sort-Object -Property "DeviceID" |ForEach-Object -Process{
        $total = [Math]::round((($_.size) / 1GB),2)
        $used = [Math]::round((($_.freespace) / 1GB),2)
        $type = Get-PhysicalDisk -SerialNumber $disk.SerialNumber
        $output += $_.DeviceID + " " + $used + " GB/" + $total + " GB Free ("+$type.MediaType+")`n" 

    }
    return $output.trim("`n")
    
}

