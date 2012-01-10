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

{
    This unit is heavily based on EasyActivationContext.pas by Jim Kueneman,
    which is part of his EasyNSE package, available at http://mustangpeak.net.
}
unit ActivationContext;
                                           
interface

uses
  Windows, Vcl.Forms, Vcl.Controls;

//------------------------------------------------------------------------------
// Activation Context API
//------------------------------------------------------------------------------

const
  {$EXTERNALSYM ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID}
  ACTCTX_FLAG_PROCESSOR_ARCHITECTURE_VALID    = $00000001;
  {$EXTERNALSYM ACTCTX_FLAG_LANGID_VALID}
  ACTCTX_FLAG_LANGID_VALID                    = $00000002;
  {$EXTERNALSYM ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID}
  ACTCTX_FLAG_ASSEMBLY_DIRECTORY_VALID        = $00000004;
  {$EXTERNALSYM ACTCTX_FLAG_RESOURCE_NAME_VALID}
  ACTCTX_FLAG_RESOURCE_NAME_VALID             = $00000008;
  {$EXTERNALSYM ACTCTX_FLAG_SET_PROCESS_DEFAULT}
  ACTCTX_FLAG_SET_PROCESS_DEFAULT             = $00000010;
  {$EXTERNALSYM ACTCTX_FLAG_APPLICATION_NAME_VALID}
  ACTCTX_FLAG_APPLICATION_NAME_VALID          = $00000020;
  {$EXTERNALSYM ACTCTX_FLAG_SOURCE_IS_ASSEMBLYREF}
  ACTCTX_FLAG_SOURCE_IS_ASSEMBLYREF           = $00000040;
  {$EXTERNALSYM ACTCTX_FLAG_HMODULE_VALID}
  ACTCTX_FLAG_HMODULE_VALID                   = $00000080;

type
  tagACTCTXA = packed record
    cbSize: ULONG;
    dwFlags: DWORD;
    lpSource: LPCSTR;
    wProcessorArchitecture: WORD;
    wLangId: LANGID;
    lpAssemblyDirectory: LPCSTR;
    lpResourceName: LPCSTR;
    lpApplicationName: LPCSTR;
    hModule: HMODULE;
  end;
  TActCTXA = tagACTCTXA;
  PActCTXA = ^TActCTXA;

  tagACTCTXW = packed record
    cbSize: ULONG;
    dwFlags: DWORD;
    lpSource: LPCWSTR;
    wProcessorArchitecture: WORD;
    wLangId: LANGID;
    lpAssemblyDirectory: LPCWSTR;
    lpResourceName: LPCWSTR;
    lpApplicationName: LPCWSTR;
    hModule: HMODULE;
  end;
  TActCTXW = tagACTCTXW;
  PActCTXW = ^TActCTXW;

