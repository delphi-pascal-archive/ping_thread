object Form1: TForm1
  Left = 213
  Top = 128
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PingThread'
  ClientHeight = 285
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 136
    Width = 93
    Height = 16
    Caption = #1058#1072#1081#1084#1072#1091#1090' ('#1084#1089'):'
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 123
    Height = 16
    Caption = #1053#1072#1095#1072#1083#1100#1085#1099#1081' '#1072#1076#1088#1077#1089':'
  end
  object Label3: TLabel
    Left = 8
    Top = 64
    Width = 113
    Height = 16
    Caption = #1050#1086#1085#1077#1095#1085#1099#1081' '#1072#1076#1088#1077#1089':'
  end
  object Label5: TLabel
    Left = 8
    Top = 168
    Width = 61
    Height = 16
    Caption = #1055#1086#1090#1086#1082#1086#1074':'
  end
  object Memo1: TMemo
    Left = 216
    Top = 8
    Width = 297
    Height = 249
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 8
    Top = 32
    Width = 201
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '10.10.79.1'
  end
  object Edit2: TEdit
    Left = 8
    Top = 88
    Width = 201
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = '10.10.79.32'
  end
  object Edit3: TEdit
    Left = 112
    Top = 128
    Width = 97
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = '100'
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 200
    Width = 201
    Height = 17
    Caption = 'Save to file'
    TabOrder = 4
  end
  object Button1: TButton
    Left = 8
    Top = 232
    Width = 201
    Height = 25
    Caption = 'Ping'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Edit5: TEdit
    Left = 80
    Top = 160
    Width = 129
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    Text = '2'
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 266
    Width = 523
    Height = 19
    Panels = <
      item
        Width = 120
      end
      item
        Width = 90
      end
      item
        Width = 170
      end
      item
        Width = 50
      end>
  end
  object SaveDialog1: TSaveDialog
    Left = 256
    Top = 16
  end
  object XPManifest1: TXPManifest
    Left = 224
    Top = 16
  end
end
