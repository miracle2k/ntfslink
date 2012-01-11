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

{*
PLEASE NOTE:
Contains declarations which are not included in the ShlObj.pas version that
ships with Delphi 7, and (at least some) still not in XE2.
*}

unit ShellObjExtended;

interface

uses
  Windows, Messages, ShlObj;

const
  IID_IColumnProvider: TGUID = (
    D1: $E8025004; D2: $1C42; D3: $11D2; D4: ($BE, $2C, $0, $A0, $C9, $A8, $3D, $A1));

  SID_IColumnProvider = '{E8025004-1C42-11D2-BE2C-00A0C9A83DA1}';

  FILE_FLAG_OPEN_REPARSE_POINT = $00200000;

const
  MAX_COLUMN_NAME_LEN = 80;
  MAX_COLUMN_DESC_LEN = 128;

type
  HANDLE = Windows.THandle;

  SHCOLUMNINFO = packed record
    scid: SHCOLUMNID;
    vt: integer;
    fmt: DWORD;
    cChars: UINT;
    csFlags: dword;
    wszTitle: array[0..MAX_COLUMN_NAME_LEN - 1] of WideChar;
    wszDescription: array[0..MAX_COLUMN_DESC_LEN - 1] of WideChar;
  end;
  LPSHCOLUMNINFO = ^SHCOLUMNINFO;

  TShColumnInfo = SHCOLUMNINFO;
  PShColumnInfo = LPSHCOLUMNINFO;

  SHCOLUMNINIT = packed record
    dwFlags: ulong;
    dwReserved: ulong;
    wszFolder: array[0..MAX_PATH - 1] of WideChar;
  end;
  LPSHCOLUMNINIT = ^SHCOLUMNINIT;

  TShColumnInit = SHCOLUMNINIT;
  PShColumnInit = LPSHCOLUMNINIT;

const
  SHCDF_UPDATEITEM = $00000001;

type
  SHCOLUMNDATA = packed record
    dwFlags: ULONG;
    dwFileAttributes: DWord;
    dwReserved: ULONG;
    pwszExt: PWideChar;
    wszFile: array[0..MAX_PATH - 1] of WideChar
  end;
  LPSHCOLUMNDATA = ^SHCOLUMNDATA;

  TShColumnData = SHCOLUMNDATA;
  PShColumnData = LPSHCOLUMNDATA;

  IColumnProvider = interface
    [SID_IColumnProvider]
    function Initialize(psci: PSHCOLUMNINIT): HResult; stdcall;
    function GetColumnInfo(dwIndex: DWORD; psci: PSHCOLUMNINFO): HResult; stdcall;
    function GetItemData(pscid: PSHCOLUMNID; pscd: PSHCOLUMNDATA; pvarData: Variant): HResult; stdcall;
  end;

// From Winbase.h
function GetVolumePathNameA(lpszFileName: LPCSTR; lpszVolumePathName: LPSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathNameA}
function GetVolumePathNameW(lpszFileName: LPCWSTR; lpszVolumePathName: LPWSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathNameW}
function GetVolumePathName(lpszFileName: LPCSTR; lpszVolumePathName: LPSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathName}

function GetVolumePathNamesForVolumeNameA(lpszVolumeName, lpszVolumePathNames: LPCSTR;
  cchBufferLength: DWORD; var lpcchReturnLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathNamesForVolumeNameA}
function GetVolumePathNamesForVolumeNameW(lpszVolumeName, lpszVolumePathNames: LPCWSTR;
  cchBufferLength: DWORD; var lpcchReturnLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathNamesForVolumeNameW}
function GetVolumePathNamesForVolumeName(lpszVolumeName, lpszVolumePathNames: LPCSTR;
  cchBufferLength: DWORD; var lpcchReturnLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumePathNamesForVolumeName}

function GetVolumeNameForVolumeMountPointA(lpszVolumeMountPoint: LPCSTR;
  lpszVolumeName: LPSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumeNameForVolumeMountPointA}
function GetVolumeNameForVolumeMountPointW(lpszVolumeMountPoint: LPCWSTR;
  lpszVolumeName: LPWSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumeNameForVolumeMountPointW}
function GetVolumeNameForVolumeMountPoint(lpszVolumeMountPoint: LPCSTR;
  lpszVolumeName: LPSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM GetVolumeNameForVolumeMountPoint}

