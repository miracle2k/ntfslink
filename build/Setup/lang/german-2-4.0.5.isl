; *** Inno Setup version 4.0.5+ German messages  ***
; *** Translated by Michael Reitz / Roland Ruder ***
; *** innosetup@assimilate.de / info@rr4u.de     ***
;
; Diese Übersetzung hält sich an die neue deutsche Rechtschreibung.
;
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; $jrsoftware: issrc/Files/Default.isl,v 1.32 2003/06/18 19:24:07 jr Exp $

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
;DialogFontName=MS Shell Dlg
;DialogFontSize=8
;DialogFontStandardHeight=13
;TitleFontName=Arial
;TitleFontSize=29
;WelcomeFontName=Verdana
;WelcomeFontSize=12
;CopyrightFontName=Arial
;CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=Setup
SetupWindowTitle=Setup - %1
UninstallAppTitle=Entfernen
UninstallAppFullTitle=%1 entfernen

; *** Misc. common
InformationTitle=Information
ConfirmTitle=Bestätigen
ErrorTitle=Fehler

; *** SetupLdr messages
SetupLdrStartupMessage=%1 wird jetzt installiert. Wollen Sie fortfahren?
LdrCannotCreateTemp=Es konnte keine temporäre Datei erstellt werden. Setup abgebrochen
LdrCannotExecTemp=Die Datei konnte nicht im temporären Ordner ausgeführt werden. Setup abgebrochen

; *** Startup error messages
LastErrorMessage=%1.%n%nFehler %2: %3
SetupFileMissing=Die Datei %1 fehlt im Installations-Ordner. Bitte beheben Sie das Problem, oder besorgen Sie sich eine neue Kopie des Programms.
SetupFileCorrupt=Die Setup-Dateien sind beschädigt. Besorgen Sie sich bitte eine neue Kopie des Programms.
SetupFileCorruptOrWrongVer=Die Setup-Dateien sind beschädigt oder inkompatibel zu dieser Version des Setups. Bitte beheben Sie das Problem, oder besorgen Sie sich eine neue Kopie des Programms.
NotOnThisPlatform=Dieses Programm kann nicht unter %1 ausgeführt werden.
OnlyOnThisPlatform=Dieses Programm muss unter %1 ausgeführt werden.
WinVersionTooLowError=Dieses Programm benötigt %1 Version %2 oder höher.
WinVersionTooHighError=Dieses Programm kann nicht unter %1 Version %2 oder höher installiert werden.
AdminPrivilegesRequired=Sie müssen als Administrator angemeldet sein, um dieses Programm zu installieren.
PowerUserPrivilegesRequired=Sie müssen als Administrator oder als Mitglied der Hauptbenutzer-Gruppe angemeldet sein, um dieses Programm zu installieren.
SetupAppRunningError=Das Setup hat entdeckt, dass %1 zur Zeit ausgeführt wird.%n%nBitte schließen Sie jetzt alle laufenden Instanzen, und klicken Sie auf "OK", um fortzufahren, oder auf "Abbrechen", um zu beenden.
UninstallAppRunningError=Die Deinstallation hat entdeckt, dass %1 zur Zeit ausgeführt wird.%n%nBitte schließen Sie jetzt alle laufenden Instanzen, und klicken Sie auf "OK", um fortzufahren, oder auf "Abbrechen", um zu beenden.

; *** Misc. errors
ErrorCreatingDir=Das Setup konnte den Ordner "%1" nicht erstellen
ErrorTooManyFilesInDir=Das Setup konnte eine Datei im Ordner "%1" nicht erstellen, weil er zu viele Dateien enthält

; *** Setup common messages
ExitSetupTitle=Setup verlassen
ExitSetupMessage=Das Setup ist noch nicht abgeschlossen. Wenn Sie jetzt beenden, wird das Programm nicht installiert.%n%nSie können das Setup-Programm zu einem späteren Zeitpunkt nochmals ausführen, um die Installation zu vervollständigen.%n%nSetup verlassen?
AboutSetupMenuItem=&Über Setup ...
AboutSetupTitle=Über Setup
AboutSetupMessage=%1 Version %2%n%3%n%n%1 Internet-Seite:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Zurück
ButtonNext=&Weiter >
ButtonInstall=&Installieren
ButtonOK=OK
ButtonCancel=Abbrechen
ButtonYes=&Ja
ButtonYesToAll=J&a für Alle
ButtonNo=&Nein
ButtonNoToAll=N&ein für Alle
ButtonFinish=&Fertigstellen
ButtonBrowse=&Durchsuchen ...

