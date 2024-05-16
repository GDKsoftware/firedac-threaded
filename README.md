# Threaded Firedac connections
## Introduction
There is no easy way in Firedac to support threaded connections. By default, the Firedac connection is not thread-safe. This means that if you try to do things in the database with multiple threads at the same time, using the same connection, this can (and usually will) result in exceptions. This library contains a solution to this via a connection pool that makes this easier.

## How it works
The connection pool assumes that you are working with connection definitions. This is easy to implement, even dynamically if not used by default. An example can be found in the main form of the application.
The connection pool can be used to request a connection. The pool checks to see if a connection already exists for the thread and the given connection definition. If so, the connection is returned, if not, it is created and registered. To keep this administration correct during application execution, an implementation of a singleton has been added.

You can register a name for the default connection definition in the connection pool, so you don't have to specify it each time. The id of the thread requesting a connection can also be automatically determined by the pool.

There is also a base class for threads that want to use the connection pool. An example using this base class is also included, and worked out in the main form of the application.

## Configuration
Include `ThreadedConnections.Singleton` in your project or data module. Call the `SetConnectionPoolDefaults` method to initialize the singleton for the connection pool. For example:

    SetConnectionPoolDefaults('SQLite', 'MainDatabase');

In this example, `'SQLite'` is the driver and `'MainDatabase'` the name of your connection definition.

If connection definitions are not being used, you can easily create them dynamically using the same parameters as your connection. The following example assumes that there is a connection called `dmDatabase.DbConnection`.

    const DefinitionName = 'MainDatabase';
    var Definition := FDManager.ConnectionDefs.FindConnectionDef(DefinitionName);
    
    if not Assigned(Definition) then
    begin
	  var Connection := dmDatabase.DbConnection;
	  FDManager.AddConnectionDef(DefinitionName, Connection.ActualDriverID, Connection.Params);
	end;
	
## How to use
When using the singleton, its instance can be retrieved using the `GetConnectionPool` function. This function is available in the `ThreadedConnections.Singleton` unit.
The pool has access to a number of `GetConnection` functions to request a connection. The no parameter variant assumes that you are doing this for the default connection definition and for the current thread. This can also be the main thread.

    var Pool := GetConnectionPool;
    var DefaultConnection := Pool.GetConnection;
    var SpecificConnection := Pool.GetConnection('FinancialDatabase', Self.ThreadID);

You can use `TThreadedConnectionThread` as a superclass for your threads. This class expects an instance of the connection pool on creation. It provides standard functions to easily get a connection in the subclasses. An example of this can be found in `ThreadedConnections.Example.Threads`. Of course, it is also possible to use the superclass as an example for implementation in your own superclass for threads.

Here is an example how to use it when using the `TThreadedConnectionThread` as superclass:

    TMyDatabaseThread = class(TThreadedConnectionThread)
    protected
      procedure Execute; override;
    end;
    
    TMyDatabaseThread.Execute;
    begin
      var Query := TFDQuery.Create;
      try
	    Query.Connection := GetConnection;
	    ...
      finally
        Query.Free;
      end;
    end;
    
    var Thread := TMyDatabaseThread.Create(True, GetConnectionPool);
    Thread.Start;
