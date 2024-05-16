unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, Vcl.StdCtrls,
  FireDAC.DApt;

type
  TMainForm = class(TForm)
    btnCheckConnection: TButton;
    btnTestThreads: TButton;
    procedure btnCheckConnectionClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnTestThreadsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function GetDatabasePath: string;
    procedure AddDatabaseDefinition;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.IOUtils,
  ThreadedConnections.Singleton,
  FireDAC.Stan.Param,
  System.UITypes,
  System.Threading,
  ThreadedConnections.Example.Threads;

const
  DatabaseDriver = 'SQLite';
  ConnectionName = 'FDTHREADED';


{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDManager.Active := True;

  AddDatabaseDefinition;
  SetConnectionPoolDefaults(DatabaseDriver, ConnectionName);
end;

procedure TMainForm.AddDatabaseDefinition;
begin
  var Params := TStringList.Create;
  try
    var DatabasePath := GetDatabasePath;

    Params.Add('DriverID=' + DatabaseDriver);
    Params.Add('Database=' + DatabasePath);

    FDManager.AddConnectionDef(ConnectionName, 'SQLite', Params);

    var Definition := FDManager.ConnectionDefs.FindConnectionDef(ConnectionName);

    var DefParams := TFDPhysSQLiteConnectionDefParams(Definition.Params);
    DefParams.BeginUpdate;
    try
      DefParams.LockingMode := TFDSQLiteLockingMode.lmNormal;
      DefParams.Synchronous := TFDSQLiteSynchronous.snNormal;
    finally
      DefParams.EndUpdate;
    end;
  finally
    Params.Free;
  end;
end;

function TMainForm.GetDatabasePath: string;
begin
  var ExePath := TPath.GetDirectoryName(ParamStr(0));
  var DbPath := TPath.Combine(ExePath, '..\..\..\Resources\FiredacThreadedTest.db');

  Result := TPath.GetFullPath(DbPath);
end;

procedure TMainForm.btnCheckConnectionClick(Sender: TObject);
begin
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

procedure TMainForm.btnTestThreadsClick(Sender: TObject);
begin
  var Threads: TArray<TThread>;

  for var i := 100 to 120 do
  begin
    var Thread := TInsertNumbersThread.Create(True, GetConnectionPool);
    Thread.FreeOnTerminate := True;

    Thread.Number := i;
    Threads := Threads + [Thread];
  end;

  for var Thread in Threads do
    Thread.Start;
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
