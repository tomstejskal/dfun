unit DFun.List;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  DFun.Maybe,
  DFun.Pair;

type
  IList<A> = interface
  ['{F2AD450F-F208-4026-B603-A95C9C69191D}']
  end;

  IEmptyCell<A> = interface(IList<A>)
  ['{F382F9DC-3615-4FFA-BC44-4A055FC8A78B}']
  end;

  IConsCell<A> = interface(IList<A>)
  ['{C9CA2B0E-AFAF-4597-A139-57CA5EAAA9C6}']
    function GetHead: A;
    function GetTail: IList<A>;
    property Head: A read GetHead;
    property Tail: IList<A> read GetTail;
  end;

  List = class
    class function Empty<A>: IList<A>;
    class function Cons<A>(const AHead: A; const ATail: IList<A>): IList<A>;
    class function IsEmpty<A>(const AList: IList<A>): Boolean;
    class function Singleton<A>(const AValue: A): IList<A>;
    class function Generate<A>(const AFunc: TFunc<A>;
      const ACount: Integer): IList<A>;
    class function ToString(const AList: IList<String>): String; reintroduce;
    class function ToStringWith<A>(const AFunc: TFunc<A, String>;
      const AList: IList<A>): String;
    class function FromArray<A>(const AList: array of A): IList<A>;
    class function FromEnumerable<A>(const AList: IEnumerable<A>): IList<A>;
    class function FromTEnumerable<A>(const AList: TEnumerable<A>): IList<A>;
    class function FromTList<A>(const AList: TList<A>): IList<A>;
    class function ToTList<A>(const AList: IList<A>): TList<A>;
    class function Head<A>(const AList: IList<A>): IMaybe<A>;
    class function Tail<A>(const AList: IList<A>): IMaybe<IList<A>>;
    class function Append<A>(const ALeft, ARight: IList<A>): IList<A>;
    class function Join<A>(const ALists: IList<IList<A>>): IList<A>;
    class function Map<A, B>(const AFunc: TFunc<A, B>;
      const AList: IList<A>): IList<B>;
    class function AndThen<A, B>(const AFunc: TFunc<A, IList<B>>;
      const AList: IList<A>): IList<B>;
    class function Filter<A>(const AFunc: TFunc<A, Boolean>;
      const AList: IList<A>): IList<A>;
    class function FoldLeft<A, B>(const AFunc: TFunc<A, B, B>;
      const AInit: B;
      const AList: IList<A>): B;
    class function FoldRight<A, B>(const AFunc: TFunc<A, B, B>;
      const AInit: B;
      const AList: IList<A>): B;
    class function Reverse<A>(const AList: IList<A>): IList<A>;
    class function Sum(const AList: IList<Integer>): Integer; overload;
    class function Sum(const AList: IList<Extended>): Extended; overload;
    class function Product(const AList: IList<Integer>): Integer; overload;
    class function Product(const AList: IList<Extended>): Extended; overload;
    class function All<A>(const AFunc: TFunc<A, Boolean>;
      const AList: IList<A>): Boolean;
    class function Any<A>(const AFunc: TFunc<A, Boolean>;
      const AList: IList<A>): Boolean;
    class procedure Each<A>(const AProc: TProc<A>;
      const AList: IList<A>);
    class function SortBy<A>(const AFunc: TFunc<A, A, Integer>;
      const AList: IList<A>): IList<A>;
    class function GroupBy<A>(const AFunc: TFunc<A, A, Integer>;
      const AList: IList<A>): IList<IList<A>>;
    class function SortAndGroupBy<A>(const AFunc: TFunc<A, A, Integer>;
      const AList: IList<A>): IList<IList<A>>;
    class function Length<A>(const AList: IList<A>): Integer;
  end;

  EmptyCell<A> = class(TInterfacedObject, IList<A>, IEmptyCell<A>)
  end;

  ConsCell<A> = class(TInterfacedObject, IList<A>, IConsCell<A>)
  strict private
    fHead: A;
    fTail: IList<A>;
  public
    constructor Create(const AHead: A; const ATail: IList<A>);
    destructor Destroy; override;
    function GetHead: A;
    function GetTail: IList<A>;
    property Head: A read GetHead;
    property Tail: IList<A> read GetTail;
  end;

  TFunComparer<A> = class(TInterfacedObject, IComparer<A>)
  private
    fFunc: TFunc<A, A, Integer>;
  public
    constructor Create(const AFunc: TFunc<A, A, Integer>);
    function Compare(const Left, Right: A): Integer;
  end;

