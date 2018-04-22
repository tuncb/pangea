unit Pangea.MemoryGuard;

interface

uses
  Pangea.ScopeAction;

type
  PTObject = ^TObject;

type
  TMemoryGuard = class
  public
    class function ClearAndGuardOnExit();
  end;

function ClearAndGuardMemoryOnExit(AObjectPtrs: TArray<PTObject>): IScopeAction;
function ClearAndGuardMemoryOnFailure(AObjectPtrs: TArray<PTObject>): IScopeAction;

implementation

uses
  System.SysUtils;

type
  TMemoryGuardOnExit = class(TInterfacedObject, IScopeAction)
  strict private
    FPointers: TArray<PTObject>;
  public
    constructor Create(const AObjectPtrs: TArray<PTObject>);
    destructor Destroy(); override;

    procedure Cancel();
  end;

type 
  TMemoryGuardOnFailure = class(TMemoryGuardOnExit)
  public
    destructor Destroy(); override;
  end;

constructor TMemoryGuardOnExit.Create(const AObjectPtrs: TArray<PTObject>);
begin
  inherited Create();
  FPointers := AObjectPtrs;
end;

destructor TMemoryGuardOnExit.Destroy();
var 
  LIndex: Integer;
begin
  for LIndex := Low(FPointers) to High(FPointers) do
  begin
    FreeAndNil(FPointers[LIndex]^);
  end;

  inherited Destroy();
end;

procedure TMemoryGuardOnExit.Cancel();
begin
  SetLength(FPointers, 0);
end;

destructor TMemoryGuardOnFailure.Destroy();
begin
  if ExceptObject = nil then
  begin
    Cancel();
  end;

  inherited Destroy();
end;

procedure ClearMemory(AObjectPtrs: TArray<PTObject>);
var 
  LIndex: Integer;
begin
  for LIndex := Low(AObjectPtrs) to High(AObjectPtrs) do
  begin
    (AObjectPtrs[LIndex])^ := nil;
  end;  
end;

function ClearAndGuardMemoryOnExit(AObjectPtrs: TArray<PTObject>): IScopeAction;
begin
  ClearMemory(AObjectPtrs);
  Result := TMemoryGuardOnExit.Create(AObjectPtrs);
end;

function ClearAndGuardMemoryOnFailure(AObjectPtrs: TArray<PTObject>): IScopeAction;
begin
  ClearMemory(AObjectPtrs);
  Result := TMemoryGuardOnFailure.Create(AObjectPtrs);
end;

end.