//------------------------------------------------------------------------------
// Delphi wrapper functionality around Activation Context API
//------------------------------------------------------------------------------

  // This class presumes the XP manifest resource at ID 2
  // Usage:
  //   AContext := TThemedActContext.Create;
  //   try
  //     AContext.SetActive := True;
  //     ... create window handles that you want themed ...
  //   finally
  //     AContext.Free;
  //   end;
  TThemedActContext = class
  private
    FActivate: Boolean;
    function GetActivate: Boolean;
    procedure SetActivate(const Value: Boolean);
  protected
    FContextAvailable: Boolean;
    FActCtxHandle: THandle;
    FActCtx : TActCTXA;
    FCookie: Pointer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    // Set to True to push the context on the stack, set to false to remove it.
    property Activate: Boolean read GetActivate write SetActivate;
  end;

  // Force all window handles of the control and it's children to be recreated
  // within the current activation context.
  procedure ForceAllWindowHandles(Window: TWinControl);
  // Shows a VCL form within an activation context
  procedure ShowFormModalWithContext(AForm: TFormClass);
  // Wraps an activation context around a call to Windows.DialogBox()
  function DialogBoxWithContext(hInstance: HINST; lpTemplate: PChar;
    hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
  // Wraps an activation context around a call to Windows.Message()
  function MessageBoxWithContext(hWnd: HWND; lpText, lpCaption: PChar;
    uType: UINT): Integer; stdcall;
  // Determines whether themes are enabled for the application
  function UseThemes: Boolean;

implementation

var
  // Necessary functions to use the activation context API.
  ActivateActCtx: function(hActCtx: THandle; var lpCookie: Pointer): BOOL; stdcall;
  AddRefActCtx: procedure(hActCtx: THandle); stdcall;
  CreateActCtxA: function(var pActCtx: TActCTXA): THandle; stdcall;
  CreateActCtxW: function(var pActCtx: TActCTXW): THandle; stdcall;
  DeactivateActCtx: function(hActCtx: THandle; lpCookie: Pointer): BOOL; stdcall;
  GetCurrentActCtx: function(var lphActCtx: THandle): BOOL; stdcall;
  ReleaseActCtx: procedure(hActCtx: THandle); stdcall;
  ZombifyActCtx: function(hActCtx: THandle): BOOL; stdcall;

  // We need those additional functions from the theming API to determine
  // whether to use themes at all. 
  IsThemeActive: function: BOOL; stdcall;
  IsAppThemed: function: BOOL; stdcall;

  // Will be set to true if all required API functions were loaded
  // successfully. 
  ActCtxAvailable: Boolean = False;

  // We need to save the handle so we can free it on termination
  ThemeDLL: HMODULE = 0;

function UseThemes: Boolean;
begin
  Result := False;
    if Assigned(IsThemeActive) and Assigned(IsAppThemed) then
      Result := IsThemeActive and IsAppThemed;
end;

procedure ForceAllWindowHandles(Window: TWinControl);
var
  i: Integer;
begin
  for i := 0 to Window.ControlCount - 1 do
  begin
    if Window.Controls[i] is TWinControl then
    begin
      ForceAllWindowHandles(TWinControl(Window.Controls[i]));
      TWinControl(Window.Controls[i]).HandleNeeded;
    end
  end
end;

procedure ShowFormModalWithContext(AForm: TFormClass);
var
  Form: TForm;
  Context: TThemedActContext;
begin
  Context := TThemedActContext.Create;
  Form := AForm.Create(nil);
  try
    ForceAllWindowHandles(Form);
    Context.Activate := True;
    Form.ShowModal;
    Context.Activate := False;
  finally
    Form.Release;
    Context.Free;
  end;
end;

function DialogBoxWithContext(hInstance: HINST; lpTemplate: PChar;
  hWndParent: HWND; lpDialogFunc: TFNDlgProc): Integer;
var
  Context: TThemedActContext;
begin
  Context := TThemedActContext.Create;
  try
    Context.Activate := True;
    Result := Windows.DialogBox(hInstance, lpTemplate, hWndParent, lpDialogFunc);
    Context.Activate := False;
  finally
    Context.Free;
  end;
end;

function MessageBoxWithContext(hWnd: HWND; lpText, lpCaption: PChar;
  uType: UINT): Integer;
var
  Context: TThemedActContext;
begin
  Context := TThemedActContext.Create;
  try
    Context.Activate := True;
    Result := Windows.MessageBox(hWnd, lpText, lpCaption, uType);
    Context.Activate := False;
  finally
    Context.Free;
  end;
end;

procedure LoadApiFunctions;
const
  Kernel32 = 'Kernel32.dll';
  UXTheme32 = 'uxtheme.dll';
var
  KernelDLL: HMODULE;
begin
  // We expect kernel32.dll to be already loaded (e.g. statically bound), so we
  // don't use LoadLibrary/FreeLibrary
  KernelDLL := GetModuleHandle(PChar(Kernel32));
  // Load activation context functions
  if KernelDLL <> 0 then
  begin
    ActivateActCtx := GetProcAddress(KernelDLL, PChar('ActivateActCtx'));
    AddRefActCtx := GetProcAddress(KernelDLL, PChar('AddRefActCtx'));
    CreateActCtxA := GetProcAddress(KernelDLL, PChar('CreateActCtxA'));
    CreateActCtxW := GetProcAddress(KernelDLL, PChar('CreateActCtxW'));
    DeactivateActCtx := GetProcAddress(KernelDLL, PChar('DeactivateActCtx'));
    GetCurrentActCtx := GetProcAddress(KernelDLL, PChar('GetCurrentActCtx'));
    ReleaseActCtx := GetProcAddress(KernelDLL, PChar('ReleaseActCtx'));
    ZombifyActCtx := GetProcAddress(KernelDLL, PChar('ZombifyActCtx'));
  end;

  // Load theme API functions; library will be freed at finalization time
  ThemeDLL := LoadLibrary(PChar(UXTheme32));
  if ThemeDLL <> 0 then
  begin
    IsThemeActive := GetProcAddress(ThemeDLL, 'IsThemeActive');
    IsAppThemed := GetProcAddress(ThemeDLL, 'IsAppThemed');
  end;

  // We only use activation contexts if all required functions are available  
  ActCtxAvailable :=
    Assigned(ActivateActCtx) and
    Assigned(CreateActCtxA) and
    Assigned(CreateActCtxW) and
    Assigned(DeactivateActCtx) and
    Assigned(GetCurrentActCtx) and
    Assigned(ReleaseActCtx) and
    Assigned(ZombifyActCtx) and
    Assigned(IsThemeActive) and
    Assigned(IsAppThemed);
end;

{ TThemedActContext }

constructor TThemedActContext.Create;
var
  Buffer: array[0..MAX_PATH] of AnsiChar;
begin
  FContextAvailable := False;
  if ActCtxAvailable then
  begin
    // prepare initialization record
    FillChar(FActCtx, SizeOf(FActCtx), #0);
    FActCtx.cbSize := SizeOf(FActCtx);
    FActCtx.dwFlags := ACTCTX_FLAG_RESOURCE_NAME_VALID;
    GetModuleFileNameA(hInstance, Buffer, SizeOf(Buffer));
    FActCtx.lpSource := Buffer;
    FActCtx.lpResourceName := MakeIntResourceA(2);

    // create context
    FActCtxHandle := CreateActCtxA(FActCtx);
    if FActCtxHandle <> INVALID_HANDLE_VALUE then
      FContextAvailable := True
    else
      FActCtxHandle := 0
  end
end;

destructor TThemedActContext.Destroy;
begin
  Activate := False;
  if FContextAvailable then
    ReleaseActCtx(FActCtxHandle);
  inherited;
end;

function TThemedActContext.GetActivate: Boolean;
begin
  Result := FActivate;
end;

procedure TThemedActContext.SetActivate(const Value: Boolean);
begin
  if Value <> FActivate then
  begin
    if Value then
    begin
      if FContextAvailable then
      begin
        ActivateActCtx(FActCtxHandle, FCookie);
        FActivate := True
      end
    end else
    begin
      if FContextAvailable and FActivate then
        DeactivateActCtx(0, FCookie);
      FActivate := False;
    end
  end
end;

initialization
  LoadApiFunctions;

finalization
  if ThemeDLL <> 0 then
    FreeLibrary(ThemeDLL);
end.
