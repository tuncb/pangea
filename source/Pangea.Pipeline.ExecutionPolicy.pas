unit Pangea.Pipeline.ExecutionPolicy;

interface

uses
  System.Generics.Collections,
  System.SysUtils;

type
  TExecutionList<T> = class
  public
    procedure Add(const AValue: T); virtual; abstract;
    function Get(const AIndex: Integer): T; virtual; abstract;
    function GetCount(): Integer; virtual; abstract;

    property Count: Integer read GetCount;
    property Values[const AIndex: Integer]: T read Get; default;
  end;

  IExecutionPolicy<T, R> = interface['{26C6BA05-2F49-46F0-9AC7-4E3998A7BF08}']
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
    function CreateExecutionList(): TExecutionList<R>;
  end;

type
  TSequentialExecutionPolicy<T, R> = class(TInterfacedObject, IExecutionPolicy<T, R>)
  public
    procedure ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer;
      const AProc: TProc<Integer>);

    function CreateExecutionList(): TExecutionList<R>;
  end;

type
  TExecutionPolicyProvider<T, R> = class
  public
    class function Provide(const AExecutionPolicy: IExecutionPolicy<T, R>): IExecutionPolicy<T, R>;
  end;

type
  TSequentialExecutionList<T> = class(TExecutionList<T>)
  strict private
    FList: TList<T>;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Add(const AValue: T); override;
    function Get(const AIndex: Integer): T; override;
    function GetCount(): Integer; override;
  end;

implementation

procedure TSequentialExecutionPolicy<T, R>.ForAll(const AInclusiveStartIndex, AInclusiveEndIndex: Integer; const AProc: TProc<Integer>);
var
  LIndex: Integer;
begin
  for LIndex := AInclusiveStartIndex to AInclusiveEndIndex do
  begin
    AProc(LIndex);
  end;
end;

function TSequentialExecutionPolicy<T, R>.CreateExecutionList(): TExecutionList<R>;
begin
  Result := TSequentialExecutionList<R>.Create();
end;

class function TExecutionPolicyProvider<T, R>.Provide(const AExecutionPolicy: IExecutionPolicy<T, R>): IExecutionPolicy<T, R>;
begin
  Result := AExecutionPolicy;
  if not Assigned(Result) then
    Result := TSequentialExecutionPolicy<T, R>.Create();
end;

constructor TSequentialExecutionList<T>.Create();
begin
  inherited Create();
  FList := TList<T>.Create();
end;

destructor TSequentialExecutionList<T>.Destroy();
begin
  FreeAndNil(FList);
  inherited Destroy();
end;

procedure TSequentialExecutionList<T>.Add(const AValue: T);
begin
  FList.Add(AValue);
end;

function TSequentialExecutionList<T>.Get(const AIndex: Integer): T;
begin
  Result := FList[AIndex];
end;

function TSequentialExecutionList<T>.GetCount(): Integer;
begin
  Result := FList.Count;
end;

end.