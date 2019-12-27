unit Pangea.Pipeline;

interface

uses
  Pangea.Optional,
  Pangea.Pipeline.ExecutionPolicy,
  Pangea.Pipeline.Range,
  System.Generics.Collections;

type
  TMutateFunc<T> = reference to function(const AValue: T): T;
  TMapFunc<T, R> = reference to function(const AValue: T): R;

type
  TPipe<T> = record
  strict private
    FRange: IRange<T>;
  public
    constructor Create(const ARange: IRange<T>);
    function ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy = nil): TPipe<T>;
    function Map<R>(const ANewRange: IRange<R>; const AMapFunc: TMapFunc<T, R>; const AExecutionPolicy: IExecutionPolicy = nil): TPipe<R>;
  end;

type
  TPipeline<T> = class
  public
    class function Start(ARange: IRange<T>): TPipe<T>;
  end;

implementation

uses
  System.SysUtils;

class function TPipeline<T>.Start(ARange: IRange<T>): TPipe<T>;
begin
  Result := TPipe<T>.Create(ARange);
end;

function TPipe<T>.ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy): TPipe<T>;
var
  LRange: IRange<T>;
begin
  LRange := FRange;
  GetExecutionPolicy(AExecutionPolicy).ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      LRange[AIndex] := AMutatingFunc(LRange[AIndex]);
    end);
  Result := Self;
end;

constructor TPipe<T>.Create(const ARange: IRange<T>);
begin
  if not Assigned(ARange) then
    raise Exception.Create('ARange argument is nil for TPipeline<T>.Create');

  FRange := ARange;
end;

function TPipe<T>.Map<R>(const ANewRange: IRange<R>; const AMapFunc: TMapFunc<T, R>; const AExecutionPolicy: IExecutionPolicy): TPipe<R>;
var
  LRange: IRange<T>;
  LNewStartingIndex: Integer;
begin
  LRange := FRange;
  LNewStartingIndex := ANewRange.GetInclusiveStart();
  ANewRange.Resize(LNewStartingIndex
    + LRange.GetInclusiveEnd() - LRange.GetInclusiveStart() + 1);

  GetExecutionPolicy(AExecutionPolicy).ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      ANewRange[LNewStartingIndex + AIndex] := AMapFunc(LRange[AIndex]);
    end);
  Result := TPipe<R>.Create(ANewRange);
end;

end.