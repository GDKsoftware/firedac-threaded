unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, Vcl.StdCtrls,
  FireDAC.DApt;

type
  TMainForm = class(TForm)
    FDConnection: TFDConnection;
    btnInitializeManager: TButton;
    procedure btnInitializeManagerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.IOUtils;

const
  ConnectionName = 'FDTHREADED';

{$R *.dfm}

procedure TMainForm.btnInitializeManagerClick(Sender: TObject);
begin
  var ExePath := TPath.GetDirectoryName(ParamStr(0));
  var DbPath := TPath.Combine(ExePath, '..\..\..\Resources\FiredacThreadedTest.db');
  DbPath := TPath.GetFullPath(DbPath);

  var Definition := FDManager.ConnectionDefs.AddConnectionDef;
  Definition.Name := ConnectionName;

  var Params := TFDPhysSQLiteConnectionDefParams(Definition.Params);
  Params.DriverID := 'SQLite';
  Params.Database := DbPath;

  Definition.Apply;

  var Connection := FDManager.AcquireConnection(ConnectionName, '');
  Connection.Connected := True;

  var NbOfTables := -1;
  var Query := TFDQuery.Create(Self);
  try
    Query.Connection := Connection;
    Query.SQL.Text := 'SELECT count(*) FROM sqlite_master WHERE type = :TYPE';
    Query.Params[0].AsString := 'table';

    Query.Open;
    Query.First;

    if not Query.Eof then
      NbOfTables := Query.Fields[0].AsInteger;

  finally
    Query.Free;
  end;

  if NbOfTables = -1 then
    MessageDlg('Query to SQLite database failed.', mtError, [mbOk], 0)
  else
    MessageDlg(Format('Number of tables in SQLite database: %d.', [NbOfTables]), mtError, [mbOk], 0)
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  try
    var Definition := FDManager.ConnectionDefs.ConnectionDefByName(ConnectionName);
    FDManager.DeleteConnectionDef(ConnectionName);
  except
    on E: EFDException do
    begin
      // Definition does not exist
    end;
  end;
end;

end.
