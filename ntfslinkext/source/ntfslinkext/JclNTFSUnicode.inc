{

NtfsStreamsSupported}

const
  FILE_ATTRIBUTE_REPARSE_POINT = DWORD($00000400);
  IO_REPARSE_TAG_MOUNT_POINT   = DWORD($A0000003);
  FILE_FLAG_OPEN_REPARSE_POINT = DWORD($00200000);
  FSCTL_DELETE_REPARSE_POINT   = DWORD($000900AC);
  FSCTL_GET_REPARSE_POINT      = DWORD($000900A8);

  REPARSE_GUID_DATA_BUFFER_HEADER_SIZE = 24;
  MAXIMUM_REPARSE_DATA_BUFFER_SIZE     = 16 * 1024;

type
  TGenericReparseBuffer = record
    DataBuffer: array [0..0] of BYTE;
  end;
  TReparseGuidDataBuffer = record
    ReparseTag: DWORD;
    ReparseDataLength: WORD;
    Reserved: WORD;
    ReparseGuid: TGUID;
    GenericReparseBuffer: TGenericReparseBuffer;
  end;

  TReparseDataBuffer = record
    ReparseTag: DWORD;
    ReparseDataLength: Word;
    Reserved: Word;
    case Integer of
      0: ( // SymbolicLinkReparseBuffer and MountPointReparseBuffer
        SubstituteNameOffset: Word;
        SubstituteNameLength: Word;
        PrintNameOffset: Word;
        PrintNameLength: Word;
        PathBuffer: array [0..0] of WCHAR);
      1: ( // GenericReparseBuffer
        DataBuffer: array [0..0] of Byte);
  end;
  TReparseDataBufferOverlay = record
  case Boolean of
    False:
      (Reparse: TReparseDataBuffer;);
    True:
      (Buffer: array [0..MAXIMUM_REPARSE_DATA_BUFFER_SIZE] of Char;);
  end;

function NtfsFileHasReparsePointW(const Path: WideString): Boolean;
var
  Attr: DWORD;
begin
  Result := False;
  Attr := GetFileAttributesW(PWideChar(Path));
  if Attr <> DWORD(-1) then
    Result := (Attr and FILE_ATTRIBUTE_REPARSE_POINT) <> 0;
end;

function NtfsGetReparseTagW(const Path: WideString; var Tag: DWORD): Boolean;
var
  Data: TWIN32FindDataW;
  Handle: THandle;
