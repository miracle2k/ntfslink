object fConfig: TfConfig
  Left = 192
  Top = 109
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'NTFS Link Configuration'
  ClientHeight = 313
  ClientWidth = 440
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
    440
    313)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 109
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Icon:'
  end
  object Label2: TLabel
    Left = 64
    Top = 165
    Width = 25
    Height = 13
    Alignment = taRightJustify
    Caption = 'Icon:'
  end
  object Bevel2: TBevel
    Left = 16
    Top = 67
    Width = 402
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object Bevel: TBevel
    Left = 0
    Top = 273
    Width = 440
    Height = 40
    Align = alBottom
    Shape = bsTopLine
  end
  object Bevel3: TBevel
    Left = 16
    Top = 195
    Width = 402
    Height = 8
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 24
    Top = 240
    Width = 144
    Height = 13
    Caption = 'Tracking of Junction Creation:'
  end
  object IntegrateIntoDragDropMenu: TCheckBox
    Left = 24
    Top = 16
    Width = 395
    Height = 17
    Hint = 'Allows creation of hardlinks and junctions using Drag&Drop'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Integrate into Explorer Drag&&Drop menu'
    TabOrder = 0
  end
  object EnableJunctionIconOverlays: TCheckBox
    Left = 24
    Top = 80
    Width = 395
    Height = 17
    Hint = 'Helps differing junction points between other directories'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Icon Overlays for Junction Points (requires restart)'
    TabOrder = 2
    OnClick = EnabledStateChange
  end
  object EnableHardlinkIconOverlays: TCheckBox
    Left = 24
    Top = 136
    Width = 395
    Height = 17
    Hint = 'Helps differing hard links between other files'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Icon Overlays for Hardlinks (requires restart)'
    TabOrder = 4
    OnClick = EnabledStateChange
  end
  object InterceptJunctionCopying: TCheckBox
    Left = 24
    Top = 208
    Width = 395
    Height = 17
    Hint = 
      'Whenever you try to copy a junction point in Explorer, NTFS Link' +
      ' will ask whether you want to copy the junction only, or all the' +
      ' contents of the target folder'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Intercept Copying of Junction Points'
    TabOrder = 6
  end
  object bOK: TButton
    Left = 277
    Top = 281
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 8
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 357
    Top = 281
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 9
    OnClick = bCancelClick
  end
  object JunctionTrackingMode: TComboBox
    Left = 184
    Top = 233
    Width = 234
    Height = 21
    Hint = 
      'NTFS Link can save information about the junctions you created, ' +
      'and warn you, if you attempt to delete a folder with junctions p' +
      'ointing to'
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 7
    Text = 'Prefer Streams, if not available Registry'
    Items.Strings = (
      'Prefer Streams, if not available Registry'
      'Always in Registry'
      'Always in Streams (does not work on FAT)'
      'Deactivate')
  end
  object JunctionOverlay: TJvComboEdit
    Left = 96
    Top = 104
    Width = 321
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonFlat = False
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 3
    OnButtonClick = OverlayIconChange
  end
  object HardlinkOverlay: TJvComboEdit
    Left = 96
    Top = 160
    Width = 321
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonFlat = False
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 5
    OnButtonClick = OverlayIconChange
  end
  object IntegrateIntoContextMenu: TCheckBox
    Left = 24
    Top = 40
    Width = 395
    Height = 17
    Hint = 
      'Adds a menu item into the context menu of junction points und em' +
      'pty directories'
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Integrate into Explorer Right-Click menu'
    TabOrder = 1
  end
  object JvChangeIconDialog: TJvChangeIconDialog
    IconIndex = 0
    Left = 376
    Top = 80
  end
end
