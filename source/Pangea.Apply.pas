unit Pangea.Apply;

interface

uses
  System.Generics.Collections;

type
  TFilterFun<T> = reference to function(const AValue: T): Boolean;
  TMapFun<T> = reference to function(const AValue: T): T;

type
  IApplier<T> = interface['{143A894A-397A-437D-8339-881FAFF5B133}']
    function Filter(const AFilterFun: TFilterFun<T>): IApplier<T>;
    function Map(const AMapFun: TMapFun<T>): IApplier<T>;

    procedure Apply(AList: TList<T>);
    procedure ApplyInParallel(AList: TList<T>);
  end;

type
  TApply<T> = record
  public
    class function Filter(const AFilterFun: TFilterFun<T>): IApplier<T>; static;
    class function Map(const AMapFun: TMapFun<T>): IApplier<T>; static;
  end;

type
  TApplyAction<T> = class
  strict private
    function IsFiltered(const AValue: T): Boolean;
    procedure ApplyUnfiltered(var AValue: T);
  public
    FilterFuns: TList<TFilterFun<T>>;
    MapFuns: TList<TMapFun<T>>;

    procedure Apply(AList: TList<T>);
    procedure ApplyInParallel(AList: TList<T>);

    constructor Create();
    destructor Destroy(); override;
  end;

type
  TApplier<T> = class(TInterfacedObject, IApplier<T>)
  strict private
    FApplyActions: TObjectList<TApplyAction<T>>;
  public
    constructor Create();
    destructor Destroy(); override;

    function Filter(const AFilterFun: TFilterFun<T>): IApplier<T>;
    function Map(const AMapFun: TMapFun<T>): IApplier<T>;

    procedure Apply(AList: TList<T>);
    procedure ApplyInParallel(AList: TList<T>);
  end;

implementation

uses
  Pangea.MemoryGuard,
  System.SysUtils,
  System.Threading;

constructor TApplyAction<T>.Create();
begin
  inherited Create();

  FilterFuns := TList<TFilterFun<T>>.Create();
  MapFuns := TList<TMapFun<T>>.Create();
end;

destructor TApplyAction<T>.Destroy();
begin
  FreeAndNil(FilterFuns);
  FreeAndNil(MapFuns);

  inherited Destroy();
end;

function TApplyAction<T>.IsFiltered(const AValue: T): Boolean;
var
  LIndex: Integer;
begin
  Result := True;

  for LIndex := 0 to FilterFuns.Count - 1 do
  begin
    if not FilterFuns[LIndex](AValue) then
    begin
      Result := False;
      EXIT;
    end;
  end;
end;

procedure TApplyAction<T>.ApplyUnfiltered(var AValue: T);
var
  LIndex: Integer;
begin
  for LIndex := 0 to MapFuns.Count - 1 do
  begin
    AValue := MapFuns[LIndex](AValue);
  end;
end;

procedure TApplyAction<T>.Apply(AList: TList<T>);
var
  LIndex: Integer;
  LValue: T;
begin
  for LIndex := 0 to AList.Count - 1 do
  begin
    LValue := AList[LIndex];
    if not IsFiltered(AList[LIndex]) then
      CONTINUE;
    ApplyUnfiltered(LValue);

    AList[LIndex] := LValue;
  end;
end;

procedure TApplyAction<T>.ApplyInParallel(AList: TList<T>);
begin
  TParallel.For(0, AList.Count - 1,
    procedure (LIndex: Integer)
    var
      LValue: T;
    begin
      LValue := AList[LIndex];
      if not IsFiltered(AList[LIndex]) then
        EXIT;
      ApplyUnfiltered(LValue);

      AList[LIndex] := LValue;
    end);
end;


constructor TApplier<T>.Create();
begin
  inherited Create();

  FApplyActions := TObjectList<TApplyAction<T>>.Create();
  FApplyActions.Add(TApplyAction<T>.Create());
end;

destructor TApplier<T>.Destroy();
begin
  FreeAndNil(FApplyActions);
  inherited Destroy();
end;

function TApplier<T>.Filter(const AFilterFun: TFilterFun<T>): IApplier<T>;
begin
  if FApplyActions.Last.MapFuns.Count > 0 then
  begin
    FApplyActions.Add(TApplyAction<T>.Create());
  end;

  FApplyActions.Last.FilterFuns.Add(AFilterFun);
  Result := Self;
end;

function TApplier<T>.Map(const AMapFun: TMapFun<T>): IApplier<T>;
begin
  FApplyActions.Last.MapFuns.Add(AMapFun);
  Result := Self;
end;

procedure TApplier<T>.Apply(AList: TList<T>);
var
  LIndex: Integer;
begin
  for LIndex := 0 to FApplyActions.Count - 1 do
  begin
    FApplyActions[LIndex].Apply(AList);
  end;
end;

procedure TApplier<T>.ApplyInParallel(AList: TList<T>);
var
  LIndex: Integer;
begin
  for LIndex := 0 to FApplyActions.Count - 1 do
  begin
    FApplyActions[LIndex].ApplyInParallel(AList);
  end;
end;

class function TApply<T>.Filter(const AFilterFun: TFilterFun<T>): IApplier<T>;
begin
  ClearThenFreeNilOnFailure(Result);

  Result := TApplier<T>.Create();
  Result.Filter(AFilterFun);
end;

class function TApply<T>.Map(const AMapFun: TMapFun<T>): IApplier<T>;
begin
  ClearThenFreeNilOnFailure(Result);

  Result := TApplier<T>.Create();
  Result := Result.Map(AMapFun);
end;


end.