implementation

{ List }

class function List.All<A>(const AFunc: TFunc<A, Boolean>;
  const AList: IList<A>): Boolean;
begin
  Result := FoldLeft<A, Boolean>(
    function(X: A; Acc: Boolean): Boolean begin Result := Acc and AFunc(X) end,
    True,
    AList);
end;

class function List.AndThen<A, B>(const AFunc: TFunc<A, IList<B>>;
  const AList: IList<A>): IList<B>;
begin
  Result := List.Join<B>(List.Map<A, IList<B>>(AFunc, AList));
end;

class function List.Any<A>(const AFunc: TFunc<A, Boolean>;
  const AList: IList<A>): Boolean;
begin
  Result := FoldLeft<A, Boolean>(
    function(X: A; Acc: Boolean): Boolean begin Result := Acc or AFunc(X) end,
    False,
    AList);
end;

class function List.Append<A>(const ALeft, ARight: IList<A>): IList<A>;
begin
  if IsEmpty<A>(ALeft) then begin
    Result := ARight;
  end else if IsEmpty<A>(ARight) then begin
    Result := ALeft;
  end else begin
    Result := FoldRight<A, IList<A>>(
      function(X: A; Acc: IList<A>): IList<A> begin
        Result := Cons<A>(X, Acc);
      end,
      ARight,
      ALeft);
  end;
end;

class function List.Tail<A>(const AList: IList<A>): IMaybe<IList<A>>;
var
  Cc: IConsCell<A>;
begin
  if Supports(AList, IConsCell<A>, Cc) then begin
    Result := Maybe.Just<IList<A>>(Cc.Tail);
  end else begin
    Result := Maybe.Nothing<IList<A>>;
  end;
end;

class function List.ToString(const AList: IList<String>): String;
begin
  Result := ToStringWith<String>(
    function(X: String): String begin Result := X end,
    AList);
end;

class function List.ToStringWith<A>(const AFunc: TFunc<A, String>;
  const AList: IList<A>): String;
var
  Sb: TStringBuilder;
  First: Boolean;
begin
  First := True;
  Sb := TStringBuilder.Create;
  try
    Sb.Append('[');
    Each<A>(
      procedure(X: A) begin
        if First then begin
          First := False;
        end else begin
          Sb.Append(', ');
        end;
        Sb.Append(AFunc(X));
      end,
      AList);
    Sb.Append(']');
    Result := Sb.ToString;
  finally
    Sb.Free;
  end;
end;

class function List.Cons<A>(const AHead: A;
  const ATail: IList<A>): IList<A>;
begin
  Result := ConsCell<A>.Create(AHead, ATail);
end;

class procedure List.Each<A>(const AProc: TProc<A>; const AList: IList<A>);
begin
  FoldLeft<A, Integer>(
    function(X: A; Acc: Integer): Integer begin AProc(X); Result := 0; end,
    0,
    AList);
end;

class function List.Empty<A>: IList<A>;
begin
  Result := EmptyCell<A>.Create;
end;

class function List.Filter<A>(const AFunc: TFunc<A, Boolean>;
  const AList: IList<A>): IList<A>;
begin
  Result := FoldRight<A, IList<A>>(
    function(X: A; Acc: IList<A>): IList<A> begin
      if AFunc(X) then begin
        Result := Cons<A>(X, Acc);
      end else begin
        Result := Acc;
      end;
    end,
    Empty<A>,
    AList);
end;

class function List.FoldLeft<A, B>(const AFunc: TFunc<A, B, B>;
  const AInit: B; const AList: IList<A>): B;
var
  Xs: IList<A>;
  Cc: IConsCell<A>;