begin
  Result := NtfsFileHasReparsePointW(Path);
  if Result then
  begin
    Handle := FindFirstFileW(PWideChar(Path), Data);
    if Handle <> INVALID_HANDLE_VALUE then
    begin
      // Check if file has a reparse point.
      Result := ((Data.dwFileAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0);
      // If so the dwReserved0 field contains the reparse tag.
      if Result then
        Tag := Data.dwReserved0;
      Windows.FindClose(Handle);
    end;
  end;
end;

function NtfsIsFolderMountPoint(const Path: WideString): Boolean;
var
  Tag: DWORD;
begin
  Result := NtfsGetReparseTagW(Path, Tag);
  if Result then
    Result := (Tag = IO_REPARSE_TAG_MOUNT_POINT);
end;

function NtfsGetHardLinkInfoW(const FileName: WideString; var Info: TNtfsHardLinkInfo): Boolean;
var
  F: THandle;
  FileInfo: TByHandleFileInformation;
begin
  Result := False;
  F := CreateFileW(PWideChar(FileName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if F <> INVALID_HANDLE_VALUE then
  try
    if GetFileInformationByHandle(F, FileInfo) then
    begin
      Info.LinkCount := FileInfo.nNumberOfLinks;
      Info.FileIndexHigh := FileInfo.nFileIndexHigh;
      Info.FileIndexLow := FileInfo.nFileIndexLow;
      Result := True;
    end;
  finally
    CloseHandle(F);
  end;
end;

function NtfsCreateJunctionPointW(const Source, Destination: WideString): Boolean;
begin
  // TODO: Convert!
  Result := NtfsCreateJunctionPoint(Source, Destination);
end;

function NtfsDeleteReparsePointW(const FileName: WideString; ReparseTag: DWORD): Boolean;
var
  Handle: THandle;
  BytesReturned: DWORD;
  ReparseData: TReparseGuidDataBuffer;
begin
  Result := False;
  Handle := CreateFileW(PWideChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OPEN_REPARSE_POINT, 0);
  if Handle <> INVALID_HANDLE_VALUE then
    try
      FillChar(ReparseData, SizeOf(ReparseData), #0);
      ReparseData.ReparseTag := ReparseTag;
      Result := DeviceIoControl(Handle, FSCTL_DELETE_REPARSE_POINT, @ReparseData,
        REPARSE_GUID_DATA_BUFFER_HEADER_SIZE, nil, 0, BytesReturned, nil);
    finally
      CloseHandle(Handle);
    end;
end;

function NtfsDeleteJunctionPointW(const Source: WideString): Boolean;
begin
  Result := NtfsDeleteReparsePointW(Source, IO_REPARSE_TAG_MOUNT_POINT);
end;

function NtfsGetJunctionPointDestinationW(const Source: WideString; var Destination: WideString): Boolean;
var
  Handle: THandle;
  ReparseData: TReparseDataBufferOverlay;
  BytesReturned: DWORD;
begin
  Result := False;
  if NtfsFileHasReparsePointW(Source) then
  begin
    Handle := CreateFileW(PWideChar(Source), GENERIC_READ, 0, nil,
      OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OPEN_REPARSE_POINT, 0);
    if Handle <> INVALID_HANDLE_VALUE then
    try
      if DeviceIoControl(Handle, FSCTL_GET_REPARSE_POINT, nil, 0, @ReparseData,
        MAXIMUM_REPARSE_DATA_BUFFER_SIZE, BytesReturned, nil) {and
        IsReparseTagValid(ReparseData.Reparse.ReparseTag) then}
        then
      begin
        if BytesReturned >= ReparseData.Reparse.SubstituteNameLength + SizeOf(WideChar) then
        begin
          // Copy into Destination buffer; A simple assign does not work,
          // because of the way ReparseData.Reparse.PathBuffer is typed. 
          SetLength(Destination, (ReparseData.Reparse.SubstituteNameLength) div SizeOf(WideChar) + 1);
          Move(ReparseData.Reparse.PathBuffer, Destination[1],
            ReparseData.Reparse.SubstituteNameLength+SizeOf(WCHAR));
          Result := True;
        end;
      end;
    finally
      CloseHandle(Handle);
    end
  end;
end;

function NtfsIsFolderMountPointW(const Path: WideString): Boolean;
var
  Tag: DWORD;
begin
  Result := NtfsGetReparseTagW(Path, Tag);
  if Result then
    Result := (Tag = IO_REPARSE_TAG_MOUNT_POINT);
end;

type
  TFileSystemFlag =
   (
    fsCaseSensitive,            // The file system supports case-sensitive file names.
    fsCasePreservedNames,       // The file system preserves the case of file names when it places a name on disk.
    fsSupportsUnicodeOnDisk,    // The file system supports Unicode in file names as they appear on disk.
    fsPersistentACLs,           // The file system preserves and enforces ACLs. For example, NTFS preserves and enforces ACLs, and FAT does not.
    fsSupportsFileCompression,  // The file system supports file-based compression.
    fsSupportsVolumeQuotas,     // The file system supports disk quotas.
    fsSupportsSparseFiles,      // The file system supports sparse files.
    fsSupportsReparsePoints,    // The file system supports reparse points.
    fsSupportsRemoteStorage,    // The file system supports remote storage.
    fsUnknown9,
    fsUnknown10,
    fsUnknown11,
    fsUnknown12,
    fsUnknown13,
    fsUnknown14,
    fsVolumeIsCompressed,       // The specified volume is a compressed volume; for example, a DoubleSpace volume.
    fsSupportsObjectIds,        // The file system supports object identifiers.
    fsSupportsEncryption,       // The file system supports the Encrypted File System (EFS).
    fsSupportsNamedStreams,     // The file system supports named streams.
    fsVolumeIsReadOnly          // The specified volume is read-only (only Windows XP and later).
   );

  TFileSystemFlags = set of TFileSystemFlag;

function PathAddSeparator(AFileName: WideString): WideString;
var
  l: integer;
begin
  l := Length(AFileName);
  if (l > 0) and (AFileName[l] <> '\') then
    Result := AFileName + '\'
  else Result := AFileName;
end;

function GetVolumeFileSystemFlagsW(const Volume: WideString): TFileSystemFlags;
var
  MaximumComponentLength, Flags: Cardinal;
  Flag: TFileSystemFlag;
begin
  if not GetVolumeInformationW(PWideChar(PathAddSeparator(Volume)), nil, 0, nil,
    MaximumComponentLength, Flags, nil, 0) then
    RaiseLastOSError;
  Result := [];
  for Flag := Low(TFileSystemFlag) to High(TFileSystemFlag) do
    if (Flags and (1 shl Ord(Flag))) <> 0 then
      Include(Result, Flag);
end;

function NtfsReparsePointsSupportedW(const Volume: WideString): Boolean;
begin
  Result := fsSupportsReparsePoints in GetVolumeFileSystemFlagsW(Volume);
end;

function NtfsStreamsSupported(const Volume: string): Boolean;
begin
  //Result := fsSupportsNamedStreams in GetVolumeFileSystemFlags(Volume);
  Result := fsSupportsReparsePoints in GetVolumeFileSystemFlagsW(Volume);
end;

function NtfsStreamsSupportedW(const Volume: WideString): Boolean;
begin
  Result := fsSupportsNamedStreams in GetVolumeFileSystemFlagsW(Volume);
end;