; *** "Select Language" dialog messages
SelectLanguageTitle=Setup-Sprache auswählen
SelectLanguageLabel=Wählen Sie die Sprache aus, die während der Installation benutzt werden soll:

; *** Common wizard text
ClickNext="Weiter" zum Fortfahren, "Abbrechen" zum Verlassen.
BeveledLabel=

; *** "Welcome" wizard page
WelcomeLabel1=Willkommen zum [name] Setup-Assistenten
WelcomeLabel2=Er wird jetzt [name/ver] auf Ihren Computer installieren.%n%nSie sollten alle anderen Anwendungen beenden, bevor Sie mit dem Setup fortfahren.

; *** "Password" wizard page
WizardPassword=Passwort
PasswordLabel1=Diese Installation wird durch ein Passwort geschützt.
PasswordLabel3=Bitte geben Sie das Passwort ein, und klicken Sie danach auf "Weiter". Achten Sie auf korrekte Groß-/Kleinschreibung.
PasswordEditLabel=&Passwort:
IncorrectPassword=Das eingegebene Passwort ist nicht korrekt. Bitte versuchen Sie es noch einmal.

; *** "License Agreement" wizard page
WizardLicense=Lizenzvereinbarung
LicenseLabel=Lesen Sie bitte folgende, wichtige Informationen bevor Sie fortfahren.
LicenseLabel3=Lesen Sie bitte die folgenden Lizenzvereinbarungen. Benutzen Sie bei Bedarf die Bildlaufleiste oder drücken Sie die "Bild Ab"-Taste.
LicenseAccepted=Ich &akzeptiere die Vereinbarung
LicenseNotAccepted=Ich &lehne die Vereinbarung ab

; *** "Information" wizard pages
WizardInfoBefore=Information
InfoBeforeLabel=Lesen Sie bitte folgende, wichtige Informationen bevor Sie fortfahren.
InfoBeforeClickLabel=Klicken Sie auf "Weiter", sobald Sie bereit sind mit dem Setup fortzufahren.
WizardInfoAfter=Information
InfoAfterLabel=Lesen Sie bitte folgende, wichtige Informationen bevor Sie fortfahren.
InfoAfterClickLabel=Klicken Sie auf "Weiter", sobald Sie bereit sind mit dem Setup fortzufahren.

; *** "User Information" wizard page
WizardUserInfo=Benutzerinformationen
UserInfoDesc=Bitte tragen Sie Ihre Daten ein.
UserInfoName=&Name:
UserInfoOrg=&Organisation:
UserInfoSerial=&Seriennummer:
UserInfoNameRequired=Sie müssen einen Namen eintragen.

; *** "Select Destination Directory" wizard page
WizardSelectDir=Ziel-Ordner wählen
SelectDirDesc=Wohin soll [name] installiert werden?
SelectDirLabel=Bitte geben Sie an, in welchen Ordner Sie [name] installieren wollen, und klicken Sie danach auf "Weiter".
DiskSpaceMBLabel=Erforderlicher Speicherplatz: min. [mb] MB
ToUNCPathname=Das Setup kann nicht in einen UNC-Pfad installieren. Wenn Sie auf ein Netzlaufwerk installieren wollen, müssen Sie dem Netzwerkpfad einen Laufwerksbuchstaben zuordnen.
InvalidPath=Sie müssen einen vollständigen Pfad mit einem Laufwerksbuchstaben angeben; z.B.:%n%nC:\Beispiel%n%noder einen UNC-Pfad in der Form:%n%n\\Server\Freigabe
InvalidDrive=Das angegebene Laufwerk bzw. der UNC-Pfad existiert nicht oder es kann nicht darauf zugegriffen werden. Wählen Sie bitte einen anderen Ordner.
DiskSpaceWarningTitle=Nicht genug freier Speicherplatz
DiskSpaceWarning=Das Setup benötigt mindestens %1 KB freien Speicherplatz zum Installieren, aber auf dem ausgewählten Laufwerk sind nur %2 KB verfügbar.%n%nWollen Sie trotzdem fortfahren?
BadDirName32=Ordnernamen dürfen keine der folgenden Zeichen enthalten:%n%n%1
DirExistsTitle=Ordner existiert bereits
DirExists=Der Ordner:%n%n%1%n%n existiert bereits. Wollen Sie trotzdem in diesen Ordner installieren?
DirDoesntExistTitle=Ordner ist nicht vorhanden
DirDoesntExist=Der Ordner:%n%n%1%n%nist nicht vorhanden. Soll der Ordner erstellt werden?

