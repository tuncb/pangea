unit Pangea.Pipeline.ExecutionPolicy.Parallel;

interface

uses
  Pangea.Pipeline.ExecutionPolicy,
  System.SysUtils;

var
  ParallelExecutionPolicy: IExecutionPolicy;

implementation

uses
  System.Threading;

type
  TParallelExecutionPolicy = class(TInterfacedObject, IExecutionPolicy)
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
  end;

procedure TParallelExecutionPolicy.ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer;
  const AProc: TProc<Integer>);
begin
  TParallel.For(AInclusiveStartIndex, AInclusiveEndIndex, AProc);
end;

initialization
  ParallelExecutionPolicy := TParallelExecutionPolicy.Create();

end.