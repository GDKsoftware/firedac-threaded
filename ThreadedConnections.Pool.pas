unit ThreadedConnections.Pool;

interface

uses
  System.Generics.Collections,
  ThreadedConnections.Interfaces,
  FireDAC.Comp.Client;

type
  TThreadedConnectionList = TThreadList<IThreadedConnection>;

  TThreadedConnectionPool = class(TInterfacedObject)
  private
    FThreadedConnections: TThreadedConnectionList;

    function TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out Connection: TFDConnection): Boolean;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function GetConnection(const ConnectionName: string): TFDConnection; overload;
    function GetConnection(const ConnectionName: string; const ThreadId: TThreadId): TFDConnection; overload;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  ThreadedConnections.Connection;

{ TThreadedConnectionPool }

procedure TThreadedConnectionPool.AfterConstruction;
begin
  inherited;
  FThreadedConnections := TThreadedConnectionList.Create;
end;

procedure TThreadedConnectionPool.BeforeDestruction;
begin
  inherited;
  FreeAndNil(FThreadedConnections);
end;

function TThreadedConnectionPool.GetConnection(const ConnectionName: string): TFDConnection;
begin
  var CurrentThreadId := TThread.Current.ThreadID;

  Result := GetConnection(ConnectionName, CurrentThreadId);
end;

function TThreadedConnectionPool.GetConnection(const ConnectionName: string; const ThreadId: TThreadId): TFDConnection;
begin
  if not TryFindConnection(ThreadId, ConnectionName, Result) then
  begin
    Result := TFDConnection.Create(nil);
    Result.ConnectionDefName := ConnectionName;

    var ThreadedConnection := TThreadedConnection.Create(ThreadId, ConnectionName, Result);
    FThreadedConnections.Add(ThreadedConnection);
  end;
end;

function TThreadedConnectionPool.TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out Connection: TFDConnection): Boolean;
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

end.
