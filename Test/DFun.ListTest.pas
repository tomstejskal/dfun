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
    procedure TestIsEmpty;
    procedure TestSingleton;
    procedure TestGenerate;
    procedure TestAppend;
    procedure TestJoin;
    procedure TestMap;
    procedure TestAndThen;
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
    procedure TestGroupBy;
    procedure TestLength;
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

procedure ListTest.TestAndThen;
begin
  CheckEquals('[1, 2, 3, 2, 4, 6, 3, 6, 9]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.AndThen<Integer, Integer>(
          function(X: Integer): IList<Integer> begin
            Result := List.FromArray<Integer>([X, X * 2, X * 3])
          end,
          List.FromArray<Integer>([1, 2, 3])))));
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

procedure ListTest.TestAppend;
begin
  CheckEquals('[1, 2, 3, 4, 5]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Append<Integer>(
          List.FromArray<Integer>([1, 2]),
          List.FromArray<Integer>([3, 4, 5])))));
  CheckEquals('[1, 2]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Append<Integer>(
          List.FromArray<Integer>([1, 2]),
          List.Empty<Integer>))));
  CheckEquals('[3, 4, 5]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Append<Integer>(
          List.Empty<Integer>,
          List.FromArray<Integer>([3, 4, 5])))));
  CheckEquals('[]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Append<Integer>(
          List.Empty<Integer>,
          List.Empty<Integer>))));
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

procedure ListTest.TestGenerate;
begin
  CheckEquals(1000000,
    List.Length<Integer>(
      List.Generate<Integer>(
        function: Integer begin Result := Random(1000) end,
        1000000)));
end;

procedure ListTest.TestGroupBy;
begin
  CheckEquals('[[1, 1], [2, 2, 2], [3], [4, 4], [5]]',
    List.ToString(
      List.Map<IList<Integer>, String>(
        function(X: IList<Integer>): String begin
          Result := List.ToString(List.Map<Integer, String>(IntToStr, X));
        end,
        List.GroupBy<Integer>(
          function(X, Y: Integer): Integer begin Result := X - Y end,
          List.FromArray<Integer>([1, 1, 2, 2, 2, 3, 4, 4, 5])))));
  CheckEquals(1000,
    List.Length<IList<Integer>>(
      List.GroupBy<Integer>(
        function(X, Y: Integer): Integer begin Result := X - Y end,
        List.SortBy<Integer>(
          function(X, Y: Integer): Integer begin Result := X - y end,
          List.Generate<Integer>(
            function: Integer begin Result := Random(1000) end,
            1000000)))));
end;

procedure ListTest.TestIsEmpty;
begin
  CheckTrue(List.IsEmpty<Integer>(List.Empty<Integer>));
  CheckFalse(List.IsEmpty<Integer>(List.Singleton<Integer>(1)));
  CheckFalse(List.IsEmpty<Integer>(List.Cons<Integer>(1, List.Empty<Integer>)));
  CheckFalse(List.IsEmpty<Integer>(List.FromArray<Integer>([1, 2, 3, 4, 5])));
end;

procedure ListTest.TestJoin;
begin
  CheckEquals('[1, 2, 3, 4, 5, 6, 7]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Join<Integer>(
          List.FromArray<IList<Integer>>(
            [ List.FromArray<Integer>([1, 2])
            , List.FromArray<Integer>([3, 4, 5])
            , List.FromArray<Integer>([6, 7])
            ])))));
  CheckEquals('[]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Join<Integer>(
          List.Empty<IList<Integer>>))));
end;

procedure ListTest.TestLength;
begin
  CheckEquals(0, List.Length<Integer>(List.Empty<Integer>));
  CheckEquals(1, List.Length<Integer>(List.Singleton<Integer>(1)));
  CheckEquals(5, List.Length<Integer>(List.FromArray<Integer>([1, 2, 3, 4, 5])));
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

procedure ListTest.TestSingleton;
begin
  CheckEquals('[1]',
    List.ToString(
      List.Map<Integer, String>(IntToStr,
        List.Singleton<Integer>(1))));
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

