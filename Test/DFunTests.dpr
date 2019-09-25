program DFunTests;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  DFun.ListTest in 'DFun.ListTest.pas',
  DFun.Either in '..\DFun.Either.pas',
  DFun.List in '..\DFun.List.pas',
  DFun.Maybe in '..\DFun.Maybe.pas',
  DFun.Pair in '..\DFun.Pair.pas';

{R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

