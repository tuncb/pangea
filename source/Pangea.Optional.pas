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
    type
      TMapFunction = reference to function(const AValue: T): T;
      TChainableMapFunction = reference to function(const AValue: T): TOptional<T>;
      TValueCreatorFunction = reference to function(): T;
  public
    procedure Reset();
    function ValueOr(const AValue: T): T;

    function Map(const AFun: TChainableMapFunction): TOptional<T>; overload;
    function Map(const AFun: TMapFunction): TOptional<T>; overload;

    function MapOr(const AFun: TChainableMapFunction; const AValue: T): TOptional<T>; overload;
    function MapOr(const AFun: TMapFunction; const AValue: T): TOptional<T>; overload;
    function MapOr(const AFun: TChainableMapFunction; const AValueFun: TValueCreatorFunction): TOptional<T>; overload;
    function MapOr(const AFun: TMapFunction; const AValueFun: TValueCreatorFunction): TOptional<T>; overload;

    function Conjunction(const AValue: T): TOptional<T>; overload;
    function Disconjunction(const AValue: T): TOptional<T>; overload;

    function Take(): TOptional<T>;

    procedure OrElse(const AProc: TProc);

    class operator Implicit(const AValue: T): TOptional<T>;
    class operator Implicit(const AEmpty: TEmpty): TOptional<T>;

    class operator Explicit(const AValue: T): TOptional<T>;
    class operator Explicit(const AEmpty: TEmpty): TOptional<T>;

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

class operator TOptional<T>.Explicit(const AValue: T): TOptional<T>;
begin
  Result.SetValue(AValue);
end;

class operator TOptional<T>.Explicit(const AEmpty: TEmpty): TOptional<T>;
begin
  Result.Reset();
end;


function TOptional<T>.Map(const AFun: TChainableMapFunction): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := EMPTY;
end;

function TOptional<T>.Map(const AFun: TMapFunction): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := EMPTY;
end;

function TOptional<T>.MapOr(const AFun: TChainableMapFunction; const AValue: T): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := AValue;
end;

function TOptional<T>.MapOr(const AFun: TMapFunction; const AValue: T): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := AValue;
end;

function TOptional<T>.MapOr(const AFun: TChainableMapFunction; const AValueFun: TValueCreatorFunction): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := AValueFun();
end;

function TOptional<T>.MapOr(const AFun: TMapFunction; const AValueFun: TValueCreatorFunction): TOptional<T>;
begin
  if HasValue then
    Result := AFun(Value)
  else
    Result := AValueFun();
end;

function TOptional<T>.Conjunction(const AValue: T): TOptional<T>;
begin
  if HasValue then
    Result := AValue
  else
    Result := EMPTY;
end;

function TOptional<T>.Disconjunction(const AValue: T): TOptional<T>;
begin
  if not HasValue then
    Result := AValue
  else
    Result := EMPTY;
end;

function TOptional<T>.Take(): TOptional<T>;
begin
  Result := Self;
  Reset();
end;

procedure TOptional<T>.OrElse(const AProc: TProc);
begin
  If not HasValue then
    AProc();
end;

end.
