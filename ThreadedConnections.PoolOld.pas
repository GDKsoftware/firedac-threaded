unit ThreadedConnections.PoolOld;

interface

uses
  System.Generics.Collections,
  Firedac.Comp.Client,
  System.SysUtils;

type
  TConnectionInfo = record
    Connection: TFDConnection;
    RunningThreadId: TThreadId;
  end;

  TThreadedConnections = class(TThreadList<TConnectionInfo>)
  public
    procedure BeforeDestruction; override;

    function TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out ConnectionFound: TFDConnection): Boolean;
  end;

  TThreadedConnectionHelper = class
  private
    class var Instance: TThreadedConnections;
  public
    class procedure Initialise;
    class procedure Finalise;

    class function GetConnection(const ConnectionName: string): TFDConnection;

    class procedure CleanConnectionsForThread(const ThreadId: TThreadId);
  end;

implementation

uses
  System.Classes;

{ TThreadedConnections }

procedure TThreadedConnections.BeforeDestruction;
begin
  inherited;

  var Items := Self.LockList;
  try
    for var ConnectionInfo in Items do
    begin
      try
        FreeAndNil(ConnectionInfo.Connection);
      except
        raise ENotImplemented.Create('Exception when freeing the connection on destruction...');
      end;
    end;
  finally
    Self.UnlockList;
  end;
end;

function TThreadedConnections.TryFindConnection(const ThreadId: TThreadId; const ConnectionName: string; out ConnectionFound: TFDConnection): Boolean;
begin
  Result := False;

  var Items := Self.LockList;
  try
    for var ConnectionInfo in Items do
    begin
      var IsSameThread := (ConnectionInfo.RunningThreadId = ThreadId);
      if not IsSameThread then
        Continue;

      var IsSameConnectionName := (ConnectionInfo.Connection.ConnectionDefName = ConnectionName);
      if not IsSameConnectionName then
        Continue;

      ConnectionFound := ConnectionInfo.Connection;
      Result := True;

      Break;
    end;
  finally
    Self.UnlockList;
  end;
end;

{ TThreadedConnectionHelper }

class procedure TThreadedConnectionHelper.Initialise;
begin
  Self.Instance := TThreadedConnections.Create;
end;

class procedure TThreadedConnectionHelper.Finalise;
begin
  FreeAndNil(Self.Instance);
end;

class function TThreadedConnectionHelper.GetConnection(const ConnectionName: string): TFDConnection;
begin
  var CurrentThread := TThread.Current;

  if not Self.Instance.TryFindConnection(CurrentThread.ThreadID, ConnectionName, Result) then
  begin
    Result := TFDConnection.Create(nil);
    Result.ConnectionDefName := ConnectionName;

    var ConnectionInfo: TConnectionInfo;
    ConnectionInfo.Connection := Result;
    ConnectionInfo.RunningThreadId := CurrentThread.ThreadID;

    Self.Instance.Add(ConnectionInfo);
  end;
end;

class procedure TThreadedConnectionHelper.CleanConnectionsForThread(const ThreadId: TThreadId);
begin
  var InfoToRemove: TArray<TConnectionInfo>;

  var Items := Self.Instance.LockList;
  try
    for var ConnectionInfo in Items do
    begin
      var IsSameThread := (ConnectionInfo.RunningThreadId = ThreadId);
      if not IsSameThread then
        Continue;

      InfoToRemove := InfoToRemove + [ConnectionInfo];
    end;
  finally
    Self.Instance.UnlockList;
  end;

  for var ConnectionInfo in InfoToRemove do
  begin
    try
      ConnectionInfo.Connection.Close;
      FreeAndNil(ConnectionInfo.Connection);
    except
      raise ENotImplemented.Create('Exception when freeing the connection...');
    end;

    Self.Instance.Remove(ConnectionInfo);
  end;
end;

end.
