unit unit_daemonSerPi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DaemonApp, Serial;

type
  TDaemonSerPi = class(TDaemon)
    procedure DataModuleExecute(Sender: TCustomDaemon);
    procedure DataModuleShutDown(Sender: TCustomDaemon);
    procedure DataModuleStart(Sender: TCustomDaemon; var OK: boolean);
    procedure DataModuleStop(Sender: TCustomDaemon; var OK: boolean);
  private
    procedure SendLine(const fstr: string);
  public
  end;


var
  DaemonSerPi: TDaemonSerPi;
  Log: TextFile;
  FSerHandle : TSerialHandle;


implementation

procedure RegisterDaemon;
begin
  RegisterDaemonClass(TDaemonSerPi);
end;

{$R *.lfm}

(*
output looks like this
ST,+00000.01  g
ST,+00007.12  g
ST,+00003.28  g
*)

procedure TDaemonSerPi.SendLine(const fstr:string);
begin
  WriteLn(Log, FStr + datetimetostr(Now));
  Flush(Log);
  LogMessage(DateTimeToStr(Now));
end;

procedure TDaemonSerPi.DataModuleExecute(Sender: TCustomDaemon);
var
  fstr:string;
  FCount:longint;
  i:integer;
  buffer:array[0..256] of byte;
  fsleep:boolean;
begin
  for i:=0 to 256 do
      buffer[i]:=0;
  fsleep:=false;

  while Self.Status = csRunning do
  begin
    if fsleep then sleep(1000);  // sleep if we didn't just do something
    fsleep:=true;

    fstr:='';

    FCount:=SerRead(FSerHandle, buffer, sizeof(buffer));
    while (FCount>0) do
    begin
      fsleep:=false;
      for i:=0 to FCount-1 do
        if ((buffer[i]>0) and (buffer[i]<128)) then
           fstr:=fstr+char(buffer[i]);

      // a line-feed is the signal to spit it out
      if (buffer[i]=10) then
      begin
        SendLine(fstr);
        fstr:='';
      end;

      FCount:=SerRead(FSerHandle, buffer, sizeof(buffer));
    end;

    if fstr<>'' then
    begin
         SendLine(fstr);
         fstr:='';
    end;
  end;
end;


procedure TDaemonSerPi.DataModuleShutDown(Sender: TCustomDaemon);
begin
  WriteLn(Log, 'Shutdown');
  Flush(Log);
  if (FSerHandle<>0) then
    SerClose(FSerHandle);
end;

procedure TDaemonSerPi.DataModuleStart(Sender: TCustomDaemon; var OK: boolean);
begin
  OK := True;
  WriteLn(Log, 'Start');
  Flush(Log);
  FSerHandle:=SerOpen('/dev/ttyACM0');
//  FSerHandle:=SerOpen('/dev/ttyUSB0');
  if (FSerHandle<>0) then
     SerSetParams(FSerHandle, 2400, 7, EvenParity, 1, []);
end;

procedure TDaemonSerPi.DataModuleStop(Sender: TCustomDaemon; var OK: boolean);
begin
  OK := True;
  WriteLn(Log, 'Stop');
  Flush(Log);
  SerClose(FSerHandle);
  FSerhandle:=0;
end;


initialization
  RegisterDaemon;
  AssignFile(Log, 'SerialPi.txt');
  Rewrite(Log);
end.


