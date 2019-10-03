program DFunTests;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  DFun.Either in '..\DFun.Either.pas',
  DFun.List in '..\DFun.List.pas',
  DFun.Maybe in '..\DFun.Maybe.pas',
  DFun.Pair in '..\DFun.Pair.pas',
  DFun.Null in '..\DFun.Null.pas',
  DFun.ListTest in 'DFun.ListTest.pas',
  DFun.IOTest in 'DFun.IOTest.pas',
  DFun.IO in '..\DFun.IO.pas';

{R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

