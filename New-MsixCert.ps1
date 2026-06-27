[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]
  $Subject,
  [Parameter(Mandatory)]
  [string]
  $FriendlyName,
  [Parameter()]
  [string]
  $Password
)

$ErrorActionPreference = 'Stop'

while (-not $Password) {
  $Password = Read-Host -Prompt '请输入证书密码'
}

$Private:TempFile = New-TemporaryFile
try {
  $Private:Cert = New-SelfSignedCertificate `
    -Type CodeSigningCert `
    -KeyUsage DigitalSignature `
    -CertStoreLocation 'Cert:\CurrentUser\My' `
    -Subject $Subject `
    -FriendlyName $FriendlyName `
    -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.3', '2.5.29.19={text}') 
  try {

    $Private:PfxPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    $Private:PfxFile = Export-PfxCertificate -Cert $Cert -Password $PfxPassword -FilePath $TempFile

    if ($PSVersionTable.PSEdition -eq 'Core') {
      $Private:Raw = $PfxFile | Get-Content -Raw -AsByteStream
    }
    else {
      $Private:Raw = $PfxFile | Get-Content -Raw -Encoding 'Byte'
    }

    [System.Convert]::ToBase64String($Raw)
  }
  finally {
    $Cert | Remove-Item
  }
}
finally {
  $TempFile | Remove-Item
}
