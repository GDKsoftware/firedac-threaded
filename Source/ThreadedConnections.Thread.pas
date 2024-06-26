unit ThreadedConnections.Thread;

interface

uses
  System.Classes,
  ThreadedConnections.Interfaces,
  FireDAC.Comp.Client;

type
  TThreadedConnectionThread = class(TThread)
  private
    FConnectionPool: IThreadedConnectionPool;
  protected
    function GetConnection: TFDCustomConnection; overload;
    function GetConnection(const ConnectionName: string): TFDCustomConnection; overload;
  public
    constructor Create(const CreateSuspended: Boolean; const ConnectionPool: IThreadedConnectionPool);
    procedure BeforeDestruction; override;
  end;

implementation

{ TThreadedConnectionThread }

constructor TThreadedConnectionThread.Create(const CreateSuspended: Boolean; const ConnectionPool: IThreadedConnectionPool);
begin
  inherited Create(CreateSuspended);
  FConnectionPool := ConnectionPool;
end;

function TThreadedConnectionThread.GetConnection: TFDCustomConnection;
begin
  Result := FConnectionPool.GetConnection(Self.ThreadID);
end;

function TThreadedConnectionThread.GetConnection(const ConnectionName: string): TFDCustomConnection;
begin
  Result := FConnectionPool.GetConnection(ConnectionName, Self.ThreadID);
end;

procedure TThreadedConnectionThread.BeforeDestruction;
begin
  inherited;
  FConnectionPool.Clear(Self.ThreadID);
end;

end.
