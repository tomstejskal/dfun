unit DFun.IO;

interface

uses
  System.Classes,
  System.SysUtils;

type
  IIO<A> = interface
  ['{B30B690A-6E63-4CB4-BA90-E24BC6B886EC}']
    function Exec: A;
  end;

  IO = class
    class function Pure<A>(const AValue: A): IIO<A>;
    class function Action<A>(const AFunc: TFunc<A>): IIO<A>;
    class function Map<A, B>(const AFunc: TFunc<A, B>;
      const Action: IIO<A>): IIO<B>;
    class function AndThen<A, B>(const AFunc: TFunc<A, IIO<B>>;
      const Action: IIO<A>): IIO<B>;
  end;

  TIO<A> = class(TInterfacedObject, IIO<A>)
  strict private
    fFunc: TFunc<A>;
  public
    constructor Create(const AFunc: TFunc<A>);
    function Exec: A;
  end;

  TIOAndThen<A, B> = class(TInterfacedObject, IIO<B>)
  strict private
    fAction: IIO<A>;
    fFunc: TFunc<A, IIO<B>>;
  public
    constructor Create(const AFunc: TFunc<A, IIO<B>>;
      const Action: IIO<A>);
    function Exec: B;
  end;

implementation

{ TIO<A> }

constructor TIO<A>.Create(const AFunc: TFunc<A>);
begin
  inherited Create;
  fFunc := AFunc;
end;

function TIO<A>.Exec: A;
begin
  Result := fFunc;
end;

{ IO }

class function IO.Action<A>(const AFunc: TFunc<A>): IIO<A>;
begin
  Result := TIO<A>.Create(AFunc);
end;

class function IO.AndThen<A, B>(const AFunc: TFunc<A, IIO<B>>;
  const Action: IIO<A>): IIO<B>;
begin
  Result := TIOAndThen<A, B>.Create(AFunc, Action);
end;

class function IO.Map<A, B>(const AFunc: TFunc<A, B>;
  const Action: IIO<A>): IIO<B>;
begin
  Result := TIOAndThen<A, B>.Create(
    function(X: A): IIO<B> begin
      Result := Pure<B>(AFunc(X));
    end,
    Action);
end;

class function IO.Pure<A>(const AValue: A): IIO<A>;
begin
  Result := TIO<A>.Create(function: A begin Result := AValue end);
end;

{ TIOAndThen<A, B> }

constructor TIOAndThen<A, B>.Create(const AFunc: TFunc<A, IIO<B>>;
  const Action: IIO<A>);
begin
  inherited Create;
  fAction := Action;
  fFunc := AFunc;
end;

function TIOAndThen<A, B>.Exec: B;
var
  X: IIO<B>;
begin
  X := fFunc(fAction.Exec);
  Result := X.Exec;
end;

end.
