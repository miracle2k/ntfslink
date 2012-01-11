{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsdörfer, with
contributions from Sebastian Schuberth.

You can find more information at http://elsdoerfer.name/ntfslink
-----------------------------------------------------------------------------}

unit PropertySheetHook;

interface

uses
  Windows, ActiveX, ShlObj, CommCtrl, ComObj, BaseExtensionFactory;

type
  // The type of the object we operate on; note that we only handle hardlinks
  // and junctions; of the source objects is anything else, we do not display
  // our sheet.
  TSourceFileMode = (sfmStandard, sfmHardlink, sfmJunction);

  TPropertySheetHook = class(TComObject, IShellExtInit, IShellPropSheetExt)
  private
    FSourceObject: string;
//    FMode: TSourceFileMode;
  public
    { IShellExtInit }
    function IShellExtInit.Initialize = SEIInitialize; // Avoid compiler warning
    function SEIInitialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; stdcall;
    { IShellPropSheetExt }
    function AddPages(lpfnAddPage: TFNAddPropSheetPage;
      lParam: LPARAM): HResult; stdcall;
    function ReplacePage(uPageID: UINT; lpfnReplaceWith: TFNAddPropSheetPage;
      lParam: LPARAM): HResult; stdcall;
  end;

  TPropertySheetHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; override;
  end;

const
  Class_PropertySheetHook: TGUID = '{AFF02BB9-D826-4566-974F-F9EE60BE13AD}';

implementation

uses
  ShellAPI;

{ TPropertySheetHook }

function TPropertySheetHook.AddPages(lpfnAddPage: TFNAddPropSheetPage;
  lParam: LPARAM): HResult;
begin
  Result := S_OK;
end;

function TPropertySheetHook.ReplacePage(uPageID: UINT;
  lpfnReplaceWith: TFNAddPropSheetPage; lParam: LPARAM): HResult;
begin
  Result := S_OK;
end;

function TPropertySheetHook.SEIInitialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
var
  StgMedium: TStgMedium;
  FormatEtc: TFormatEtc;
  tempFile: array[0..MAX_PATH] of Char;
  SrcCount: Integer;
begin
  // Initialize FormatEtc
  with FormatEtc do begin
    cfFormat := CF_HDROP;
    ptd      := nil;
    dwAspect := DVASPECT_CONTENT;
    lindex   := -1;
    tymed    := TYMED_HGLOBAL;
  end;

  // Render the data referenced by the IDataObject pointer to an HGLOBAL
  // storage medium in CF_HDROP format.
  Result := lpdobj.GetData(FormatEtc, StgMedium);
  if Failed(Result) then exit;

  // Get the selected object; note that only *1* is supported;
  SrcCount := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  if SrcCount = 1 then begin
    DragQueryFile(StgMedium.hGlobal, 0, tempFile, SizeOf(tempFile));
    FSourceObject := tempFile;
  end
  else begin
    Result := E_INVALIDARG;
    exit;
  end;

  // Free resources
  ReleaseStgMedium(StgMedium);
end;

{ TPropertySheetHookFactory }

function TPropertySheetHookFactory.GetInstallationData: TExtensionRegistryData;
begin
  Result.RootKey := HKEY_CLASSES_ROOT;
  Result.BaseKey := '*\shellex\PropertySheetHandlers\NTFSLink';
  Result.UseGUIDAsKeyName := False;
end;

initialization
//  TODO [v2.1] Implement the Property Sheet Extensions
//  TPropertySheetHookFactory.Create(ComServer, TPropertySheetHook,
//      Class_PropertySheetHook, '', 'NTFSLink Property Sheet Shell Extension',
//      ciMultiInstance, tmApartment);
end.
