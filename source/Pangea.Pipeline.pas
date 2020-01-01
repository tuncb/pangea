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
  TPredicateFunc<T> = reference to function(const AValue: T): Boolean;

type
  IFilterStorage<T> = interface['{EBA1EFC6-7FCE-4CDA-A455-2BE5BF318F8C}']
    procedure Add(const AFilter: TPredicateFunc<T>);
    function Check(const AValue: T): Boolean;
    procedure Clear();
  end;

  TFilterStorage<T> = class(TInterfacedObject, IFilterStorage<T>)
  strict private
    FFilters: TList<TPredicateFunc<T>>;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Add(const AFilter: TPredicateFunc<T>);
    function Check(const AValue: T): Boolean;
    procedure Clear();
  end;

type
  TPipe<T> = record
  strict private
    FRange: IRange<T>;
    FFilters: IFilterStorage<T>;
  public
    constructor Create(const ARange: IRange<T>);
    function ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy<T, T> = nil): TPipe<T>;
    function Map<R>(const ANewRange: IRange<R>; const AMapFunc: TMapFunc<T, R>; const AExecutionPolicy: IExecutionPolicy<T, R> = nil): TPipe<R>;
    function Filter(const AFilter: TPredicateFunc<T>): TPipe<T>;
  end;

type
  TPipeline<T> = class
  public
    class function Start(ARange: IRange<T>): TPipe<T>;
  end;

implementation

uses
  Pangea.MemoryGuard,
  System.SysUtils;

class function TPipeline<T>.Start(ARange: IRange<T>): TPipe<T>;
begin
  Result := TPipe<T>.Create(ARange);
end;

function TPipe<T>.ForEach(const AMutatingFunc: TMutateFunc<T>; const AExecutionPolicy: IExecutionPolicy<T, T>): TPipe<T>;
var
  LRange: IRange<T>;
  LFilters: IFilterStorage<T>;
  LExecutionPolicy: IExecutionPolicy<T, T>;
begin
  LRange := FRange;
  LFilters := FFilters;
  LExecutionPolicy := TExecutionPolicyProvider<T, T>.Provide(AExecutionPolicy);

  LExecutionPolicy.ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      if LFilters.Check(LRange[AIndex]) then
        LRange[AIndex] := AMutatingFunc(LRange[AIndex]);
    end);

  LFilters.Clear();
  Result := Self;
end;

constructor TPipe<T>.Create(const ARange: IRange<T>);
begin
  if not Assigned(ARange) then
    raise Exception.Create('ARange argument is nil for TPipeline<T>.Create');

  FRange := ARange;
  FFilters := TFilterStorage<T>.Create();
end;

function TPipe<T>.Map<R>(const ANewRange: IRange<R>; const AMapFunc: TMapFunc<T, R>; const AExecutionPolicy: IExecutionPolicy<T, R>): TPipe<R>;
var
  LRange: IRange<T>;
  LExecutionPolicy: IExecutionPolicy<T, R>;
  LList: TExecutionList<R>;
  LFilters: IFilterStorage<T>;
  LNewStartingIndex: Integer;
begin
  LExecutionPolicy := TExecutionPolicyProvider<T, R>.Provide(AExecutionPolicy);
  LRange := FRange;
  LFilters := FFilters;
  LNewStartingIndex := ANewRange.GetInclusiveStart();

  GuardMemoryOnExit(LList);
  LList := LExecutionPolicy.CreateExecutionList();

  LExecutionPolicy.ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      //ANewRange[LNewStartingIndex + AIndex] := AMapFunc(LRange[AIndex]);
      if LFilters.Check(LRange[AIndex]) then
        LList.Add(AMapFunc(LRange[AIndex]));
    end);

  ANewRange.Resize(LNewStartingIndex + LList.Count);
  LExecutionPolicy.ForAll(FRange.GetInclusiveStart(), FRange.GetInclusiveEnd(),
    procedure(AIndex: Integer)
    begin
      ANewRange[LNewStartingIndex + AIndex] := LList[AIndex];
    end);

  Result := TPipe<R>.Create(ANewRange);
end;

function TPipe<T>.Filter(const AFilter: TPredicateFunc<T>): TPipe<T>;
begin
  FFilters.Add(AFilter);
  Result := Self;
end;

procedure TFilterStorage<T>.Add(const AFilter: TPredicateFunc<T>);
begin
  FFilters.Add(AFilter);
end;

function TFilterStorage<T>.Check(const AValue: T): Boolean;
var
  LFilter: TPredicateFunc<T>;
begin
  Result := True;
  for LFilter in FFilters do
  begin
    if not LFilter(AValue) then
    begin
      Result := False;
      EXIT;
    end;
  end;
end;

procedure TFilterStorage<T>.Clear();
begin
  FFilters.Clear();
end;

constructor TFilterStorage<T>.Create();
begin
  inherited Create();
  FFilters := TList<TPredicateFunc<T>>.Create();
end;

destructor TFilterStorage<T>.Destroy();
begin
  FreeAndNil(FFilters);
  inherited Destroy();
end;

end.