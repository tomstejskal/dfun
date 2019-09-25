unit DFun.Either;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IEither<A, B> = interface
  ['{4CBE3C0C-1517-4001-A388-FCDC46E1235F}']
  end;

  ILeftVal<A, B> = interface(IEither<A, B>)
  ['{A74BA450-5CAC-40CD-BFFD-F660F6F9487E}']
    function GetValue: A;
    property Value: A read GetValue;
  end;

  IRightVal<A, B> = interface(IEither<A, B>)
  ['{C96B8F5F-6F74-4B4C-A37B-AC29B354437B}']
    function GetValue: B;
    property Value: B read GetValue;
  end;

  Either = class
    class function Left<A, B>(const AValue: A): IEither<A, B>;
    class function Right<A, B>(const AValue: B): IEither<A, B>;
    class function Match<A, B, C>(const AWhenLeft: TFunc<A, C>;
      const AWhenRight: TFunc<B, C>;
      const AValue: IEither<A, B>): C;
    class function Map<A, B, C>(const AFunc: TFunc<B, C>;
      const AValue: IEither<A, B>): IEither<A, C>;
    class function AndThen<A, B, C>(const AFunc: TFunc<B, IEither<A, C>>;
      const AValue: IEither<A, B>): IEither<A, C>;
  end;

  LeftVal<A, B> = class(TInterfacedObject, IEither<A, B>, ILeftVal<A, B>)
  strict private
    fValue: A;
  public
    constructor Create(const AValue: A);
    function GetValue: A;
    property Value: A read GetValue;
  end;

  RightVal<A, B> = class(TInterfacedObject, IEither<A, B>, IRightVal<A, B>)
  strict private
    fValue: B;
  public
    constructor Create(const AValue: B);
    function GetValue: B;
    property Value: B read GetValue;
  end;

implementation

{ Either }

class function Either.AndThen<A, B, C>(const AFunc: TFunc<B, IEither<A, C>>;
  const AValue: IEither<A, B>): IEither<A, C>;
var
  L: ILeftVal<A, B>;
begin
  if Supports(AValue, ILeftVal<A, B>, L) then begin
    Result := Left<A, C>(L.Value);
  end else begin
    Result := AFunc((AValue as IRightVal<A, B>).Value);
  end;
end;

class function Either.Left<A, B>(const AValue: A): IEither<A, B>;
begin
  Result := LeftVal<A, B>.Create(AValue);
end;

class function Either.Map<A, B, C>(const AFunc: TFunc<B, C>;
  const AValue: IEither<A, B>): IEither<A, C>;
var
  L: ILeftVal<A, B>;
begin
  if Supports(AValue, ILeftVal<A, B>, L) then begin
    Result := Left<A, C>(L.Value);
  end else begin
    Result := Right<A, C>(AFunc((AValue as IRightVal<A, B>).Value));
  end;
end;

class function Either.Match<A, B, C>(const AWhenLeft: TFunc<A, C>;
  const AWhenRight: TFunc<B, C>; const AValue: IEither<A, B>): C;
var
  L: ILeftVal<A, B>;
begin
  if Supports(AValue, ILeftVal<A, B>, L) then begin
    Result := AWhenLeft(L.Value);
  end else begin
    Result := AWhenRight((AValue as IRightVal<A, B>).Value);
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

function LeftVal<A, B>.GetValue: A;
begin
  Result := fValue;
end;

{ RightVal<A, B> }

constructor RightVal<A, B>.Create(const AValue: B);
begin
  inherited Create;
  fValue := AValue;
end;

function RightVal<A, B>.GetValue: B;
begin
  Result := fValue;
end;

end.
