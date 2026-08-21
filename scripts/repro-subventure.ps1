Set-Location "d:\Project Compass\project_TrackerPro"
$base = "http://127.0.0.1:5194/api/v1/clients"

$createBody = @{
  name = "SVRepro2-" + (Get-Date -Format "HHmmss")
  industry = "Technology"
  clientType = "NEW"
  contactName = "Cust SPOC"
  contactEmail = "c@acme.co"
  contactPhone = "+91 9000000001"
  contactDesignation = "M"
  contactType = "Primary"
  city = "Mumbai"
  country = "India"
  businessType = "Enterprise"
  subVentures = @(@{ name = "Existing Div"; contacts = @(@{ name = "Div1 SPOC"; email = "d1@acme.co"; phone = "+91 9111000001"; designation = "L"; contactType = "Primary" }) })
  contacts = @(@{ name = "Cust SPOC"; email = "c@acme.co"; phone = "+91 9000000001"; designation = "M"; contactType = "Primary" })
} | ConvertTo-Json -Depth 6

$cr = Invoke-WebRequest -Uri $base -Method Post -Body $createBody -ContentType "application/json" -UseBasicParsing
$created = $cr.Content | ConvertFrom-Json
$cid = $created.data.id
Write-Host "CREATED id=$cid"

$updateBody = @{
  subVentures = @(
    @{ name = "Existing Div"; contacts = @(@{ name = "Div1 SPOC"; email = "d1@acme.co"; phone = "+91 9111000001"; designation = "L"; contactType = "Primary" }) },
    @{ name = "New Div B"; contacts = @(@{ name = "Div2 SPOC"; email = "d2@acme.co"; phone = "+91 9112000002"; designation = "L"; contactType = "Primary" }) }
  )
} | ConvertTo-Json -Depth 6

try {
  $ur = Invoke-WebRequest -Uri "$base/$cid" -Method Put -Body $updateBody -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
  Write-Host "UPDATE_STATUS=$($ur.StatusCode)"
} catch {
  Write-Host "UPDATE_FAILED"
  if ($_.Exception.Response) {
    $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    Write-Host $sr.ReadToEnd()
  }
}
