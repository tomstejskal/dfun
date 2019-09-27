unit DFun.Null;

interface

uses
  System.Classes,
  System.SysUtils;

type
  INull = interface
  ['{20928069-739E-4EB9-A959-BA6FEE0055EE}']
  end;

  Null = class
    class var Value: INull;
    class constructor Create;
  end;

  TNull = class(TInterfacedObject, INull)
  end;

implementation

{ Null }

class constructor Null.Create;
begin
  Value := TNull.Create;
end;

end.
