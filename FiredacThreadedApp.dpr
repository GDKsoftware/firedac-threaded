program FiredacThreadedApp;

uses
  Vcl.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  ThreadedConnections.PoolOld in 'ThreadedConnections.PoolOld.pas',
  ThreadedConnections.Connection in 'ThreadedConnections.Connection.pas',
  ThreadedConnections.Interfaces in 'ThreadedConnections.Interfaces.pas',
  ThreadedConnections.Pool in 'ThreadedConnections.Pool.pas',
  ThreadedConnections.Thread in 'ThreadedConnections.Thread.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
