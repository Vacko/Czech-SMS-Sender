object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Form1'
  ClientHeight = 396
  ClientWidth = 601
  Color = clWindow
  Font.Charset = EASTEUROPE_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Sylfaen'
  Font.Style = [fsBold]
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 16
    Top = 288
    Width = 38
    Height = 14
    Caption = 'Date : '
  end
  object Label2: TLabel
    Left = 16
    Top = 310
    Width = 43
    Height = 14
    Caption = 'Name : '
  end
  object Label4: TLabel
    Left = 16
    Top = 330
    Width = 56
    Height = 14
    Caption = 'Number : '
  end
  object Label5: TLabel
    Left = 15
    Top = 352
    Width = 57
    Height = 14
    Caption = 'Country : '
  end
  object Label6: TLabel
    Left = 16
    Top = 372
    Width = 62
    Height = 14
    Caption = 'Operator : '
  end
  object Label7: TLabel
    Left = 80
    Top = 290
    Width = 4
    Height = 14
  end
  object Label8: TLabel
    Left = 78
    Top = 310
    Width = 4
    Height = 14
  end
  object Label10: TLabel
    Left = 78
    Top = 330
    Width = 4
    Height = 14
  end
  object Label11: TLabel
    Left = 78
    Top = 352
    Width = 4
    Height = 14
  end
  object Label12: TLabel
    Left = 78
    Top = 372
    Width = 4
    Height = 14
  end
  object historylistof_m: TListView
    Left = 16
    Top = 16
    Width = 465
    Height = 257
    Columns = <
      item
        Caption = 'Date : '
        Width = 150
      end
      item
        Caption = 'Number : '
        Width = 150
      end
      item
        Caption = 'Text : '
        Width = 150
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = historylistof_mSelectItem
  end
  object HDelete: TButton
    Left = 487
    Top = 16
    Width = 106
    Height = 25
    Caption = 'Delete'
    TabOrder = 1
    OnClick = HDeleteClick
  end
  object Hmessage: TMemo
    Left = 208
    Top = 288
    Width = 273
    Height = 98
    ReadOnly = True
    TabOrder = 2
  end
  object HResend: TButton
    Left = 487
    Top = 288
    Width = 106
    Height = 25
    Caption = 'ReSend'
    TabOrder = 3
    OnClick = HResendClick
  end
  object HClose: TButton
    Left = 487
    Top = 360
    Width = 106
    Height = 26
    Caption = 'Close'
    TabOrder = 4
    OnClick = HCloseClick
  end
  object add_tofriends: TButton
    Left = 487
    Top = 47
    Width = 106
    Height = 25
    Caption = 'Add to Friends'
    Enabled = False
    TabOrder = 5
    OnClick = add_tofriendsClick
  end
end
