[Dirs]
Name: {app}\locale
Name: {app}\locale\de
Name: {app}\locale\de\LC_MESSAGES
[Files]
Source: locale\de\LC_MESSAGES\default.mo; DestDir: {app}\locale\de\LC_MESSAGES
Source: ConfigUtil.exe; DestDir: {app}
Source: ntfslink.dll; DestDir: {app}; Flags: regserver uninsrestartdelete
[Icons]
Name: {group}\Configure NTFS Link; Filename: {app}\ConfigUtil.exe; WorkingDir: {app}; IconFilename: {app}\ConfigUtil.exe; IconIndex: 0; Flags: createonlyiffileexists; Languages: English
Name: {group}\NTFS Link Homepage; Filename: {app}\NTFSLink.url
Name: {group}\NTFS Link konfigurieren; Filename: {app}\ConfigUtil.exe; WorkingDir: {app}; IconFilename: {app}\ConfigUtil.exe; IconIndex: 0; Flags: createonlyiffileexists; Languages: Deutsch
Name: {group}\Uninstall NTFS Link; Filename: {uninstallexe}; Languages: English
Name: {group}\NTFS Link deinstallieren; Filename: {uninstallexe}; Languages: Deutsch
[Languages]
Name: English; MessagesFile: compiler:Default.isl
Name: Deutsch; MessagesFile:..\Setup\lang\german-2-4.0.5.isl
[Setup]
OutputDir=..\
SourceDir=..\ntfslink-temp
OutputBaseFilename=ntfslink
DefaultDirName={pf}\NTFS Link
AlwaysRestart=yes
Compression=bzip
AppCopyright=Copyright ©2004 by Michael Elsdörfer
AppName=NTFS Link
AppVerName=NTFS Link 2.0
PrivilegesRequired=poweruser
MinVersion=0,5.0.2195
UsePreviousUserInfo=false
AllowNoIcons=true
ShowLanguageDialog=yes
SolidCompression=true
LicenseFile=..\Setup\gpl.txt
ChangesAssociations=true
DefaultGroupName=NTFS Link
AppID={BE0CA065-5BDF-44D6-8BB1-1CA922EFE575}
[INI]
Filename: {app}\NTFSLink.url; Section: InternetShortcut; Key: URL; String: http://www.elsdoerfer.net/ntfslink/
[UninstallDelete]
Type: files; Name: {app}\NTFSLink.url
[Registry]
Root: HKLM; Subkey: Software\elsdoerfer.net\NTFS Link\Config; Flags: uninsdeletekey
