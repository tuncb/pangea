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
    LIndex: Integer;
  public
    function GetCurrent(): T;
    procedure SetCurrent(const AValue: T);
    function MoveNext(): Boolean;
    procedure Reset();

    constructor Create(const AList: TList<T>);
  end;

implementation

function TListRange<T>.GetCurrent(): T;
begin
  Result := FList[LIndex];
end;

procedure TListRange<T>.SetCurrent(const AValue: T);
begin
  FList[LIndex] := AValue;
end;

function TListRange<T>.MoveNext(): Boolean;
begin
  Inc(LIndex);
  Result := LIndex < FList.Count;
end;

procedure TListRange<T>.Reset();
begin
  LIndex := 0;
end;

constructor TListRange<T>.Create(const AList: TList<T>);
begin
  if not Assigned(AList) then
    raise Exception.Create('AList is not assigned for TListRange<T>.Create');

  FList := AList;
  Reset();
end;

end.