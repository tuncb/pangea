unit Pangea.Optional;

interface

uses
  System.SysUtils;

type
  TOptionalBadAccessException = class(Exception)
  end;

type
  TEmpty = record
  end;

type
  TOptional<T> = record
  strict private
    FValue: T;
    FHasValue: Boolean;

    function GetValue(): T;
    procedure SetValue(const AValue: T);
  public
    procedure Reset();
    function ValueOr(const AValue: T): T;

    class operator Implicit(const AValue: T): TOptional<T>;
    class operator Implicit(const AEmpty: TEmpty): TOptional<T>;

    property Value: T read GetValue write SetValue;
    property HasValue: boolean read FHasValue;
  end;

const
  EMPTY: TEmpty = ();

implementation

function TOptional<T>.GetValue(): T;
begin
  if FHasValue then
    Result := FValue
  else
    raise TOptionalBadAccessException.Create('Attempted access to empty optional');
end;

procedure TOptional<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

procedure TOptional<T>.Reset();
begin
  FHasValue := False;
end;

function TOptional<T>.ValueOr(const AValue: T): T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := AValue;
end;

class operator TOptional<T>.Implicit(const AValue: T): TOptional<T>;
begin
  Result.SetValue(AValue);
end;

class operator TOptional<T>.Implicit(const AEmpty: TEmpty): TOptional<T>;
begin
  Result.Reset();
end;

end.
