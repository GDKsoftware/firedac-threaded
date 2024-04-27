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
    FConnection: TFDCustomConnection;
    function GetThreadId: TThreadId;
    function GetConnectionName: string;
    function GetConnection: TFDCustomConnection;
  public
    constructor Create(const ThreadId: TThreadId; const ConnectionName: string; const Connection: TFDCustomConnection);

    function BelongsTo(const Thread: TThreadId; const ConnectionName: string): Boolean;

    property ThreadId: TThreadId read GetThreadId;
    property ConnectionName: string read GetConnectionName;
    property Connection: TFDCustomConnection read GetConnection;
  end;

implementation

uses
  System.SysUtils;

{ TThreadedConnection }

constructor TThreadedConnection.Create(const ThreadId: TThreadId; const ConnectionName: string; const Connection: TFDCustomConnection);
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

function TThreadedConnection.GetConnection: TFDCustomConnection;
begin
  Result := FConnection;
end;

end.