function FindFirstVolumeA(lpszVolumeName: LPSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolumeA}
function FindFirstVolumeW(lpszVolumeName: LPWSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolumeW}
function FindFirstVolume(lpszVolumeName: LPSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolume}

function FindNextVolumeA(hFindVolume: HANDLE; lpszVolumeName: LPSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolumeA}
function FindNextVolumeW(hFindVolume: HANDLE; lpszVolumeName: LPWSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolumeW}
function FindNextVolume(hFindVolume: HANDLE; lpszVolumeName: LPSTR;
  cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolume}

function FindVolumeClose(hFindVolume: HANDLE): BOOL; stdcall;
{$EXTERNALSYM FindVolumeClose}

function FindFirstVolumeMountPointA(lpszRootPathName: LPCSTR;
  lpszVolumeMountPoint: LPSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolumeMountPointA}
function FindFirstVolumeMountPointW(lpszRootPathName: LPCWSTR;
  lpszVolumeMountPoint: LPWSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolumeMountPointW}
function FindFirstVolumeMountPoint(lpszRootPathName: LPCSTR;
  lpszVolumeMountPoint: LPSTR; cchBufferLength: DWORD): HANDLE; stdcall;
{$EXTERNALSYM FindFirstVolumeMountPoint}

function FindNextVolumeMountPointA(hFindVolumeMountPoint: HANDLE;
  lpszVolumeMountPoint: LPSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolumeMountPointA}
function FindNextVolumeMountPointW(hFindVolumeMountPoint: HANDLE;
  lpszVolumeMountPoint: LPWSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolumeMountPointW}
function FindNextVolumeMountPoint(hFindVolumeMountPoint: HANDLE;
  lpszVolumeMountPoint: LPSTR; cchBufferLength: DWORD): BOOL; stdcall;
{$EXTERNALSYM FindNextVolumeMountPoint}

function FindVolumeMountPointClose(hFindVolumeMountPoint: HANDLE): BOOL; stdcall;
{$EXTERNALSYM FindVolumeMountPointClose}

implementation

function GetVolumePathNameA; external kernel32 name 'GetVolumePathNameA';
function GetVolumePathNameW; external kernel32 name 'GetVolumePathNameW';
function GetVolumePathName; external kernel32 name 'GetVolumePathNameA';

function GetVolumePathNamesForVolumeNameA; external kernel32 name 'GetVolumePathNamesForVolumeNameA';
function GetVolumePathNamesForVolumeNameW; external kernel32 name 'GetVolumePathNamesForVolumeNameW';
function GetVolumePathNamesForVolumeName; external kernel32 name 'GetVolumePathNamesForVolumeNameA';

function GetVolumeNameForVolumeMountPointA; external kernel32 name 'GetVolumeNameForVolumeMountPointA';
function GetVolumeNameForVolumeMountPointW; external kernel32 name 'GetVolumeNameForVolumeMountPointW';
function GetVolumeNameForVolumeMountPoint; external kernel32 name 'GetVolumeNameForVolumeMountPointA';

function FindFirstVolumeA; external kernel32 name 'FindFirstVolumeA';
function FindFirstVolumeW; external kernel32 name 'FindFirstVolumeW';
function FindFirstVolume; external kernel32 name 'FindFirstVolumeA';

function FindNextVolumeA; external kernel32 name 'FindNextVolumeA';
function FindNextVolumeW; external kernel32 name 'FindNextVolumeW';
function FindNextVolume; external kernel32 name 'FindNextVolumeA';

function FindVolumeClose; external kernel32 name 'FindVolumeClose';

function FindFirstVolumeMountPointA; external kernel32 name 'FindFirstVolumeMountPointA';
function FindFirstVolumeMountPointW; external kernel32 name 'FindFirstVolumeMountPointW';
function FindFirstVolumeMountPoint; external kernel32 name 'FindFirstVolumeMountPointA';

function FindNextVolumeMountPointA; external kernel32 name 'FindNextVolumeMountPointA';
function FindNextVolumeMountPointW; external kernel32 name 'FindNextVolumeMountPointW';
function FindNextVolumeMountPoint; external kernel32 name 'FindNextVolumeMountPointA';

function FindVolumeMountPointClose; external kernel32 name 'FindVolumeMountPointClose';

end.

