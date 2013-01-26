{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsd�rfer.
All Rights Reserved.

Development of the extended version has been moved from Novell Forge to
SourceForge by Sebastian Schuberth.

You may retrieve the latest extended version at the "NTFS Link Ext" project page
located at http://sourceforge.net/projects/ntfslinkext/

The original version can still be retrieved from the "NTFS Link" homepage
located at http://www.elsdoerfer.net/ntfslink/
-----------------------------------------------------------------------------}

unit Constants;

interface

const
  // Paths used in registry
  NTFSLINK_REGISTRY = 'Software\elsdoerfer.net\NTFS Link\';
  NTFSLINK_CONFIGURATION = NTFSLINK_REGISTRY + 'Config\';

  // Junction Tracking: Define where the data should be stored
  NTFSLINK_TRACKINGDATA_KEY = NTFSLINK_REGISTRY + 'Tracking\';
  NTFSLINK_TRACKING_STREAM = 'ntfslink.junction-tracking';

  // Some default values, can (mostly) be overridden by configuration values
  OVERLAY_HARDLINK_ICONINDEX = 0;
  OVERLAY_JUNCTION_ICONINDEX = 1;
  OVERLAY_BROKEN_HARDLINK_ICONINDEX = 2;
  OVERLAY_PRIORITY_DEFAULT = 0;

  // Template used to name the created links; can be overridden by lang file
  {gnugettext:scan-all}
  LINK_PREFIX_TEMPLATE_DEFAULT =  'Link%s to %s';
  COPY_PREFIX_TEMPLATE_DEFAULT =  'Copy%s of %s';
  {gnugettext:reset}
  LINK_NO_PREFIX_TEMPLATE      =  '%1:s%0:s';

  RECREATE_HARDLINKS_FILENAME = '.setupHardLinks.cmd';
  MKLINK_COMMAND = 'mklink /H ';
  DEL_COMMAND = 'del ';

implementation

end.
