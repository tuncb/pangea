unit Pangea.Pipeline.ExecutionPolicy.Parallel;

interface

uses
  Pangea.Pipeline.ExecutionPolicy,
  System.SysUtils;

type
  TParallelExecutionPolicy = class(TInterfacedObject, IExecutionPolicy)
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
  end;

implementation

uses
  System.Threading;

procedure TParallelExecutionPolicy.ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer;
  const AProc: TProc<Integer>);
begin
  TParallel.For(AInclusiveStartIndex, AInclusiveEndIndex, AProc);
end;

end.