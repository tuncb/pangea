unit Pangea.Algorithm;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type


  TRange<T> = record
  strict private
    FEnumerable: TEnumerable<T>;
  public
    function ForEach(const AFun: TFunc<T, T>): TRange<T>; overload;

    class operator Explicit(const AEnumerable: TEnumerable<T>): TRange<T>;
  end;


implementation

function TRange<T>.ForEach(const AFun: TFunc<T, T>): TRange<T>;
var
  LValue: T;
begin
  for LValue in FEnumerable do
  begin
    LValue := AFun(LValue);
  end;

  Result := Self;
end;

class operator TRange<T>.Explicit(const AEnumerable: TEnumerable<T>): TRange<T>;
begin
  Result.FEnumerable := AEnumerable;
end;

end.
