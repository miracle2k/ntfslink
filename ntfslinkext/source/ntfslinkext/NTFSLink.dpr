{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsdörfer.
All Rights Reserved.

Development of the extended version has been moved from Novell Forge to
SourceForge by Sebastian Schuberth.

You may retrieve the latest extended version at the "NTFS Link Ext" project page
located at http://sourceforge.net/projects/ntfslinkext/

The original version can still be retrieved from the "NTFS Link" homepage
located at http://www.elsdoerfer.net/ntfslink/
-----------------------------------------------------------------------------}

library NTFSLink;

// TODO [v2.1] Implement a logging mechanism
// TODO [v2.1] Support for target.lnk style links?
// TODO [v2.1] Create hardlinks automatically for each file in directory and
//             subdirectories [by Gunthar Müller]

{$R 'DialogLinksExisting.res' 'DialogLinksExisting.rc'}
{$R 'Icons.res' 'Icons.rc'}
{$R 'XPManifest.res'}

uses
  ComServ,
  Windows,
  JclRegistry,
  ActivationContext in 'ActivationContext.pas',
  Global in 'Global.pas',
  Constants in '..\common\Constants.pas',
  GNUGetText in '..\common\GNUGetText.pas',
  BaseExtensionFactory in 'BaseExtensionFactory.pas',
  ContextMenuHook in 'ContextMenuHook.pas',
  CopyHook in 'CopyHook.pas',
  DialogLinksExisting in 'DialogLinksExisting.pas',
  DragDropHook in 'DragDropHook.pas',
  IconOverlayHook in 'IconOverlayHook.pas',
  JunctionMonitor in 'JunctionMonitor.pas',
  PropertySheetHook in 'PropertySheetHook.pas',
  ShellNewDummyHook in 'ShellNewDummyHook.pas',
  ShellNewExports in 'ShellNewExports.pas',
  ShellObjExtended in 'ShellObjExtended.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall,

  // Used to integrate into the Shell New menu: Explorer later will use
  // rundll32.exe to call these function
  NewHardlinkDlg,
  NewJunctionDlg;

begin
  // Try to load the language setting from the registry
  //UseLanguage(RegReadStringDef(
  //               HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION, 'Language', ''));

  // Initialize some handles
  GLYPH_HANDLE_STD := LoadBitmap(HInstance, 'MENU_GLYPH_STD');
  GLYPH_HANDLE_JUNCTION := LoadBitmap(HInstance, 'MENU_GLYPH_JUNCTION');
  GLYPH_HANDLE_HARDLINK := LoadBitmap(HInstance, 'MENU_GLYPH_HARDLINK');
  GLYPH_HANDLE_LINKDEL := LoadBitmap(HInstance, 'MENU_GLYPH_LINKDEL');
  GLYPH_HANDLE_EXPLORER := LoadBitmap(HInstance, 'MENU_GLYPH_EXPLORER');
end.
