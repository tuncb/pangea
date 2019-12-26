unit Pangea.Pipeline.ExecutionPolicy;

interface

uses
  System.SysUtils;

type
  IExecutionPolicy = interface['{D481AD6F-1A94-4F02-8E52-A00E7D24F299}']
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
  end;

function GetExecutionPolicy(const AExecutionPolicy: IExecutionPolicy): IExecutionPolicy;

implementation

type
  TSequentialExecutionPolicy = class(TInterfacedObject, IExecutionPolicy)
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
  end;

procedure TSequentialExecutionPolicy.ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
var
  LIndex: Integer;
begin
  for LIndex := AInclusiveStartIndex to AInclusiveEndIndex do
  begin
    AProc(LIndex);
  end;
end;

function GetExecutionPolicy(const AExecutionPolicy: IExecutionPolicy): IExecutionPolicy;
begin
  Result := AExecutionPolicy;
  if not Assigned(Result) then
    Result := TSequentialExecutionPolicy.Create();
end;

end.