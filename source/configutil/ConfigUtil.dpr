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

program ConfigUtil;

uses
 {$IFDEF WIN64}
  { The following line was added because after opening icon dialog in 64 bits
    a nasty access violation happens on shutdown. Something with the JVCL components }
  uHarakiri in 'uHarakiri.pas', {$ENDIF}
  Forms,
  uConfig in 'uConfig.pas' {fConfig},
  Constants in '..\common\Constants.pas',
  GNUGetText in '..\common\GNUGetText.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'NTFS Link Configuration';
  Application.CreateForm(TfConfig, fConfig);
  Application.Run;
end.
