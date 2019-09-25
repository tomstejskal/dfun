unit DFun.Maybe;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IMaybe<A> = interface
  ['{DD482B38-350F-4AA9-9B3E-7A731752C123}']
  end;

  Maybe = class
    class function Nothing<A>: IMaybe<A>;
    class function Just<A>(const AValue: A): IMaybe<A>;
    class function Match<A, B>(const AWhenNothing: TFunc<B>;
      const AWhenJust: TFunc<A, B>;
      const AValue: IMaybe<A>): B;
    class function Map<A, B>(const AFunc: TFunc<A, B>;
      const AValue: IMaybe<A>): IMaybe<B>;
    class function AndMap<A, B>(const AFunc: IMaybe<TFunc<A, B>>;
      const AValue: IMaybe<A>): IMaybe<B>;
    class function AndThen<A, B>(const AFunc: TFunc<A, IMaybe<B>>;
      const AValue: IMaybe<A>): IMaybe<B>;
  end;

  NothingVal<A> = class(TInterfacedObject, IMaybe<A>)
  end;

  JustVal<A> = class(TInterfacedObject, IMaybe<A>)
  strict private
    fValue: A;
  public
    constructor Create(const AValue: A);
    property Value: A read fValue;
  end;

implementation

{ Maybe }

class function Maybe.AndMap<A, B>(const AFunc: IMaybe<TFunc<A, B>>;
  const AValue: IMaybe<A>): IMaybe<B>;
begin
  if (AFunc is JustVal<TFunc<A, B>>) and (AValue is JustVal<A>) then begin
    Result := Just<B>((AFunc as JustVal<TFunc<A, B>>).Value((AValue as JustVal<A>).Value));
  end else begin
    Result := Nothing<B>;
  end;
end;

class function Maybe.AndThen<A, B>(const AFunc: TFunc<A, IMaybe<B>>;
  const AValue: IMaybe<A>): IMaybe<B>;
begin
  if AValue is JustVal<A> then begin
    Result := AFunc((AValue as JustVal<A>).Value);
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
begin
  if AValue is JustVal<A> then begin
    Result := Just<B>(AFunc((AValue as JustVal<A>).Value));
  end else begin
    Result := Nothing<B>;
  end;
end;

class function Maybe.Match<A, B>(const AWhenNothing: TFunc<B>;
  const AWhenJust: TFunc<A, B>; const AValue: IMaybe<A>): B;
begin
  if AValue is JustVal<A> then begin
    Result := AWhenJust((AValue as JustVal<A>).Value);
  end else begin
    Result := AWhenNothing;
  end;
end;

class function Maybe.Nothing<A>: IMaybe<A>;
begin
  Result := NothingVal<A>.Create;
end;

{ JustVal<A> }

constructor JustVal<A>.Create(const AValue: A);
begin
  inherited Create;
  fValue := AValue;
end;

end.
