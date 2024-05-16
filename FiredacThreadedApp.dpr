program FiredacThreadedApp;

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  ThreadedConnections.Connection in 'ThreadedConnections.Connection.pas',
  ThreadedConnections.Interfaces in 'ThreadedConnections.Interfaces.pas',
  ThreadedConnections.Pool in 'ThreadedConnections.Pool.pas',
  ThreadedConnections.Thread in 'ThreadedConnections.Thread.pas',
  ThreadedConnections.Singleton in 'ThreadedConnections.Singleton.pas',
  ThreadedConnections.Example.Threads in 'Examples\ThreadedConnections.Example.Threads.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
