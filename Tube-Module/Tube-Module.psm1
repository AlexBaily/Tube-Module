
class TubeLine {

    [String]$LineName
    [String]$LineID
    [String]$Service

    TubeLine([String]$id, [String]$LineName, [String]$Service) {
        $this.LineID = $id
        $this.LineName = $LineName
        $this.Service = $Service
    }

    
}
class TubeStation {

    [String]$StationName
    [String]$StationID
    [String]$TubeLine

    TubeStation([String]$id, [String]$StationName, [String]$TubeLine) {
        $this.StationID = $id
        $this.StationName = $StationName
        $this.TubeLine = $TubeLine

    }
}
<# 
 .Synopsis
    Get-TubeStation gets a list of tube stations from TFL based on the line.
  
 .Description
    Get-TubeStation accepts an array of LineNames, this will then go to the TFL api
    and get a list of the tube stations for the specified tube line.

    This does accept via pipeline or not. It can be fed through from Get-TubeLine.
    
 .Example
    Get-TubeStation -LineName "district"

    StationName                                      StationID   TubeLine
    -----------                                      ---------   --------
    Acton Town Underground Station                   940GZZLUACT District
    Aldgate East Underground Station                 940GZZLUADE District
    Bromley-by-Bow Underground Station               940GZZLUBBB District
    .....

 .Example
    Get-TubeLine | Get-TubeStation
 
 .Example
    "district", "central" | Get-Tubestation
 
 .Example
    Get-TubeStation -LineName "district","central"

#>
function Get-TubeStation {

    [CmdletBinding()]
    param(
        [Parameter (
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [String[]]$LineName,
        [String]$ErrorsToLogFile
    )

    Begin {

    }

    Process {

        foreach($line in $LineName) {
            
            try { 
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $apiUrl = "https://api.tfl.gov.uk/Line/$line/StopPoints"
                $stationInLine = Invoke-RestMethod -Method Get -Uri $apiUrl
                $stationArray = New-Object System.Collections.ArrayList
            }
            catch {

            }

            foreach($station in $stationInLine) {
                $name = $station.commonName
                $id = $station.id
                [void]$stationArray.Add([TubeStation]::new($id, $name, $line))
           
            }

            return $stationArray
        }
    }

    End { 

    }
}
<# 
 .Synopsis
  
 .Description

 .Example

#>
function Get-TubeLine {

    [CmdletBinding()]
    param(
        [Parameter (
            ValueFromPipeline = $true,
            Position = 0
        )]
        [String[]]$LineName,
        [String[]]$ErrorsToLogFile,
        [switch]$All,
        [switch]$List
    )

    Begin {
       try { 
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $apiUrl = "https://api.tfl.gov.uk/Line/Mode/tube/Status"
            $underground = Invoke-RestMethod -Method Get -Uri $apiUrl
            $lineArray = New-Object System.Collections.ArrayList
       }
       catch {

       }
    }

    Process {
        if(!$List) {
            foreach($line in $underground) {
                $id = $line.id
                $name = $line.name
                $service = $line | select -ExpandProperty LineStatuses |
                    select -ExpandProperty statusSeverityDescription
                [void]$lineArray.Add([TubeLine]::new($id, $name, $service))

            }
        }

    }

    End {

        if($List){
            $underground | % {$_.Name}
        }
        else {
            return $lineArray
        }

    }

}