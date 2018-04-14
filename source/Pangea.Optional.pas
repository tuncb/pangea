unit Pangea.Optional;

interface

uses
  System.SysUtils;

type
  TOptionalBadAccessException = class(Exception)
  end;

type
  TEmpty = record
    class operator Implicit(const ANotNeeded: TEmpty): Pointer;
  end;

type
  TOptional<T> = record
  strict private
    FIsAssignedValue: Boolean;
    FValue: T;

    function GetValue(): T;
    procedure SetValue(const AValue: T);
  public
    constructor Create(const AValue: T);

    procedure Reset();
    function ValueOr(const AValue: T): T;

    class operator Implicit(const AValue: T): TOptional<T>;
    class operator Implicit(const AEmptyValue: TEmpty): TOptional<T>;
    class operator Implicit(const AOptional: TOptional<T>): Pointer;

    property Value: T read GetValue write SetValue;
    property HasValue: boolean read FIsAssignedValue;
  end;

const
  EMPTY: TEmpty = ();

implementation

function TOptional<T>.GetValue(): T;
begin
  if FIsAssignedValue then
    Result := FValue
  else
    raise TOptionalBadAccessException.Create('Attampted acces to empty optional');
end;

procedure TOptional<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FIsAssignedValue := True;
end;

constructor TOptional<T>.Create(const AValue: T);
begin
  SetValue(AValue);
end;

procedure TOptional<T>.Reset();
begin
  FIsAssignedValue := False;
end;

function TOptional<T>.ValueOr(const AValue: T): T;
begin
  if FIsAssignedValue then
    Result := FValue
  else
    Result := AValue;
end;

class operator TOptional<T>.Implicit(const AValue: T): TOptional<T>;
begin
  Result := TOptional<T>.Create(AValue);
end;

class operator TOptional<T>.Implicit(const AEmptyValue: TEmpty): TOptional<T>;
begin
  Result.Reset();
end;

class operator TOptional<T>.Implicit(const AOptional: TOptional<T>): Pointer;
begin
  if AOptional.HasValue then
    Result := @AOptional.FValue
  else
    Result := nil;
end;

class operator TEmpty.Implicit(const ANotNeeded: TEmpty): Pointer;
begin
  Result := nil;
end;

end.
