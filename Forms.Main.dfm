object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Main form'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object btnCheckConnection: TButton
    Left = 56
    Top = 200
    Width = 121
    Height = 25
    Caption = 'Check connection'
    TabOrder = 0
    OnClick = btnCheckConnectionClick
  end
  object btnTestThreads: TButton
    Left = 56
    Top = 240
    Width = 121
    Height = 25
    Caption = 'Test threading'
    TabOrder = 1
    OnClick = btnTestThreadsClick
  end
end
