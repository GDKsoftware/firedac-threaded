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
  OnDestroy = FormDestroy
  TextHeight = 15
  object btnInitializeManager: TButton
    Left = 56
    Top = 200
    Width = 121
    Height = 25
    Caption = 'Initialize manager'
    TabOrder = 0
    OnClick = btnInitializeManagerClick
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      
        'Database=C:\Sources\Delphi\GitHub\firedac-threaded\Resources\Fir' +
        'edacThreadedTest.db'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 72
    Top = 120
  end
end
