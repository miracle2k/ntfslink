object fConfig: TfConfig
  Left = 192
  Top = 109
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'NTFS Link Ext Configuration'
  ClientHeight = 419
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  DesignSize = (
    464
    419)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 133
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Icon:'
  end
  object Label2: TLabel
    Left = 64
    Top = 189
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Icon:'
  end
  object Bevel2: TBevel
    Left = 24
    Top = 90
    Width = 426
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
    ExplicitWidth = 402
  end
  object Bevel: TBevel
    Left = 0
    Top = 379
    Width = 464
    Height = 40
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 293
    ExplicitWidth = 440
  end
  object Bevel3: TBevel
    Left = 22
    Top = 342
    Width = 426
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
    ExplicitWidth = 402
  end
  object Label3: TLabel
    Left = 22
    Top = 315
    Width = 144
    Height = 13
    Caption = 'Tracking of Junction Creation:'
  end
  object Bevel1: TBevel
    Left = 22
    Top = 278
    Width = 426
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
    ExplicitWidth = 402
  end
  object Label4: TLabel
    Left = 63
    Top = 245
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Icon:'
  end
  object IntegrateIntoDragDropMenu: TCheckBox
    Left = 24
    Top = 16
    Width = 217
    Height = 17
    Hint = 'Allows creation of hardlinks and junctions using Drag&Drop'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Integrate into Explorer Drag&&Drop menu'
    TabOrder = 0
  end
  object EnableJunctionIconOverlays: TCheckBox
    Left = 24
    Top = 104
    Width = 419
    Height = 17
    Hint = 'Helps differing junction points between other directories'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Icon Overlays for Junction Points (requires restart)'
    TabOrder = 3
    OnClick = EnabledStateChange
    ExplicitWidth = 395
  end
  object EnableHardlinkIconOverlays: TCheckBox
    Left = 24
    Top = 160
    Width = 419
    Height = 17
    Hint = 'Helps differing hard links between other files'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Icon Overlays for Hardlinks (requires restart)'
    TabOrder = 5
    OnClick = EnabledStateChange
    ExplicitWidth = 395
  end
  object InterceptJunctionCopying: TCheckBox
    Left = 22
    Top = 283
    Width = 419
    Height = 17
    Hint = 
      'Whenever you try to copy a junction point in Explorer, NTFS Link' +
      ' will ask whether you want to copy the junction only, or all the' +
      ' contents of the target folder'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Intercept Copying of Junction Points'
    TabOrder = 9
    ExplicitWidth = 395
  end
  object bOK: TButton
    Left = 301
    Top = 387
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 12
    OnClick = bOKClick
    ExplicitLeft = 277
  end
  object bCancel: TButton
    Left = 381
    Top = 387
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 13
    OnClick = bCancelClick
    ExplicitLeft = 357
  end
  object JunctionTrackingMode: TComboBox
    Left = 182
    Top = 308
    Width = 258
    Height = 21
    Hint = 
      'NTFS Link can save information about the junctions you created, ' +
      'and warn you, if you attempt to delete a folder with junctions p' +
      'ointing to'
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 0
    TabOrder = 10
    Text = 'Prefer Streams, if not available Registry'
    Items.Strings = (
      'Prefer Streams, if not available Registry'
      'Always in Registry'
      'Always in Streams (does not work on FAT)'
      'Deactivate')
    ExplicitWidth = 234
  end
  object JunctionOverlay: TJvComboEdit
    Left = 96
    Top = 128
    Width = 345
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 4
    OnButtonClick = OverlayIconChange
    ExplicitWidth = 321
  end
  object HardlinkOverlay: TJvComboEdit
    Left = 96
    Top = 184
    Width = 345
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 6
    OnButtonClick = OverlayIconChange
    ExplicitWidth = 321
  end
  object IntegrateIntoContextMenu: TCheckBox
    Left = 24
    Top = 40
    Width = 233
    Height = 17
    Hint = 
      'Adds a menu item into the context menu of junction points und em' +
      'pty directories'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Integrate into Explorer Right-Click menu'
    TabOrder = 1
    ExplicitWidth = 209
  end
  object CreateLinksSuppressPrefix: TCheckBox
    Left = 24
    Top = 64
    Width = 257
    Height = 17
    Hint = 
      'By default, a "Link to" prefix will be added to every link, like' +
      ' the Explorer does with copies'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Do not add "Link to" prefix when creating links'
    TabOrder = 2
    ExplicitWidth = 233
  end
  object SetupHardlinksCmdFile: TCheckBox
    Left = 22
    Top = 356
    Width = 419
    Height = 17
    Hint = 
      'When creating a hardlink, a .cmd file will be created that allow' +
      's to re-create hardlinks if they become "broken"'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Create and maintain local .setupHardLinks.cmd files'
    TabOrder = 11
    ExplicitWidth = 395
  end
  object EnableBrokenHardlinkIconOverlays: TCheckBox
    Left = 23
    Top = 216
    Width = 419
    Height = 17
    Hint = 'Helps showing broken hard links from their source'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Icon Overlays for broken Hardlinks (requires restart)'
    TabOrder = 7
    OnClick = EnabledStateChange
    ExplicitWidth = 395
  end
  object BrokenHardlinkOverlay: TJvComboEdit
    Left = 95
    Top = 240
    Width = 345
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 8
    OnButtonClick = OverlayIconChange
    ExplicitWidth = 321
  end
  object JvChangeIconDialog: TJvChangeIconDialog
    IconIndex = 0
    Left = 376
    Top = 104
  end
end
