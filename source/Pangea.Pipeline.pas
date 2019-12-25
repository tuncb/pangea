unit Pangea.Pipeline;

interface

uses
  Pangea.Pipeline.Range,
  System.Generics.Collections;

type
  TMutateFunc<T> = reference to function(const AValue: T): T;

type
  IPipe<T> = interface['{15112A97-4A0B-4EF5-A123-03830D84A7B2}']
    procedure ForEach(const AMutatingFunc: TMutateFunc<T>);
  end;

const
  INVALID_INDEX = -1;

type
  TPipe<T> = class(TInterfacedObject, IPipe<T>)
  strict private
    FRange: IRange<T>;
  public
    constructor Create(const ARange: IRange<T>);
    procedure ForEach(const AMutatingFunc: TMutateFunc<T>);
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

procedure TPipe<T>.ForEach(const AMutatingFunc: TMutateFunc<T>);
begin
  FRange.Reset();
  repeat
    FRange.Current := AMutatingFunc(FRange.Current);
  until not FRange.MoveNext();
end;

constructor TPipe<T>.Create(const ARange: IRange<T>);
begin
  if not Assigned(ARange) then
    raise Exception.Create('ARange argument is nil for TPipeline<T>.Create');

  FRange := ARange;
end;

end.