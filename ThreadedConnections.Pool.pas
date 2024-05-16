unit ThreadedConnections.Pool;

interface

uses
  System.Generics.Collections,
  ThreadedConnections.Interfaces,
  FireDAC.Comp.Client;

type
  TThreadedConnectionList = TThreadList<IThreadedConnection>;

  TThreadedConnectionPool = class(TInterfacedObject, IThreadedConnectionPool)
  private
    FLock: TObject;
    FThreadedConnections: TThreadedConnectionList;
    FDefaultConnectionName: string;
    FDriverId: string;

    function GetDefaultConnectionName: string;
    procedure SetDefaultConnectionName(const Value: string);

    /// <summary>
    ///   Find a registered, existing connection for the given thread and connection name.
    /// </summary>
    function TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out Connection: TFDCustomConnection): Boolean;

    /// <summary>
    ///   Returns all the threaded connections for the given thread.
    /// </summary>
    function GetConnectionsForThread(const ThreadId: TThreadId): TArray<IThreadedConnection>;

    procedure ClearConnections;
    procedure ClearThreadedConnection(const ThreadedConnection: IThreadedConnection);
  public
    constructor Create(const DriverId, DefaultConnectionName: string);

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function GetConnection: TFDCustomConnection; overload;
    function GetConnection(const ThreadId: TThreadId): TFDCustomConnection; overload;
    function GetConnection(const ConnectionName: string): TFDCustomConnection; overload;
    function GetConnection(const ConnectionName: string; const ThreadId: TThreadId): TFDCustomConnection; overload;

    procedure Clear(const ThreadId: TThreadId);

    property DefaultConnectionName: string read GetDefaultConnectionName write SetDefaultConnectionName;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  ThreadedConnections.Connection;

{ TThreadedConnectionPool }

constructor TThreadedConnectionPool.Create(const DriverId, DefaultConnectionName: string);
begin
  inherited Create;
  FDriverId := DriverId;
  FDefaultConnectionName := DefaultConnectionName;
end;

procedure TThreadedConnectionPool.AfterConstruction;
begin
  inherited;
  FThreadedConnections := TThreadedConnectionList.Create;
  FLock := TObject.Create;
end;

procedure TThreadedConnectionPool.BeforeDestruction;
begin
  inherited;
  ClearConnections;
  FreeAndNil(FThreadedConnections);
  FreeAndNil(FLock);
end;

function TThreadedConnectionPool.GetConnection: TFDCustomConnection;
begin
  Result := GetConnection(FDefaultConnectionName);
end;

function TThreadedConnectionPool.GetConnection(const ThreadId: TThreadId): TFDCustomConnection;
begin
  Result := GetConnection(FDefaultConnectionName, ThreadId);
end;

function TThreadedConnectionPool.GetConnection(const ConnectionName: string): TFDCustomConnection;
begin
  var CurrentThreadId := TThread.Current.ThreadID;

  Result := GetConnection(ConnectionName, CurrentThreadId);
end;

function TThreadedConnectionPool.GetConnection(const ConnectionName: string; const ThreadId: TThreadId): TFDCustomConnection;
begin
  TMonitor.Enter(FLock);
  try
    if not TryFindConnection(ThreadId, ConnectionName, Result) then
    begin
  //    if FDManager.Active then
  //    begin
  //      Result := FDManager.AcquireConnection(ConnectionName, ThreadId.ToString);
  //    end
  //    else
      begin
        Result := TFDCustomConnection.Create(nil);
        Result.ConnectionDefName := ConnectionName;
        Result.CheckConnectionDef;

//        Result.DriverName := FDriverId;
      end;

      var ThreadedConnection := TThreadedConnection.Create(ThreadId, ConnectionName, Result);
      FThreadedConnections.Add(ThreadedConnection);
    end;
  finally
     TMonitor.Exit(FLock);
  end;
end;

function TThreadedConnectionPool.TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out Connection: TFDCustomConnection): Boolean;
begin
  Result := False;

  var Connections := FThreadedConnections.LockList;
  try
    for var ThreadedConnection in Connections do
    begin
      if not ThreadedConnection.BelongsTo(ThreadId, ConnectionName) then
        Continue;

      Connection := ThreadedConnection.Connection;
      Result := True;

      Break;
    end;
  finally
    FThreadedConnections.UnlockList;
  end;
end;

procedure TThreadedConnectionPool.Clear(const ThreadId: TThreadId);
begin
  var ConnectionsToClear := GetConnectionsForThread(ThreadId);

  for var ThreadedConnection in ConnectionsToClear do
    ClearThreadedConnection(ThreadedConnection);
end;

procedure TThreadedConnectionPool.ClearConnections;
begin
  var Connections := FThreadedConnections.LockList;
  try
    var ConnectionsToClear := Connections.ToArray;

    for var ThreadedConnection in ConnectionsToClear do
      ClearThreadedConnection(ThreadedConnection);
  finally
    FThreadedConnections.UnlockList;
  end;
end;

procedure TThreadedConnectionPool.ClearThreadedConnection(const ThreadedConnection: IThreadedConnection);
begin
  try
    ThreadedConnection.Connection.Close;
    FreeAndNil(ThreadedConnection.Connection);
  except
    // Ignoring exceptions while clearing
  end;

  FThreadedConnections.Remove(ThreadedConnection);
end;

function TThreadedConnectionPool.GetConnectionsForThread(const ThreadId: TThreadId): TArray<IThreadedConnection>;
begin
  Result := [];

  var Items := FThreadedConnections.LockList;
  try
    for var ThreadedConnection in Items do
    begin
      var IsSameThread := (ThreadedConnection.ThreadId = ThreadId);
      if not IsSameThread then
        Continue;

      Result := Result + [ThreadedConnection];
    end;
  finally
    FThreadedConnections.UnlockList;
  end;
end;

function TThreadedConnectionPool.GetDefaultConnectionName: string;
begin
  Result := FDefaultConnectionName;
end;

procedure TThreadedConnectionPool.SetDefaultConnectionName(const Value: string);
begin
  FDefaultConnectionName := Value;
end;

end.
