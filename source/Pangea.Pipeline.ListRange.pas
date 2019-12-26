unit Pangea.Pipeline.ListRange;

interface

uses
  Pangea.Pipeline.Range,
  System.Generics.Collections,
  System.SysUtils;

type
  TListRange<T> = class(TInterfacedObject, IRange<T>)
  strict private
    FList: TList<T>;
    FInclusiveStartIndex: Integer;
    FInclusiveEndIndex: Integer;
  public
    function GetInclusiveStart(): Integer;
    function GetInclusiveEnd(): Integer;

    function GetValue(const AIndex: Integer): T;
    procedure SetValue(const AIndex: Integer; const AValue: T);

    constructor Create(const AList: TList<T>;
      const AInclusiveStart: Integer = INVALID_INDEX; AInclusiveEnd: Integer = INVALID_INDEX);
  end;

implementation

uses
  System.Math;

constructor TListRange<T>.Create(const AList: TList<T>;
  const AInclusiveStart: Integer = INVALID_INDEX; AInclusiveEnd: Integer = INVALID_INDEX);
begin
  if not Assigned(AList) then
    raise Exception.Create('AList is not assigned for TListRange<T>.Create');

  FList := AList;

  FInclusiveStartIndex := IfThen(AInclusiveStart < 0, 0, AInclusiveStart);
  FInclusiveEndIndex := IfThen(AInclusiveEnd < 0, FList.Count - 1, AInclusiveEnd);
end;

function TListRange<T>.GetInclusiveStart: Integer;
begin
  Result := FInclusiveStartIndex;
end;

function TListRange<T>.GetInclusiveEnd: Integer;
begin
  Result := FInclusiveEndIndex;
end;

function TListRange<T>.GetValue(const AIndex: Integer): T;
begin
  Result := FList[AIndex];
end;

procedure TListRange<T>.SetValue(const AIndex: Integer; const AValue: T);
begin
  FList[AIndex] := AValue;
end;

end.