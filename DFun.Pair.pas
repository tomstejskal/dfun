unit DFun.Pair;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IPair<A, B> = interface
  ['{9E1D001F-4BBE-49FB-93B5-A7722BF807AB}']
    function GetFirst: A;
    function GetSecond: B;
    property First: A read GetFirst;
    property Second: B read GetSecond;
  end;

  Pair = class
    class function Create<A, B>(const AFirst: A; const ASecond: B): IPair<A, B>;
    class function MapFirst<A, B, C>(const AFunc: TFunc<A, C>;
      const APair: IPair<A, B>): IPair<C, B>;
    class function MapSecond<A, B, C>(const AFunc: TFunc<B, C>;
      const APair: IPair<A, B>): IPair<A, C>;
    class function Map<A, B, C>(const AFunc: TFunc<B, C>;
      const APair: IPair<A, B>): IPair<A, C>;
    class function MapBoth<A, B, C, D>(const AFirst: TFunc<A, C>;
      const ASecond: TFunc<B, D>;
      const APair: IPair<A, B>): IPair<C, D>;
    class function AndThen<A, B, C>(const AFunc: TFunc<B, IPair<A, C>>;
      const APair: IPair<A, B>): IPair<A, C>;
  end;

  TPair<A, B> = class(TInterfacedObject, IPair<A, B>)
  strict private
    fFirst: A;
    fSecond: B;
  public
    constructor Create(const AFirst: A; const ASecond: B);
    function GetFirst: A;
    function GetSecond: B;
    property First: A read GetFirst;
    property Second: B read GetSecond;
  end;

implementation

{ TPair<A, B> }

constructor TPair<A, B>.Create(const AFirst: A; const ASecond: B);
begin
  inherited Create;
  fFirst := AFirst;
  fSecond := ASecond;
end;

function TPair<A, B>.GetFirst: A;
begin
  Result := fFirst;
end;

function TPair<A, B>.GetSecond: B;
begin
  Result := fSecond;
end;

{ Pair }

class function Pair.AndThen<A, B, C>(const AFunc: TFunc<B, IPair<A, C>>;
  const APair: IPair<A, B>): IPair<A, C>;
begin
  Result := AFunc(APair.Second);
end;

class function Pair.Create<A, B>(const AFirst: A;
  const ASecond: B): IPair<A, B>;
begin
  Result := TPair<A, B>.Create(AFirst, ASecond);
end;

class function Pair.Map<A, B, C>(const AFunc: TFunc<B, C>;
  const APair: IPair<A, B>): IPair<A, C>;
begin
  Result := MapSecond<A, B, C>(AFunc, APair);
end;

class function Pair.MapBoth<A, B, C, D>(const AFirst: TFunc<A, C>;
  const ASecond: TFunc<B, D>; const APair: IPair<A, B>): IPair<C, D>;
begin
  Result := Create<C, D>(AFirst(APair.First), ASecond(APair.Second));
end;

class function Pair.MapFirst<A, B, C>(const AFunc: TFunc<A, C>;
  const APair: IPair<A, B>): IPair<C, B>;
begin
  Result := Create<C, B>(AFunc(APair.First), APair.Second);
end;

class function Pair.MapSecond<A, B, C>(const AFunc: TFunc<B, C>;
  const APair: IPair<A, B>): IPair<A, C>;
begin
  Result := Create<A, C>(APair.First, AFunc(APair.Second));
end;

end.