; *** "Select Components" wizard page
WizardSelectComponents=Komponenten auswählen
SelectComponentsDesc=Welche Komponenten sollen installiert werden?
SelectComponentsLabel2=Wählen Sie die Komponenten aus, die Sie installieren möchten. Klicken Sie auf "Weiter", wenn sie bereit sind fortzufahren.
FullInstallation=Vollständige Installation
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Kompakte Installation
CustomInstallation=Benutzerdefinierte Installation
NoUninstallWarningTitle=Komponenten vorhanden
NoUninstallWarning=Das Setup hat festgestellt, dass die folgenden Komponenten bereits auf Ihrem Computer installiert sind:%n%n%1%n%nDiese nicht mehr ausgewählten Komponenten werden nicht vom Computer entfernt.%n%nWollen Sie trotzdem fortfahren?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=Die aktuelle Auswahl erfordert min. [mb] MB Speicherplatz.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Zusätzliche Aufgaben auswählen
SelectTasksDesc=Welche zusätzlichen Aufgaben sollen ausgeführt werden?
SelectTasksLabel2=Wählen Sie die zusätzlichen Aufgaben aus, die das Setup während der Installation von [name] ausführen soll, und klicken Sie danach auf "Weiter".

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=Startmenü-Ordner auswählen
SelectStartMenuFolderDesc=Wo soll das Setup die Programm-Verknüpfungen anlegen?
SelectStartMenuFolderLabel=Wählen Sie den Startmenü-Ordner, in dem das Setup die Programm-Verknüpfungen anlegen soll, und klicken Sie danach auf "Weiter".
NoIconsCheck=Keine Programm-Verknüpfungen erzeugen
MustEnterGroupName=Sie müssen einen Ordnernamen eingeben.
BadGroupName=Der Ordnername darf keine der folgenden Zeichen enthalten:%n%n%1
NoProgramGroupCheck2=&Keinen Ordner im Startmenü erstellen

; *** "Ready to Install" wizard page
WizardReady=Installation durchführen
ReadyLabel1=Das Setup ist jetzt bereit, [name] auf Ihren Computer zu installieren.
ReadyLabel2a=Klicken Sie auf "Installieren", um mit der Installation zu beginnen, oder auf "Zurück", um Ihre Einstellungen zu überprüfen oder zu ändern.
ReadyLabel2b=Klicken Sie auf "Installieren", um mit der Installation zu beginnen.
ReadyMemoUserInfo=Benutzerinformationen:
ReadyMemoDir=Ziel-Ordner:
ReadyMemoType=Setup-Typ:
ReadyMemoComponents=Ausgewählte Komponenten:
ReadyMemoGroup=Startmenü-Ordner:
ReadyMemoTasks=Zusätzliche Aufgaben:

; *** "Preparing to Install" wizard page
WizardPreparing=Vorbereitung der Installation
PreparingDesc=Das Setup bereitet die Installation von [name] auf diesen Computer vor.
PreviousInstallNotCompleted=Eine vorherige Installation/Deinstallation eines Programms wurde nicht abgeschlossen. Der Computer muss neu gestartet werden, um die Installation/Deinstallation zu beenden.%n%nStarten Sie das Setup nach dem Neustart Ihres Computers erneut, um die Installation von [name] durchzuführen.
CannotContinue=Das Setup kann nicht fortfahren. Bitte klicken Sie auf "Abbrechen" zum Verlassen.

