object Form1: TForm1
  Left = 192
  Top = 109
  Width = 443
  Height = 437
  Caption = 'NTFS Link Configuration'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    435
    407)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 51
    Height = 13
    Caption = 'Language:'
  end
  object ComboBox1: TComboBox
    Left = 88
    Top = 16
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    Text = 'ComboBox1'
  end
  object CheckBox1: TCheckBox
    Left = 24
    Top = 56
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Drag&&Drop Extension'
    TabOrder = 1
  end
  object CheckBox2: TCheckBox
    Left = 24
    Top = 80
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Junction Overlay'
    TabOrder = 2
  end
  object CheckBox3: TCheckBox
    Left = 24
    Top = 128
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Enable Hardlink Overlay'
    TabOrder = 3
  end
  object CheckBox4: TCheckBox
    Left = 24
    Top = 184
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Intercept Deletion of Junctions'
    TabOrder = 4
  end
  object CheckBox5: TCheckBox
    Left = 24
    Top = 208
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Intercept Copying/Moving of Junctions'
    TabOrder = 5
  end
  object CheckBox6: TCheckBox
    Left = 24
    Top = 256
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'PropertySheet Extension'
    TabOrder = 6
  end
  object CheckBox7: TCheckBox
    Left = 24
    Top = 280
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Column Extension'
    TabOrder = 7
  end
  object CheckBox8: TCheckBox
    Left = 24
    Top = 304
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'ContextMenu Extension'
    TabOrder = 8
  end
  object CheckBox9: TCheckBox
    Left = 24
    Top = 328
    Width = 390
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'ShellNew Items'
    TabOrder = 9
  end
  object Button1: TButton
    Left = 184
    Top = 368
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 10
  end
  object Button2: TButton
    Left = 264
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 11
  end
  object Button3: TButton
    Left = 344
    Top = 368
    Width = 75
    Height = 25
    Caption = 'About...'
    TabOrder = 12
  end
  object JvFilenameEdit1: TJvFilenameEdit
    Left = 48
    Top = 104
    Width = 353
    Height = 21
    ButtonFlat = False
    TabOrder = 13
    Text = 'JvFilenameEdit1'
  end
  object JvFilenameEdit2: TJvFilenameEdit
    Left = 48
    Top = 144
    Width = 353
    Height = 21
    ButtonFlat = False
    TabOrder = 14
    Text = 'JvFilenameEdit1'
  end
end