begin
  Xs := AList;
  Result := AInit;
  while Supports(Xs, IConsCell<A>, Cc) do begin
    Result := AFunc(Cc.Head, Result);
    Xs := Cc.Tail;
  end;
end;

class function List.FoldRight<A, B>(const AFunc: TFunc<A, B, B>;
  const AInit: B; const AList: IList<A>): B;
begin
  Result := FoldLeft<A, B>(AFunc, AInit, Reverse<A>(AList));
end;

class function List.FromArray<A>(const AList: array of A): IList<A>;
var
  I: Integer;
begin
  Result := Empty<A>;
  for I := System.Length(AList) - 1 downto 0 do begin
    Result := Cons<A>(AList[I], Result);
  end;
end;

class function List.FromEnumerable<A>(
  const AList: IEnumerable<A>): IList<A>;
var
  X: A;
begin
  Result := Empty<A>;
  for X in AList do begin
    Result := Cons<A>(X, Result);
  end;
  Result := Reverse<A>(Result);
end;

class function List.FromTEnumerable<A>(
  const AList: TEnumerable<A>): IList<A>;
var
  X: A;
begin
  Result := Empty<A>;
  for X in AList do begin
    Result := Cons<A>(X, Result);
  end;
  Result := Reverse<A>(Result);
end;

class function List.FromTList<A>(const AList: TList<A>): IList<A>;
var
  I: Integer;
begin
  Result := Empty<A>;
  for I := AList.Count - 1 downto 0 do begin
    Result := Cons<A>(AList[I], Result);
  end;
end;

class function List.Generate<A>(const AFunc: TFunc<A>;
  const ACount: Integer): IList<A>;
var
  I: Integer;
begin
  Result := Empty<A>;
  for I := 0 to ACount - 1 do begin
    Result := Cons<A>(AFunc, Result);
  end;
  Result := Reverse<A>(Result);
end;

class function List.GroupBy<A>(const AFunc: TFunc<A, A, Integer>;
  const AList: IList<A>): IList<IList<A>>;
var
  Acc: IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>>;
begin
  Acc :=
    FoldLeft<A, IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>>>(
      function(X: A; Acc: IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>>): IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>> begin
        Result := Maybe.Match<IPair<A, IList<A>>, IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>>>(
          function: IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>> begin
            Result := Pair.Create(
              Maybe.Just(
                Pair.Create(
                  X,
                  List.Singleton(X))),
              List.Empty<IList<A>>);
          end,
          function(Y: IPair<A, IList<A>>): IPair<IMaybe<IPair<A, IList<A>>>, IList<IList<A>>> begin
            if AFunc(X, Y.First) = 0 then begin
              Result := Pair.Create(
                Maybe.Just(
                  Pair.Create(
                    Y.First,
                    List.Cons<A>(X, Y.Second))),
                Acc.Second);
            end else begin
              Result := Pair.Create(
                Maybe.Just(
                  Pair.Create(
                    X,
                    List.Singleton(X))),
                List.Cons<IList<A>>(Y.Second, Acc.Second));
            end;
          end,
          Acc.First);
      end,
      Pair.Create(Maybe.Nothing<IPair<A, IList<A>>>, List.Empty<IList<A>>),
      AList);
  Result :=
    List.Reverse<IList<A>>(
      Maybe.Match<IPair<A, IList<A>>, IList<IList<A>>>(
        function: IList<IList<A>> begin
          Result := Acc.Second;
        end,
        function(X: IPair<A, IList<A>>): IList<IList<A>> begin
          Result := List.Cons<IList<A>>(X.Second, Acc.Second);
        end,
        Acc.First));
end;

class function List.Head<A>(const AList: IList<A>): IMaybe<A>;
var
  Cc: IConsCell<A>;
begin
  if Supports(AList, IConsCell<A>, Cc) then begin
    Result := Maybe.Just<A>(Cc.Head);
  end else begin
    Result := Maybe.Nothing<A>;
  end;
end;

class function List.IsEmpty<A>(const AList: IList<A>): Boolean;
begin
  Result := Supports(AList, IEmptyCell<A>);
end;

