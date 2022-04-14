# Windows Uri
注册表
```reg
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\pixiv]
@="URL:Pixiv protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\pixiv\DefaultIcon]
@="pixez.exe"

[HKEY_CLASSES_ROOT\pixiv\Shell]

[HKEY_CLASSES_ROOT\pixiv\Shell\Open]

[HKEY_CLASSES_ROOT\pixiv\Shell\Open\Command]
@="\"<Path to Pixez.exe>\" --uri \"%1\""
```