; *** "Installing" wizard page
WizardInstalling=Installiere ...
InstallingLabel=Warten Sie bitte während [name] auf Ihren Computer installiert wird.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=Beenden des [name] Setup-Assistenten
FinishedLabelNoIcons=Setup hat die Installation von [name] auf Ihren Computer abgeschlossen.
FinishedLabel=Setup hat die Installation von [name] auf Ihren Computer abgeschlossen. Die Anwendung kann über die installierten Programm-Verknüpfungen gestartet werden.
ClickFinish=Klicken Sie auf "Fertigstellen", um das Setup zu beenden.
FinishedRestartLabel=Um die Installation von [name] abzuschließen, muss das Setup Ihren Computer neu starten. Wollen Sie jetzt neu starten?
FinishedRestartMessage=Um die Installation von [name] abzuschließen, muss das Setup Ihren Computer neu starten.%n%nWollen Sie jetzt neu starten?
ShowReadmeCheck=Ja, ich möchte die LIESMICH-Datei sehen
YesRadio=&Ja, Computer jetzt neu starten
NoRadio=&Nein, ich werde den Computer später neu starten
; used for example as 'MyProg.exe starten'
RunEntryExec=%1 starten
; used for example as 'Readme.txt anzeigen'
RunEntryShellExec=%1 anzeigen

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=Nächste Diskette einlegen
SelectDirectory=Ordner auswählen
SelectDiskLabel2=Legen Sie bitte Diskette %1 ein, und klicken Sie auf "OK".%n%nWenn sich die Dateien von dieser Diskette in einem anderen als dem angezeigten Ordner befinden, dann geben Sie bitte den korrekten Pfad ein oder klicken auf "Durchsuchen".
PathLabel=&Pfad:
FileNotInDir2=Die Datei "%1" befindet sich nicht in "%2". Bitte Ordner ändern oder richtige Diskette einlegen.
SelectDirectoryLabel=Geben Sie bitte an, wo die nächste Diskette eingelegt wird.

; *** Installation phase messages
SetupAborted=Setup konnte nicht abgeschlossen werden.%n%nBeheben Sie bitte das Problem, und starten Sie das Setup erneut.
EntryAbortRetryIgnore=Klicken Sie auf "Wiederholen" für einen weiteren Versuch, "Ignorieren", um trotzdem fortzufahren, oder "Abbrechen", um die Installation abzubrechen.

; *** Installation status messages
StatusCreateDirs=Ordner werden erstellt ...
StatusExtractFiles=Dateien werden ausgepackt ...
StatusCreateIcons=Verknüpfungen werden erstellt ...
StatusCreateIniEntries=INI-Einträge werden erstellt ...
StatusCreateRegistryEntries=Registry-Einträge werden erstellt ...
StatusRegisterFiles=Dateien werden registriert ...
StatusSavingUninstall=Deinstallations-Informationen werden gespeichert ...
StatusRunProgram=Installation wird beendet ...
StatusRollback=Änderungen werden rückgängig gemacht ...

; *** Misc. errors
ErrorInternal2=Interner Fehler: %1
ErrorFunctionFailedNoCode=%1 schlug fehl
ErrorFunctionFailed=%1 schlug fehl; Code %2
ErrorFunctionFailedWithMessage=%1 schlug fehl; Code %2.%n%3
ErrorExecutingProgram=Datei kann nicht ausgeführt werden:%n%1

; *** Registry errors
ErrorRegOpenKey=Registry-Schlüssel konnte nicht geöffnet werden:%n%1\%2
ErrorRegCreateKey=Registry-Schlüssel konnte nicht erstellt werden:%n%1\%2
ErrorRegWriteKey=Fehler beim Schreiben des Registry-Schlüssels:%n%1\%2

; *** INI errors
ErrorIniEntry=Fehler beim Erstellen eines INI-Eintrages in die Datei "%1".