class function List.Join<A>(const ALists: IList<IList<A>>): IList<A>;
begin
  Result := List.FoldLeft<IList<A>, IList<A>>(
    function(X: IList<A>; Acc: IList<A>): IList<A> begin
      Result := List.Append<A>(Acc, X);
    end,
    List.Empty<A>,
    ALists);
end;

class function List.Length<A>(const AList: IList<A>): Integer;
begin
  Result := FoldLeft<A, Integer>(
    function(X: A; Acc: Integer): Integer begin Result := Acc + 1 end,
    0,
    AList);
end;

class function List.Map<A, B>(const AFunc: TFunc<A, B>;
  const AList: IList<A>): IList<B>;
begin
  Result := FoldRight<A, IList<B>>(
    function(X: A; Acc: IList<B>): IList<B> begin
      Result := Cons<B>(AFunc(X), Acc);
    end,
    Empty<B>,
    AList);
end;

class function List.Product(const AList: IList<Integer>): Integer;
begin
  Result := FoldLeft<Integer, Integer>(
    function (A, B: Integer): Integer begin Result := A * B end,
    1,
    AList);
end;

class function List.Product(const AList: IList<Extended>): Extended;
begin
  Result := FoldLeft<Extended, Extended>(
    function (A, B: Extended): Extended begin Result := A * B end,
    1.0,
    AList);
end;

class function List.Reverse<A>(const AList: IList<A>): IList<A>;
begin
  Result := FoldLeft<A, IList<A>>(
    function(X: A; Acc: IList<A>): IList<A> begin
      Result := Cons<A>(X, Acc);
    end,
    Empty<A>,
    AList);
end;

class function List.Sum(const AList: IList<Integer>): Integer;
begin
  Result := FoldLeft<Integer, Integer>(
    function (A, B: Integer): Integer begin Result := A + B end,
    0,
    AList);
end;

class function List.Singleton<A>(const AValue: A): IList<A>;
begin
  Result := Cons<A>(AValue, Empty<A>);
end;

class function List.SortAndGroupBy<A>(const AFunc: TFunc<A, A, Integer>;
  const AList: IList<A>): IList<IList<A>>;
begin
  Result := GroupBy<A>(AFunc, SortBy<A>(AFunc, AList));
end;

class function List.SortBy<A>(const AFunc: TFunc<A, A, Integer>;
  const AList: IList<A>): IList<A>;
var
  Xs: TList<A>;
begin
  Xs := List.ToTList<A>(AList);
  try
    Xs.Sort(TFunComparer<A>.Create(AFunc));
    Result := List.FromTList<A>(Xs);
  finally
    Xs.Free;
  end;
end;

class function List.Sum(const AList: IList<Extended>): Extended;
begin
  Result := FoldLeft<Extended, Extended>(
    function (A, B: Extended): Extended begin Result := A + B end,
    0.0,
    AList);
end;

class function List.ToTList<A>(const AList: IList<A>): TList<A>;
begin
  Result := FoldLeft<A, TList<A>>(
    function(X: A; Acc: TList<A>): TList<A> begin
      Acc.Add(X);
      Result := Acc;
    end,
    TList<A>.Create,
    AList);
end;

{ ConsCell<A> }

constructor ConsCell<A>.Create(const AHead: A; const ATail: IList<A>);
begin
  inherited Create;
  fHead := AHead;
  fTail := ATail;
end;

destructor ConsCell<A>.Destroy;
var
  Xs: IList<A>;
  Ys: IList<A>;
begin
  Xs := Tail;
  while Xs is ConsCell<A> do begin
    Ys := ConsCell<A>(Xs).Tail;
    ConsCell<A>(Xs).fTail := nil;
    Xs := Ys;
    Ys := nil;
  end;
  inherited;
end;

function ConsCell<A>.GetHead: A;
begin
  Result := fHead;
end;

function ConsCell<A>.GetTail: IList<A>;
begin
  Result := fTail;
end;

{ TFunComparer<A> }

function TFunComparer<A>.Compare(const Left, Right: A): Integer;
begin
  Result := fFunc(Left, Right);
end;

constructor TFunComparer<A>.Create(const AFunc: TFunc<A, A, Integer>);
begin
  inherited Create;
  fFunc := AFunc;
end;

end.
