unit DFun.Maybe;

interface

uses
  System.Classes,
  System.SysUtils,
  DFun.Null;

type
  IMaybe<A> = interface
  ['{DD482B38-350F-4AA9-9B3E-7A731752C123}']
  end;

  INothingVal<A> = interface(IMaybe<A>)
  ['{D7EDD0CC-5217-4FDA-AD4F-CB2BEF8E2AE3}']
  end;

  IJustVal<A> = interface(IMaybe<A>)
  ['{4B9C00B2-8112-45C1-9872-ECF0E2030134}']
    function GetValue: A;
    property Value: A read GetValue;
  end;

  Maybe = class
    class function Nothing<A>: IMaybe<A>;
    class function Just<A>(const AValue: A): IMaybe<A>;
    class function Match<A, B>(const AWhenNothing: TFunc<B>;
      const AWhenJust: TFunc<A, B>;
      const AValue: IMaybe<A>): B; overload;
    class procedure Match<A>(const AWhenNothing: TProc;
      const AWhenJust: TProc<A>;
      const AValue: IMaybe<A>); overload;
    class function WhenNothing<A, B>(const AFunc: TFunc<B>;
      const AElse: B;
      const AValue: IMaybe<A>): B; overload;
    class procedure WhenNothing<A>(const AProc: TProc;
      const AValue: IMaybe<A>); overload;
    class function WhenJust<A, B>(const AFunc: TFunc<A, B>;
      const AElse: B;
      const AValue: IMaybe<A>): B; overload;
    class procedure WhenJust<A>(const AProc: TProc<A>;
      const AValue: IMaybe<A>); overload;
    class function Map<A, B>(const AFunc: TFunc<A, B>;
      const AValue: IMaybe<A>): IMaybe<B>;
    class function AndThen<A, B>(const AFunc: TFunc<A, IMaybe<B>>;
      const AValue: IMaybe<A>): IMaybe<B>;
  end;

  NothingVal<A> = class(TInterfacedObject, IMaybe<A>, INothingVal<A>)
  end;

  JustVal<A> = class(TInterfacedObject, IMaybe<A>, IJustVal<A>)
  strict private
    fValue: A;
  public
    constructor Create(const AValue: A);
    function GetValue: A;
    property Value: A read GetValue;
  end;

implementation

{ Maybe }

class function Maybe.AndThen<A, B>(const AFunc: TFunc<A, IMaybe<B>>;
  const AValue: IMaybe<A>): IMaybe<B>;
var
  X: IJustVal<A>;
begin
  if Supports(AValue, IJustVal<A>, X) then begin
    Result := AFunc(X.Value);
  end else begin
    Result := Nothing<B>;
  end;
end;

class function Maybe.Just<A>(const AValue: A): IMaybe<A>;
begin
  Result := JustVal<A>.Create(AValue);
end;

class function Maybe.Map<A, B>(const AFunc: TFunc<A, B>;
  const AValue: IMaybe<A>): IMaybe<B>;
var
  X: IJustVal<A>;
begin
  if Supports(AValue, IJustVal<A>, X) then begin
    Result := Just<B>(AFunc(X.Value));
  end else begin
    Result := Nothing<B>;
  end;
end;

class procedure Maybe.Match<A>(const AWhenNothing: TProc;
  const AWhenJust: TProc<A>; const AValue: IMaybe<A>);
begin
  Match<A, INull>(
    function: INull begin AWhenNothing; Result := Null.Value; end,
    function(X: A): INull begin AWhenJust(X); Result := Null.Value; end,
    AValue);
end;

class function Maybe.Match<A, B>(const AWhenNothing: TFunc<B>;
  const AWhenJust: TFunc<A, B>; const AValue: IMaybe<A>): B;
var
  X: IJustVal<A>;
begin
  if Supports(AValue, IJustVal<A>, X) then begin
    Result := AWhenJust(X.Value);
  end else begin
    Result := AWhenNothing;
  end;
end;

class function Maybe.Nothing<A>: IMaybe<A>;
begin
  Result := NothingVal<A>.Create;
end;

class function Maybe.WhenJust<A, B>(const AFunc: TFunc<A, B>;
  const AElse: B; const AValue: IMaybe<A>): B;
begin
  Result := Match<A, B>(
    function: B begin Result := AElse end,
    function(X: A): B begin Result := AFunc(X) end,
    AValue);
end;

class procedure Maybe.WhenJust<A>(const AProc: TProc<A>;
  const AValue: IMaybe<A>);
begin
  WhenJust<A, INull>(
    function(X: A): INull begin AProc(X); Result := Null.Value; end,
    Null.Value,
    AValue);
end;

class function Maybe.WhenNothing<A, B>(const AFunc: TFunc<B>;
  const AElse: B; const AValue: IMaybe<A>): B;
begin
  Result := Match<A, B>(
    AFunc,
    function(X: A): B begin Result := AElse end,
    AValue);
end;

class procedure Maybe.WhenNothing<A>(const AProc: TProc;
  const AValue: IMaybe<A>);
begin
  WhenNothing<A, INull>(
    function: INull begin AProc; Result := Null.Value; end,
    Null.Value,
    AValue);
end;

{ JustVal<A> }

constructor JustVal<A>.Create(const AValue: A);
begin
  inherited Create;
  fValue := AValue;
end;

function JustVal<A>.GetValue: A;
begin
  Result := fValue;
end;

end.
