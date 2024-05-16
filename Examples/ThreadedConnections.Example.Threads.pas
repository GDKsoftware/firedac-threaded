unit ThreadedConnections.Example.Threads;

interface

uses
  ThreadedConnections.Thread;

type
  TInsertNumbersThread = class(TThreadedConnectionThread)
  private
    FNumber: Integer;
  protected
    procedure Execute; override;
  public
    property Number: Integer write FNumber;
  end;

implementation

uses
  FireDAC.Comp.Client,
  System.SysUtils;

{ TInsertNumbersThread }

procedure TInsertNumbersThread.Execute;
begin
  inherited;
  var Connection := GetConnection;

  Connection.StartTransaction;
  try
    var Query := TFDQuery.Create(nil);
    try
      Query.Connection := Connection;
      Query.SQL.Text := 'INSERT INTO Numbers (IntValue) VALUES (:INTVALUE)';

      Query.Params[0].AsInteger := FNumber;
      Query.ExecSQL;
    finally
      Query.Free;
    end;

    Connection.Commit;
  except
    on E: Exception do
    begin
      Connection.Rollback;
      raise;
    end;
  end;
end;

end.
