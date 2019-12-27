unit Pangea.Pipeline.ArrayRange;

interface

uses
  Pangea.Pipeline.Range;

type
  TArrayRange<T> = class(TInterfacedObject, IRange<T>)
  strict private
    FArray: TArray<T>;
    FInclusiveStartIndex: Integer;
    FInclusiveEndIndex: Integer;
  public
    function GetInclusiveStart(): Integer;
    function GetInclusiveEnd(): Integer;

    function GetValue(const AIndex: Integer): T;
    procedure SetValue(const AIndex: Integer; const AValue: T);

    procedure Resize(const AInclusiveEnd: Integer);

    constructor Create(const AArray: TArray<T>;
      const AInclusiveStart: Integer = INVALID_INDEX; AInclusiveEnd: Integer = INVALID_INDEX);
  end;

implementation

uses
  System.Math;

constructor TArrayRange<T>.Create(const AArray: TArray<T>;
  const AInclusiveStart: Integer = INVALID_INDEX; AInclusiveEnd: Integer = INVALID_INDEX);
begin
  FArray := AArray;
  FInclusiveStartIndex := IfThen(AInclusiveStart < 0, 0, AInclusiveStart);
  FInclusiveEndIndex := IfThen(AInclusiveEnd < 0, Length(FArray) - 1, AInclusiveEnd);
end;

function TArrayRange<T>.GetInclusiveStart: Integer;
begin
  Result := FInclusiveStartIndex;
end;

function TArrayRange<T>.GetInclusiveEnd: Integer;
begin
  Result := FInclusiveEndIndex;
end;

function TArrayRange<T>.GetValue(const AIndex: Integer): T;
begin
  Result := FArray[AIndex];
end;

procedure TArrayRange<T>.SetValue(const AIndex: Integer; const AValue: T);
begin
  FArray[AIndex] := AValue;
end;

procedure TArrayRange<T>.Resize(const AInclusiveEnd: Integer);
begin
  if Length(FArray) <= AInclusiveEnd then
    SetLength(FArray, AInclusiveEnd + 1);
end;

end.