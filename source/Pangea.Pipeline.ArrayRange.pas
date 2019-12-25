unit Pangea.Pipeline.ArrayRange;

interface

uses
  Pangea.Pipeline.Range;

type
  TArrayRange<T> = class(TInterfacedObject, IRange<T>)
  strict private
    FArray: TArray<T>;
    LIndex: Integer;
  public
    function GetCurrent(): T;
    procedure SetCurrent(const AValue: T);
    function MoveNext(): Boolean;
    procedure Reset();

    constructor Create(const AArray: TArray<T>);
  end;

implementation

function TArrayRange<T>.GetCurrent(): T;
begin
  Result := FArray[LIndex];
end;

procedure TArrayRange<T>.SetCurrent(const AValue: T);
begin
  FArray[LIndex] := AValue;
end;

function TArrayRange<T>.MoveNext(): Boolean;
begin
  Inc(LIndex);
  Result := LIndex < Length(FArray);
end;

procedure TArrayRange<T>.Reset();
begin
  LIndex := 0;
end;

constructor TArrayRange<T>.Create(const AArray: TArray<T>);
begin
  FArray := AArray;
  Reset();
end;

end.