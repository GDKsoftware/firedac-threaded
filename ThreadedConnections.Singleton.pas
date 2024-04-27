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

function GetConnectionPool: IThreadedConnectionPool;
begin
  if not Assigned(_ConnectionPool) then
    _ConnectionPool := TThreadedConnectionPool.Create(_DriverId, _ConnectionName);

  Result := _ConnectionPool;
end;

procedure SetConnectionPoolDefaults(const DriverId, ConnectionName: string);
begin
  _DriverId := DriverId;
  _ConnectionName := ConnectionName;
end;

initialization
  _ConnectionPool := nil;
  _DriverId := '';
  _ConnectionName := '';

end.
