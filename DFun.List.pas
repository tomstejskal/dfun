unit DFun.List;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  DFun.Maybe;

type
  IList<A> = interface
  ['{F2AD450F-F208-4026-B603-A95C9C69191D}']
  end;

  List = class
    class function Empty<A>: IList<A>;
    class function Cons<A>(const AHead: A; const ATail: IList<A>): IList<A>;
    class function Map<A, B>(const AFunc: TFunc<A, B>;
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
    class function Sum(const AList: IList<Extended>): Extended;
    class function Product(const AList: IList<Extended>): Extended;
    class function All<A>(const AFunc: TFunc<A, Boolean>;
      const AList: IList<A>): Boolean;
    class function Any<A>(const AFunc: TFunc<A, Boolean>;
      const AList: IList<A>): Boolean;
    class procedure Each<A>(const AProc: TProc<A>;
      const AList: IList<A>);
    class function FromArray<A>(const AList: array of A): IList<A>;
    class function ToTList<A>(const AList: IList<A>): TList<A>;
  end;

  EmptyVal<A> = class(TInterfacedObject, IList<A>)
  end;

  ConsVal<A> = class(TInterfacedObject, IList<A>)
  strict private
    fHead: A;
    fTail: IList<A>;
  public
    constructor Create(const AHead: A; const ATail: IList<A>);
    property Head: A read fHead;
    property Tail: IList<A> read fTail;
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

class function List.Any<A>(const AFunc: TFunc<A, Boolean>;
  const AList: IList<A>): Boolean;
begin
  Result := FoldLeft<A, Boolean>(
    function(X: A; Acc: Boolean): Boolean begin Result := Acc or AFunc(X) end,
    False,
    AList);
end;

class function List.Cons<A>(const AHead: A;
  const ATail: IList<A>): IList<A>;
begin
  Result := ConsVal<A>.Create(AHead, ATail);
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
  Result := EmptyVal<A>.Create;
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
begin
  if AList is EmptyVal<A> then begin
    Result := AInit;
  end else begin
    Result := FoldLeft(AFunc,
      AFunc((AList as ConsVal<A>).Head, AInit),
      (AList as ConsVal<A>).Tail);
  end;
end;

class function List.FoldRight<A, B>(const AFunc: TFunc<A, B, B>;
  const AInit: B; const AList: IList<A>): B;
begin
  if AList is EmptyVal<A> then begin
    Result := AInit;
  end else begin
    Result := AFunc((AList as ConsVal<A>).Head,
      FoldRight(AFunc, AInit, (AList as ConsVal<A>).Tail));
  end;
end;

class function List.FromArray<A>(const AList: array of A): IList<A>;
var
  I: Integer;
begin
  Result := Empty<A>;
  for I := Length(AList) - 1 downto 0 do begin
    Result := Cons<A>(AList[I], Result);
  end;
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

{ ConsVal<A> }

constructor ConsVal<A>.Create(const AHead: A; const ATail: IList<A>);
begin
  inherited Create;
  fHead := AHead;
  fTail := ATail;
end;

end.
