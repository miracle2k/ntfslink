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

You may retrieve the latest version of this file at the NTFS Link Homepage
located at http://www.elsdoerfer.net/ntfslink/

Known Issues:
-----------------------------------------------------------------------------}

library ntfslink;

{$R 'ntfslink.res' 'ntfslink.rc'}
{$R 'DialogLinksExisting.res' 'DialogLinksExisting.rc'}

// TODO [future] Implement a logging mechanism
// TODO [future] Enable WinXP styles 

uses      
  ComServ,
  Windows,
  JclRegistry,
  Global in 'Global.pas',
  GNUGetText in 'GNUGetText.pas',
  BaseExtensionFactory in 'BaseExtensionFactory.pas',  
  DragDropHook in 'DragDropHook.pas',
  IconOverlayHook in 'IconOverlayHook.pas',
  CopyHook in 'CopyHook.pas',
  ContextMenuHook in 'ContextMenuHook.pas',
  PropertySheetHook in 'PropertySheetHook.pas',  
  ShellNewExports in 'ShellNewExports.pas',
  ShellObjExtended in 'ShellObjExtended.pas',
  JunctionMonitor in 'JunctionMonitor.pas',
  DialogLinksExisting in 'DialogLinksExisting.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  
  // Used to integrate into the Shell New menu: Explorer later will use
  // rundll32.exe to call these function
  NewHardlinkDlg,
  NewJunctionDlg;

begin
  // Try to load the language setting from the registry
  UseLanguage(RegReadStringDef(
                 HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION, 'Language', ''));

  // Initialize some handles
  GLYPH_HANDLE_STD := LoadBitmap(HInstance, 'MENU_GLYPH_STD');
  GLYPH_HANDLE_JUNCTION := LoadBitmap(HInstance, 'MENU_GLYPH_JUNCTION');
  GLYPH_HANDLE_LINKDEL := LoadBitmap(HInstance, 'MENU_GLYPH_LINKDEL');
  GLYPH_HANDLE_EXPLORER := LoadBitmap(HInstance, 'MENU_GLYPH_EXPLORER');
end.
