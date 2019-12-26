unit Pangea.Pipeline;

interface

uses
  Pangea.Optional,
  Pangea.Pipeline.ExecutionPolicy,
  Pangea.Pipeline.Range,
  System.Generics.Collections;

type
  TMutateFunc<T> = reference to function(const AValue: T): T;

type
  IPipe<T> = interface['{15112A97-4A0B-4EF5-A123-03830D84A7B2}']
    function ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy = nil): IPipe<T>;
  end;

type
  TPipe<T> = class(TInterfacedObject, IPipe<T>)
  strict private
    FRange: IRange<T>;
  public
    constructor Create(const ARange: IRange<T>);
    function ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy = nil): IPipe<T>;
  end;

type
  TPipeline<T> = class
  public
    class function Start(ARange: IRange<T>): IPipe<T>;
  end;

implementation

uses
  System.SysUtils;

class function TPipeline<T>.Start(ARange: IRange<T>): IPipe<T>;
begin
  Result := TPipe<T>.Create(ARange);
end;

function TPipe<T>.ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy): IPipe<T>;
begin
  GetExecutionPolicy(AExecutionPolicy).ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      FRange[AIndex] := AMutatingFunc(FRange[AIndex]);
    end);
  Result := Self;
end;

constructor TPipe<T>.Create(const ARange: IRange<T>);
begin
  if not Assigned(ARange) then
    raise Exception.Create('ARange argument is nil for TPipeline<T>.Create');

  FRange := ARange;
end;

end.