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
  OVERLAY_PRIORITY_DEFAULT = 0;

  // Template used to name the created links; can be overridden by lang file
  {gnugettext:scan-all}
  LINK_PREFIX_TEMPLATE_DEFAULT =  'Link%s to %s';
  COPY_PREFIX_TEMPLATE_DEFAULT =  'Copy%s of %s';
  {gnugettext:reset}
  LINK_NO_PREFIX_TEMPLATE      =  '%1:s%0:s';

implementation

end.
