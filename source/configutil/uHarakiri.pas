unit uHarakiri;

interface

implementation

uses
  Windows;

initialization
finalization
  TerminateProcess (GetCurrentProcess, 0);
end.