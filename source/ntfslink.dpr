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
located at http://www.elsdoerfer.net/?pid=ntfslink

Known Issues:
-----------------------------------------------------------------------------}

library ntfslink;

{$R 'ntfslink.res' 'ntfslink.rc'}

// TODO correct link in header
// TODO link count is not decremented on deletion?
// TODO update explorer on new links
// TODO correct english

uses
  ComServ,
  Windows,
  JclRegistry,
  ntfslink_TLB in 'ntfslink_TLB.pas',
  Global in 'Global.pas',
  GNUGetText in 'GNUGetText.pas',
  DragDropHook in 'DragDropHook.pas',
  IconOverlayHook in 'IconOverlayHook.pas',
  CopyHook in 'CopyHook.pas',
  ColumnHook in 'ColumnHook.pas',
  ContextMenuHook in 'ContextMenuHook.pas',
  ShellNewExports in 'ShellNewExports.pas',
  PropertySheetHook in 'PropertySheetHook.pas',
  BaseExtensionFactory in 'BaseExtensionFactory.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  
  // Used to integrate into the Shell New menu: Explorer later will use
  // rundll32.exe to call these function
  NewHardlink,
  NewJunction;

begin
  // Try to load the language setting from the registry
  UseLanguage(RegReadStringDef(
                 HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION, 'Language', ''));
end.
