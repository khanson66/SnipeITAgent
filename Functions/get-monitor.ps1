#https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
function Get-Monitor {

  #Grabs the Monitor objects from WMI
  $Monitors = Get-CimInstance -Namespace root/WMI -ClassName "WmiMonitorID" -ErrorAction SilentlyContinue
    
  #Creates an empty string to hold the formated output
  $Monitor_Array = ""

  #Takes each monitor object found and runs the following code:
  ForEach ($Monitor in $Monitors) {
      
    #Grabs respective data and converts it from ASCII encoding and removes any trailing ASCII null values
    If ($null -ne [System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)) {
      $Mon_Model = ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)", "")
    }
    else {
      $Mon_Model = $null
    }
    $Mon_Serial_Number = ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)", "")

    #Appends the object to the array
    $Monitor_Array += "$Mon_Model($Mon_Serial_Number)`n"
  
  } #End ForEach Monitor
    
  #Outputs the Array
  return $Monitor_Array.trim("`n")
    
}
