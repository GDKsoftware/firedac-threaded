unit ThreadedConnections.Singleton;

interface

uses
  ThreadedConnections.Interfaces;

function GetConnectionPool: IThreadedConnectionPool;
procedure SetConnectionPoolDefaults(const DriverId, ConnectionName: string);


implementation

uses
  ThreadedConnections.Pool;

var
  _ConnectionPool: IThreadedConnectionPool;
  _DriverId, _ConnectionName: string;


procedure CreateConnectionPool;
begin
  if Assigned(_ConnectionPool) then
    Exit;

  _ConnectionPool := TThreadedConnectionPool.Create(_DriverId, _ConnectionName);
end;

function GetConnectionPool: IThreadedConnectionPool;
begin
  CreateConnectionPool;
  Result := _ConnectionPool;
end;

procedure SetConnectionPoolDefaults(const DriverId, ConnectionName: string);
begin
  _DriverId := DriverId;
  _ConnectionName := ConnectionName;

  CreateConnectionPool;
end;

initialization
  _ConnectionPool := nil;
  _DriverId := '';
  _ConnectionName := '';

finalization
  _ConnectionPool := nil;

end.
