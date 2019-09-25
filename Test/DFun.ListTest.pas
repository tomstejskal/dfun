unit DFun.ListTest;

interface

uses
  System.Classes,
  System.SysUtils,
  TestFramework,
  DFun.List,
  DFun.Maybe;

type
  // Test methods for class List

  ListTest = class(TTestCase)
  published
    procedure TestEmpty;
    procedure TestCons;
    procedure TestMap;
    procedure TestFilter;
    procedure TestFoldLeft;
    procedure TestFoldRight;
    procedure TestReverse;
    procedure TestSum;
    procedure TestProduct;
    procedure TestAll;
    procedure TestAny;
    procedure TestEach;
    procedure TestSortBy;
  end;

implementation

{ ListTest }

procedure ListTest.TestAll;
begin
  CheckTrue(List.All<Integer>(
    function(X: Integer): Boolean begin Result := X > 0 end,
    List.FromArray<Integer>([1, 2, 3, 4, 5])));
  CheckFalse(List.All<Integer>(
    function(X: Integer): Boolean begin Result := X <> 3 end,
    List.FromArray<Integer>([1, 2, 3, 4, 5])));
end;

procedure ListTest.TestAny;
begin
  CheckTrue(List.Any<Integer>(
    function(X: Integer): Boolean begin Result := X <> 3 end,
    List.FromArray<Integer>([1, 2, 3, 4, 5])));
  CheckFalse(List.Any<Integer>(
    function(X: Integer): Boolean begin Result := X < 0 end,
    List.FromArray<Integer>([1, 2, 3, 4, 5])));
end;

procedure ListTest.TestCons;
begin
  CheckEquals('[1, 2, 3]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Cons<Integer>(1,
          List.Cons<Integer>(2,
            List.Cons<Integer>(3,
              List.Empty<Integer>))))));
end;

procedure ListTest.TestEach;
var
  I: Integer;
begin
  I := 0;
  List.Each<Integer>(
    procedure(X: Integer) begin I := I + X end,
    List.FromArray<Integer>([1, 2, 3, 4, 5]));
  CheckEquals(15, I);
end;

procedure ListTest.TestEmpty;
begin
  CheckEquals('[]', List.ToString(List.Empty<String>));
end;

procedure ListTest.TestFilter;
begin
  CheckEquals('[2, 4]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Filter<Integer>(
          function(X: Integer): Boolean begin Result := X mod 2 = 0 end,
          List.FromArray<Integer>([1, 2, 3, 4, 5])))));
end;

procedure ListTest.TestFoldLeft;
begin
  CheckEquals('abcde',
    List.FoldLeft<String, String>(
      function(X: String; Acc: String): String begin
        Result := Acc + X;
      end,
      '',
      List.FromArray<String>(['a', 'b', 'c', 'd', 'e'])));
end;

procedure ListTest.TestFoldRight;
begin
  CheckEquals('edcba',
    List.FoldRight<String, String>(
      function(X: String; Acc: String): String begin
        Result := Acc + X;
      end,
      '',
      List.FromArray<String>(['a', 'b', 'c', 'd', 'e'])));
end;

procedure ListTest.TestMap;
begin
  CheckEquals('[3, 6, 9, 12, 15]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Map<Integer, Integer>(
          function(X: Integer): Integer begin Result := X * 3 end,
          List.FromArray<Integer>([1, 2, 3, 4, 5])))));
end;

procedure ListTest.TestProduct;
begin
  CheckEquals(120, List.Product(List.FromArray<Integer>([1, 2, 3, 4, 5])));
  CheckEquals(120, List.Product(List.FromArray<Extended>([1, 2, 3, 4, 5])));
end;

procedure ListTest.TestReverse;
begin
  CheckEquals('[5, 4, 3, 2, 1]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Reverse<Integer>(
          List.FromArray<Integer>([1, 2, 3, 4, 5])))));
end;

procedure ListTest.TestSortBy;
begin
  CheckEquals('[1, 2, 3, 4, 5]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.SortBy<Integer>(
          function(L, R: Integer): Integer begin Result := L - R end,
          List.FromArray<Integer>([3, 2, 4, 1, 5])))));
end;

procedure ListTest.TestSum;
begin
  CheckEquals(15, List.Sum(List.FromArray<Integer>([1, 2, 3, 4, 5])));
  CheckEquals(15, List.Sum(List.FromArray<Extended>([1, 2, 3, 4, 5])));
end;

initialization
  RegisterTest(ListTest.Suite);
end.

