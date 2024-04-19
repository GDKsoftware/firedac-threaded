unit ThreadedConnections.Interfaces;

interface

uses
  FireDAC.Comp.Client;

type
  IThreadedConnection = interface
    ['{5CB055D0-9472-41B4-937B-E4C01F3D0B77}']

    {$REGION 'Getters and setters'}
    function GetThreadId: TThreadId;
    function GetConnectionName: string;
    function GetConnection: TFDConnection;
    {$ENDREGION}

    function BelongsTo(const Thread: TThreadId; const ConnectionName: string): Boolean;

    property ThreadId: TThreadId read GetThreadId;
    property ConnectionName: string read GetConnectionName;
    property Connection: TFDConnection read GetConnection;
  end;

implementation

end.
