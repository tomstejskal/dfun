unit DFun.IOTest;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  TestFramework,
  DFun.IO;

type
  IOTest = class(TTestCase)
  published
    procedure TestMap;
    procedure TestAndThen;
  end;

implementation

{ IOTest }

procedure IOTest.TestAndThen;
begin
  CheckEquals(3,
    IO.AndThen<String, Integer>(
      function(X: String): IIO<Integer> begin
        Result := IO.Pure<Integer>(StrToInt(X));
      end,
      IO.AndThen<Integer, String>(
        function(X: Integer): IIO<String> begin
          Result := IO.Pure<String>(IntToStr(X * 2 + 1));
        end,
        IO.Pure<Integer>(1))).Exec);
end;

procedure IOTest.TestMap;
begin
  CheckEquals(3,
    IO.Map<String, Integer>(
      function(X: String): Integer begin
        Result := StrToInt(X);
      end,
      IO.Map<Integer, String>(
        function(X: Integer): String begin
          Result := IntToStr(X * 2 + 1);
        end,
        IO.Pure<Integer>(1))).Exec);
end;

initialization
  RegisterTest(IOTest.Suite);
end.

