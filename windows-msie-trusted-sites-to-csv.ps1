$csv = 'C:\TEMP\Scripts\websites.csv'

# (1) Intranet zone, (2) Trusted Sites zone, (3) Internet zone, and (4) Restricted Sites zone.
# https://blogs.msdn.microsoft.com/askie/2012/06/05/how-to-configure-internet-explorer-security-zone-sites-using-group-polices/
$types = @{1="Intranet zone"; 2="Trusted Sites zone"; 3="Internet zone"; 4="Restricted Sites zone"}

$internetTLDs = @("ch","be","se","us","eu","lu","com","net","org")

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey"

$table = New-Object system.Data.DataTable "Sites"

$colURI = New-Object system.Data.DataColumn URI,([string])
$colDomain = New-Object system.Data.DataColumn Domain,([string])
$colNetwork = New-Object system.Data.DataColumn Network,([string])
$colTypeNumber = New-Object system.Data.DataColumn TypeNumber,([string])
$colTypeDescr = New-Object system.Data.DataColumn TypeDescr,([string])

$table.columns.add($colURI)
$table.columns.add($colDomain)
$table.columns.add($colNetwork)
$table.columns.add($colTypeNumber)
$table.columns.add($colTypeDescr)

$key = (Get-ItemProperty $path)
$key.PSObject.Properties | ForEach-Object {
   $uri = $_.Name
   $value = $_.Value

   if($value -isnot [String]) {
       Write-Output "Found a non-string value. Skipping item."

       #$_.Value | fl *

       # https://stackoverflow.com/questions/7760013/why-does-continue-behave-like-break-in-a-foreach-object
       #continue
       return
   }

   try {
       $valueInt = $value.ToInt32($Null)
   }
   catch {
       Write-Output "ToInt32() failed. Skipping item."

       #$_.Value | fl *

       return
   }

   $zone = $types[$valueInt]

   $network = ''

   $uriRaw = $uri
   $helper = $uriRaw.Split('/')
   $uriRaw = $helper[0]
   $helper = $uriRaw.Split('.')
   if($helper.length -gt 1) {
       $tld = $helper[-1]
       $domain = $helper[-2]

       $domain = "$domain.$tld"

       if($internetTLDs.Contains($tld)) {
           $network = 'Internet'
       }
       else {
           Write-Output "TLD '$tld' for domain '$uri' not found in internetTLDs"
       }

       # Special Cases
       if($domain -eq 'intranet.tld') {
           $network = 'Intranet'
       }

       if($tld -eq 'dom') {
           $network = 'Intranet'
       }
   }
   else {
       $domain = $uriRaw
       $network = 'Intranet'
   }

   #Write-Host $_.Name ' = ' $_.Value '(' $zone ')'

   $row = $table.NewRow()

   $row.URI = $uri
   $row.Domain = $domain
   $row.Network = $network
   $row.TypeNumber= $valueInt
   $row.TypeDescr= $zone

   $table.Rows.Add($row)
}

$table | Sort-Object TypeNumber | format-table
$table | Sort-Object TypeNumber | Export-CSV -Path $csv
