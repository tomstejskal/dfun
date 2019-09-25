unit DFun.Either;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IEither<A, B> = interface
  ['{4CBE3C0C-1517-4001-A388-FCDC46E1235F}']
  end;

  Either = class
    class function Left<A, B>(const AValue: A): IEither<A, B>;
    class function Right<A, B>(const AValue: B): IEither<A, B>;
    class function Match<A, B, C>(const AWhenLeft: TFunc<A, C>;
      const AWhenRight: TFunc<B, C>;
      const AValue: IEither<A, B>): C;
    class function Map<A, B, C>(const AFunc: TFunc<B, C>;
      const AValue: IEither<A, B>): IEither<A, C>;
    class function AndMap<A, B, C>(const AFunc: IEither<A, TFunc<B, C>>;
      const AValue: IEither<A, B>): IEither<A, C>;
    class function AndThen<A, B, C>(const AFunc: TFunc<B, IEither<A, C>>;
      const AValue: IEither<A, B>): IEither<A, C>;
  end;

  LeftVal<A, B> = class(TInterfacedObject, IEither<A, B>)
  strict private
    fValue: A;
  public
    constructor Create(const AValue: A);
    property Value: A read fValue;
  end;

  RightVal<A, B> = class(TInterfacedObject, IEither<A, B>)
  strict private
    fValue: B;
  public
    constructor Create(const AValue: B);
    property Value: B read fValue;
  end;

implementation

{ Either }

class function Either.AndMap<A, B, C>(const AFunc: IEither<A, TFunc<B, C>>;
  const AValue: IEither<A, B>): IEither<A, C>;
begin
  if AFunc is LeftVal<A, TFunc<B, C>> then begin
    Result := Left<A, C>((AFunc as LeftVal<A, TFunc<B, C>>).Value);
  end else if AValue is LeftVal<A, B> then begin
    Result := Left<A, C>((AValue as LeftVal<A, B>).Value);
  end else begin
    Result := Right<A, C>((AFunc as RightVal<A, TFunc<B, C>>).Value((AValue as RightVal<A, B>).Value));
  end;
end;

class function Either.AndThen<A, B, C>(const AFunc: TFunc<B, IEither<A, C>>;
  const AValue: IEither<A, B>): IEither<A, C>;
begin
  if AValue is LeftVal<A, B> then begin
    Result := Left<A, C>((AValue as LeftVal<A, B>).Value);
  end else begin
    Result := AFunc((AValue as RightVal<A, B>).Value);
  end;
end;

class function Either.Left<A, B>(const AValue: A): IEither<A, B>;
begin
  Result := LeftVal<A, B>.Create(AValue);
end;

class function Either.Map<A, B, C>(const AFunc: TFunc<B, C>;
  const AValue: IEither<A, B>): IEither<A, C>;
begin
  if AValue is LeftVal<A, B> then begin
    Result := Left<A, C>((AValue as LeftVal<A, B>).Value);
  end else begin
    Result := Right<A, C>(AFunc((AValue as RightVal<A, B>).Value));
  end;
end;

class function Either.Match<A, B, C>(const AWhenLeft: TFunc<A, C>;
  const AWhenRight: TFunc<B, C>; const AValue: IEither<A, B>): C;
begin
  if AValue is LeftVal<A, B> then begin
    Result := AWhenLeft((AValue as LeftVal<A, B>).Value);
  end else begin
    Result := AWhenRight((AValue as RightVal<A, B>).Value);
  end;
end;

class function Either.Right<A, B>(const AValue: B): IEither<A, B>;
begin
  Result := RightVal<A, B>.Create(AValue);
end;

{ LeftVal<A, B> }

constructor LeftVal<A, B>.Create(const AValue: A);
begin
  inherited Create;
  fValue := AValue;
end;

{ RightVal<A, B> }

constructor RightVal<A, B>.Create(const AValue: B);
begin
  inherited Create;
  fValue := AValue;
end;

end.
