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
  end
end;

function NtfsCreateJunctionPointW(const Source, Destination: WideString): Boolean;
begin
  Result := NtfsCreateJunctionPoint(Source, Destination);
end;

function NtfsDeleteJunctionPointW(const Source: WideString): Boolean;
begin
  Result := NtfsDeleteJunctionPoint(Source);
end;

function NtfsGetJunctionPointDestinationW(const Source: WideString; var Destination: WideString): Boolean;
var
  DestinationShort: string;
begin
  Result := NtfsGetJunctionPointDestination(Source, DestinationShort);
  Destination := DestinationShort;
end;
