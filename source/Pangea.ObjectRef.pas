unit Pangea.ObjectRef;

interface

type
  TObjectRef<T: class> = record
  strict private
    FValueReference: ^T;

    function GetValue(): T;
  public
    constructor Create(var AValue: T);

    property Value: T read GetValue;
  end;

implementation

uses
  System.SysUtils;

constructor TObjectRef<T>.Create(var AValue: T);
begin
  if not Assigned(AValue) then
    raise EArgumentException.Create('Reference is not assigned.');

  FValueReference := @AValue;
end;

function TObjectRef<T>.GetValue(): T;
begin
  Result := FValueReference^;
end;

end.