; *** File copying errors
FileAbortRetryIgnore=Klicken Sie auf "Wiederholen" für einen weiteren Versuch, "Ignorieren", um diese Datei zu überspringen (nicht empfohlen), oder "Abbrechen", um die Installation abzubrechen.
FileAbortRetryIgnore2=Klicken Sie auf "Wiederholen" für einen weiteren Versuch, "Ignorieren", um trotzdem fortzufahren (nicht empfohlen), oder "Abbrechen", um die Installation abzubrechen.
SourceIsCorrupted=Die Quelldatei ist beschädigt
SourceDoesntExist=Die Quelldatei "%1" existiert nicht
ExistingFileReadOnly=Die vorhandene Datei ist schreibgeschützt.%n%nKlicken Sie auf "Wiederholen", um den Schreibschutz zu entfernen, "Ignorieren", um die Datei zu überspringen, oder "Abbrechen", um die Installation abzubrechen.
ErrorReadingExistingDest=Lesefehler in Datei:
FileExists=Die Datei ist bereits vorhanden.%n%nSoll sie überschrieben werden?
ExistingFileNewer=Die vorhandene Datei ist neuer als die Datei, die installiert werden soll. Es wird empfohlen die vorhandene Datei beizubehalten.%n%n Wollen Sie die vorhandene Datei beibehalten?
ErrorChangingAttr=Fehler beim Ändern der Datei-Attribute:
ErrorCreatingTemp=Fehler beim Erstellen einer Datei im Ziel-Ordner:
ErrorReadingSource=Fehler beim Lesen der Quelldatei:
ErrorCopying=Fehler beim Kopieren einer Datei:
ErrorReplacingExistingFile=Fehler beim Ersetzen einer vorhandenen Datei:
ErrorRestartReplace="Ersetzen nach Neustart" fehlgeschlagen:
ErrorRenamingTemp=Fehler beim Umbenennen einer Datei im Ziel-Ordner:
ErrorRegisterServer=DLL/OCX konnte nicht registriert werden: %1
ErrorRegisterServerMissingExport="DllRegisterServer Export" nicht gefunden
ErrorRegisterTypeLib=Typen-Bibliothek konnte nicht registriert werden: %1

; *** Post-installation errors
ErrorOpeningReadme=Fehler beim Öffnen der LIESMICH-Datei.
ErrorRestartingComputer=Setup konnte den Computer nicht neu starten. Bitte führen Sie den Neustart selbst durch.

; *** Uninstaller messages
UninstallNotFound=Die Datei "%1" existiert nicht. Entfernen der Anwendung fehlgeschlagen.
UninstallOpenError=Die Datei "%1" konnte nicht geöffnet werden. Entfernen der Anwendung fehlgeschlagen.
UninstallUnsupportedVer=Das Format der Deinstallations-Datei "%1" konnte nicht erkannt werden. Entfernen der Anwendung fehlgeschlagen
UninstallUnknownEntry=In der Deinstallations-Datei wurde ein unbekannter Eintrag (%1) gefunden
ConfirmUninstall=Sind Sie sicher, dass Sie %1 und alle zugehörigen Komponenten entfernen wollen?
OnlyAdminCanUninstall=Diese Installation kann nur von einem Benutzer mit Administrator-Rechten entfernt werden.
UninstallStatusLabel=Warten Sie bitte während %1 von Ihrem Computer entfernt wird.
UninstalledAll=%1 wurde erfolgreich von Ihrem Computer entfernt.
UninstalledMost=Entfernen von %1 beendet.%n%nEinige Komponenten konnten nicht entfernt werden. Diese können von Ihnen gelöscht werden.
UninstalledAndNeedsRestart=Um die Deinstallation von %1 abzuschließen, muss Ihr Computer neu gestartet werden.%n%nWollen Sie jetzt neu starten?
UninstallDataCorrupted="%1"-Datei ist beschädigt. Entfernen der Anwendung fehlgeschlagen.

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=Gemeinsame Datei entfernen?
ConfirmDeleteSharedFile2=Das System zeigt an, dass die folgende gemeinsame Datei von keinem anderen Programm mehr benutzt wird. Wollen Sie diese Datei entfernen lassen?%n%nSollte es doch noch Programme geben, die diese Datei benutzen, und die Datei ist entfernt worden, dann werden diese Programme wahrscheinlich nicht mehr einwandfrei funktionieren. Wenn Sie sich nicht sicher sind, sollten Sie "Nein" wählen. Es schadet Ihrem System nicht, wenn Sie die Datei behalten.
SharedFileNameLabel=Dateiname:
SharedFileLocationLabel=Ordner:
WizardUninstalling=Entfernen (Status)
StatusUninstalling=Entferne %1 ...


