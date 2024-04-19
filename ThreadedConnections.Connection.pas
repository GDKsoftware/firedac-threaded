unit ThreadedConnections.Connection;

interface

uses
  ThreadedConnections.Interfaces,
  FireDAC.Comp.Client;

type
  TThreadedConnection = class(TInterfacedObject, IThreadedConnection)
  private
    FThreadId: TThreadId;
    FConnectionName: string;
    FConnection: TFDConnection;
    function GetThreadId: TThreadId;
    function GetConnectionName: string;
    function GetConnection: TFDConnection;
  public
    constructor Create(const ThreadId: TThreadId; const ConnectionName: string; const Connection: TFDConnection);

    function BelongsTo(const Thread: TThreadId; const ConnectionName: string): Boolean;

    property ThreadId: TThreadId read GetThreadId;
    property ConnectionName: string read GetConnectionName;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

uses
  System.SysUtils;

{ TThreadedConnection }

constructor TThreadedConnection.Create(const ThreadId: TThreadId; const ConnectionName: string; const Connection: TFDConnection);
begin
  inherited Create;
  FThreadId := ThreadId;
  FConnectionName := ConnectionName;
  FConnection := Connection;
end;

function TThreadedConnection.BelongsTo(const Thread: TThreadId; const ConnectionName: string): Boolean;
begin
  Result := (Thread = FThreadId);
  if not Result then
    Exit;

  Result := SameText(ConnectionName, FConnection.ConnectionDefName);
end;

function TThreadedConnection.GetThreadId: TThreadId;
begin
  Result := FThreadId;
end;

function TThreadedConnection.GetConnectionName: string;
begin
  Result := FConnectionName;
end;

function TThreadedConnection.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

end.
