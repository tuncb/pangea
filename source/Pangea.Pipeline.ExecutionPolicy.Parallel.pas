unit Pangea.Pipeline.ExecutionPolicy.Parallel;

interface

uses
  Pangea.Pipeline.ExecutionPolicy,
  System.Generics.Collections,
  System.SysUtils;

type
  TParallelExecutionPolicy<T, R> = class(TInterfacedObject, IExecutionPolicy<T, R>)
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
    function CreateExecutionList: TExecutionList<R>;
  end;

type
  TParallelExecutionList<T> = class(TExecutionList<T>)
  strict private
    FList: TThreadList<T>;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Add(const AValue: T); override;
    function Get(const AIndex: Integer): T; override;
    function GetCount(): Integer; override;
  end;

implementation

uses
  Pangea.ScopeAction,
  System.Threading;

procedure TParallelExecutionPolicy<T, R>.ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer;
  const AProc: TProc<Integer>);
begin
  TParallel.For(AInclusiveStartIndex, AInclusiveEndIndex, AProc);
end;

function TParallelExecutionPolicy<T,R>.CreateExecutionList(): TExecutionList<R>;
begin
  Result := TParallelExecutionList<R>.Create();
end;

constructor TParallelExecutionList<T>.Create();
begin
  inherited Create();
  FList := TThreadList<T>.Create();
end;

destructor TParallelExecutionList<T>.Destroy();
begin
  FreeAndNil(FList);
  inherited Destroy();
end;

procedure TParallelExecutionList<T>.Add(const AValue: T);
begin
  FList.Add(AValue);
end;

function TParallelExecutionList<T>.Get(const AIndex: Integer): T;
var
  LList: TList<T>;
begin
  ExecuteOnScopeExit(FList.UnlockList);

  LList := FList.LockList();
  Result := LList[AIndex];
end;

function TParallelExecutionList<T>.GetCount: Integer;
var
  LList: TList<T>;
begin
  ExecuteOnScopeExit(FList.UnlockList);

  LList := FList.LockList();
  Result := LList.Count;
end;

end.