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

unit uConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, JvExMask, JvToolEdit, ExtCtrls, JvComponent,
  JvBaseDlg, JvWinDialogs, XPMan;

type
  TfConfig = class(TForm)
    IntegrateIntoDragDropMenu: TCheckBox;
    EnableJunctionIconOverlays: TCheckBox;
    EnableHardlinkIconOverlays: TCheckBox;
    InterceptJunctionCopying: TCheckBox;
    bOK: TButton;
    bCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    JunctionTrackingMode: TComboBox;
    Bevel2: TBevel;
    Bevel: TBevel;
    Bevel3: TBevel;
    Label3: TLabel;
    JvChangeIconDialog: TJvChangeIconDialog;
    JunctionOverlay: TJvComboEdit;
    HardlinkOverlay: TJvComboEdit;
    IntegrateIntoContextMenu: TCheckBox;
    procedure bCancelClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OverlayIconChange(Sender: TObject);
    procedure EnabledStateChange(Sender: TObject);
  private
    function MakeIconString(IconPath: string; IconIndex: Integer): string;
    procedure SplitIconString(IconString: string; var IconPath: string;
      var IconIndex: Integer);
  protected
    procedure UpdateEnabledStates;

    procedure LoadCurrentStateFromRegistry;
    procedure WriteStateToRegistry;
  end;

var
  fConfig: TfConfig;

implementation

uses
  JclRegistry, GNUGetText, Constants;

{$R *.dfm}

procedure TfConfig.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfConfig.bOKClick(Sender: TObject);
begin
  WriteStateToRegistry;
  Close;
end;

procedure TfConfig.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
  LoadCurrentStateFromRegistry;
  UpdateEnabledStates;
end;

procedure TfConfig.LoadCurrentStateFromRegistry;

  procedure LoadCheckBox(ACheckBox: TCheckBox);
  begin
    ACheckBox.Checked :=
      RegReadBoolDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                     ACheckBox.Name, True);
  end;

  procedure LoadIconComboEdit(AComboEdit: TJvComboEdit);
  begin
    AComboEdit.Text := MakeIconString(
      RegReadStringDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                       AComboEdit.Name + 'File', ''),
      RegReadIntegerDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                       AComboEdit.Name + 'Index', 0)
           );
  end;

  procedure LoadComboBox(AComboBox: TComboBox);
  begin
    AComboBox.ItemIndex :=
      RegReadIntegerDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                        AComboBox.Name, 0);
  end;  

begin
  LoadCheckBox(IntegrateIntoDragDropMenu);
  LoadCheckBox(IntegrateIntoContextMenu);
  LoadCheckBox(EnableJunctionIconOverlays);
  LoadIconComboEdit(JunctionOverlay);
  LoadCheckBox(EnableHardlinkIconOverlays);
  LoadIconComboEdit(HardlinkOverlay);
  LoadCheckBox(InterceptJunctionCopying);
  LoadComboBox(JunctionTrackingMode);
end;

procedure TfConfig.WriteStateToRegistry;

  procedure WriteCheckBox(ACheckBox: TCheckBox);
  begin
    RegWriteBool(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                   ACheckBox.Name, ACheckBox.Checked);
  end;

  procedure WriteIconComboEdit(AComboEdit: TJvComboEdit);
  var
    IconFile: string;
    IconIndex: Integer;
  begin
    SplitIconString(AComboEdit.Text, IconFile, IconIndex);
    RegWriteString(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                   AComboEdit.Name + 'File', IconFile);
    RegWriteInteger(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                    AComboEdit.Name + 'Index', IconIndex);
  end;

  procedure WriteComboBox(AComboBox: TComboBox);
  begin
    RegWriteInteger(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                    AComboBox.Name, AComboBox.ItemIndex);
  end;

begin
  WriteCheckBox(IntegrateIntoDragDropMenu);
  WriteCheckBox(IntegrateIntoContextMenu);
  WriteCheckBox(EnableJunctionIconOverlays);
  WriteIconComboEdit(JunctionOverlay);
  WriteCheckBox(EnableHardlinkIconOverlays);
  WriteIconComboEdit(HardlinkOverlay);
  WriteCheckBox(InterceptJunctionCopying);
  WriteComboBox(JunctionTrackingMode);
end;

function TfConfig.MakeIconString(IconPath: string;
  IconIndex: Integer): string;
begin
  if IconPath <> '' then
    Result := IconPath + ',' + IntToStr(IconIndex)
  else
    Result := '';
end;

procedure TfConfig.SplitIconString(IconString: string;
  var IconPath: string; var IconIndex: Integer);
var
  p: Integer;
begin
  p := LastDelimiter(',', IconString);
  if p > 0 then begin
    try
      IconIndex := StrToInt(Copy(IconString, p + 1, MaxInt));
    except
      IconIndex := 0;
    end;
    IconPath := Copy(IconString, 1, p - 1);
  end else begin
    IconPath := IconString;
    IconIndex := -1;
  end;
end;

procedure TfConfig.OverlayIconChange(Sender: TObject);
var
  iFile: string;
  iIndex: Integer;
begin
  with TJvComboEdit(Sender) do
  begin
    SplitIconString(Text, iFile, iIndex);
    with JvChangeIconDialog do begin
      IconIndex := iIndex;
      FileName := iFile;
      if Execute then
        Text := MakeIconString(FileName, IconIndex);
    end;
  end;
end;

procedure TfConfig.UpdateEnabledStates;
begin
  HardlinkOverlay.Enabled := EnableHardlinkIconOverlays.Checked;
  JunctionOverlay.Enabled := EnableJunctionIconOverlays.Checked;
end;

procedure TfConfig.EnabledStateChange(Sender: TObject);
begin
  UpdateEnabledStates;
end;

end.
