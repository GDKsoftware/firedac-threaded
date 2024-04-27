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
    function GetConnection: TFDCustomConnection;
    {$ENDREGION}

    function BelongsTo(const Thread: TThreadId; const ConnectionName: string): Boolean;

    property ThreadId: TThreadId read GetThreadId;
    property ConnectionName: string read GetConnectionName;
    property Connection: TFDCustomConnection read GetConnection;
  end;

  IThreadedConnectionPool = interface
    ['{9D955C2E-8757-4751-B56B-7E3792B367F1}']

    {$REGION 'Getters and setters'}
    function GetDefaultConnectionName: string;
    procedure SetDefaultConnectionName(const Value: string);
    {$ENDREGION}

    /// <summary>
    ///   Get connection for the default connection name and running thread
    /// </summary>
    function GetConnection: TFDCustomConnection; overload;

    /// <summary>
    ///   Get connection for the default connection name and given thread
    /// </summary>
    function GetConnection(const ThreadId: TThreadId): TFDCustomConnection; overload;

    /// <summary>
    ///   Get or create a connection for the given connection name and running thread
    /// </summary>
    function GetConnection(const ConnectionName: string): TFDCustomConnection; overload;

    /// <summary>
    ///   Get or create a connection for the given connection name and thread
    /// </summary>
    function GetConnection(const ConnectionName: string; const ThreadId: TThreadId): TFDCustomConnection; overload;

    /// <summary>
    ///   Clear the connections for the given thread.
    /// </summary>
    procedure Clear(const ThreadId: TThreadId);


    /// <summary>
    ///   Default connection name when no name is specified to get a connection
    /// </summary>
    property DefaultConnectionName: string read GetDefaultConnectionName write SetDefaultConnectionName;
  end;

implementation

end.
