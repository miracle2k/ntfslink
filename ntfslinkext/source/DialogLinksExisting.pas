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

unit DialogLinksExisting;

interface

uses
  Windows, Messages;

function DialogCallback(hDlg: HWND; uMsg: dword; wParam: wParam;
                        lParam: lParam): BOOL; stdcall;

var
  // Global variable (uh :-), used to pass the list of junctions to the dialog
  Dialog_JunctionListAsString: string = '';

  // Another global, used to pass whether the object is to be deleted or
  // if it's moved/renamed. Used to adjusted some texts in the dialog.
  Dialog_IsDeleteOperation: boolean = True;  // true = delete; false = move;

implementation

uses
  GNUGetText;

const
  IDC_TFLINKSEXISTINGDIALOG = 1000;
  IDC_CAPTION = 100;
  IDC_MLINKS = 102;
  IDC_BNO = 103;
  IDC_BYES = 104;
  IDC_ICON = 105;
  IDC_BYESDELETE = 106;

function DialogCallback(hDlg: HWND; uMsg: dword; wParam: wParam;
  lParam: lParam): BOOL;

  procedure TranslateDialogItemText(DlgItem: Integer);
  var
    ItemText: array[0..180] of Char;
  begin
    GetDlgItemText(hDlg, DlgItem, ItemText, High(ItemText));
    SetDlgItemText(hDlg, DlgItem, PAnsiChar(string(_(ItemText))));
  end;

var
  IconHandle: HICON;
begin
  // "True" means: we handled the message ourself
  Result := True;

  case uMsg of
    WM_INITDIALOG:
    begin
      // Translate dialog texts
      TranslateDialogItemText(IDC_CAPTION);
      TranslateDialogItemText(IDC_BNO);
      TranslateDialogItemText(IDC_BYES);

      // Depending on the operation mode (delete or copy/move), set the
      // text of the third option button
      if Dialog_IsDeleteOperation then
        SetDlgItemText(hDlg, IDC_BYESDELETE,
                       PAnsiChar(string(_('Yes, and delete links'))))
      else
        SetDlgItemText(hDlg, IDC_BYESDELETE,
                       PAnsiChar(string(_('Yes, and correct links'))));

      // Display the list of junctions
      SetDlgItemText(hDlg, IDC_MLINKS, PAnsiChar(Dialog_JunctionListAsString));

      // Display a standard windows "question" icon
      IconHandle := LoadIcon(0, MakeIntResource(IDI_QUESTION));
      SendDlgItemMessage(hDlg, IDC_ICON, STM_SETIMAGE, IMAGE_ICON, IconHandle);

      // Set focus to "no" button
      if (GetDlgCtrlID(wParam) <> IDC_BNO) then
      begin
        SetActiveWindow(GetDlgItem(hDlg, IDC_BNO));
        SetFocus(GetDlgItem(hDlg, IDC_BNO));
        Result := False;
      end;
    end;

    WM_SETFOCUS:
      Result := True;

    WM_CLOSE:
      // Close dialog: pass wParam as the result value
      EndDialog(hDlg, wParam);

    WM_COMMAND:
      // Check if a button is clicked
      if HIWORD(wParam) = BN_CLICKED then
        case LoWord(wParam) of
          // Yes or no: either way, close the dialog, but with different result
          IDC_BNO:
            SendMessage(hDlg, WM_CLOSE, ID_NO, 0);
          IDC_BYES:
            SendMessage(hDlg, WM_CLOSE, ID_YES, 0);
          IDC_BYESDELETE:
            SendMessage(hDlg, WM_CLOSE, ID_RETRY, 0);  // "Retry" is used, because of lack of better alternative
        end
      else Result := False;
    else
      Result := False;
  end;
end;

end.
