Program SerialPi;

Uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  DaemonApp, lazdaemonapp, DaemonMapperUnit1, unit_daemonSerPi
  { add your units here };

begin
  Application.Initialize;
  Application.Run;
end.
