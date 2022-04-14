#Requires -Version 5.0

if (Test-Path HKCU:\Software\Classes\pixiv) {
  if ($Host.UI.PromptForChoice('Uri 注销', "我们发现您已经注册了 ""pixiv"" Uri, `n您是否要注销它?", @('&Yes', '&No'), 1) -eq 0) {
    Remove-Item -Path HKCU:\Software\Classes\pixiv -Recurse | Out-Null

    Write-Host "我们已经成功的注销了pixiv Uri" -ForegroundColor Green
  }
}
if ($Host.UI.PromptForChoice('Uri 注册', "这个脚本可以帮助您注册 ""pixiv"" Uri并将其引导至pixez, `n您是否要继续执行这个脚本?", @('&Yes', '&No'), 1) -eq 0) {
  $program = Get-Item '.\pixez.exe'
  if (!$program.Exists) {
    throw "找不到pixez.exe"
  }

  New-Item -Path HKCU:\Software\Classes\pixiv -Value "URL:Pixiv protocol" | Out-Null
  New-ItemProperty -Path HKCU:\Software\Classes\pixiv -Name "URL Protocol" -PropertyType String -Value "" | Out-Null
  New-Item -Path HKCU:\Software\Classes\pixiv\DefaultIcon -Value "pixez.exe" | Out-Null
  New-Item -Path HKCU:\Software\Classes\pixiv\Shell | Out-Null
  New-Item -Path HKCU:\Software\Classes\pixiv\Shell\Open | Out-Null
  New-Item -Path HKCU:\Software\Classes\pixiv\Shell\Open\Command -Value """$($program.FullName)"" --uri ""%1""" | Out-Null

    Write-Host "我们已经成功的注册了pixiv Uri" -ForegroundColor Green
}

Write-Host Byebye.