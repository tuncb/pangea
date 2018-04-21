unit Pangea.ScopeAction;

interface

uses
  System.SysUtils;

type
  IScopeAction = interface ['{CD7D4D9B-2CDD-4406-9B2D-E76F79F0973F}']
    procedure Cancel();
  end;

function DoOnScopeExit(const AAction: TProc): IScopeAction;
function DoOnScopeSuccess(const AAction: TProc): IScopeAction;
function DoOnScopeFailure(const AAction: TProc): IScopeAction;

implementation

type
  TScopeExitAction = class(TInterfacedObject, IScopeAction)
  strict private
    FAction: TProc;
  public
    constructor Create(const AAction: TProc);
    destructor Destroy(); override;

    procedure Cancel();
  end;

type
  TScopeSuccessAction = class(TScopeExitAction)
  public
    destructor Destroy(); override;
  end;

type
  TScopeFailureAction = class(TScopeExitAction)
  public
    destructor Destroy(); override;
  end;

constructor TScopeExitAction.Create(const AAction: TProc);
begin
  inherited Create();

  if not Assigned(AAction) then
    raise EArgumentException.Create('Guard function is nil.');

  FAction := AAction;
end;

destructor TScopeExitAction.Destroy();
begin
  if Assigned(FAction) then
  begin
    FAction();
  end;

  inherited Destroy();
end;

procedure TScopeExitAction.Cancel();
begin
  FAction := nil;
end;

destructor TScopeSuccessAction.Destroy();
begin
  if ExceptObject <> nil then
  begin
    Cancel();
  end;

  inherited Destroy();
end;

destructor TScopeFailureAction.Destroy();
begin
  if ExceptObject = nil then
  begin
    Cancel();
  end;

  inherited Destroy();
end;

function DoOnScopeExit(const AAction: TProc): IScopeAction;
begin
  Result := TScopeExitAction.Create(AAction);
end;

function DoOnScopeSuccess(const AAction: TProc): IScopeAction;
begin
  Result := TScopeSuccessAction.Create(AAction);
end;

function DoOnScopeFailure(const AAction: TProc): IScopeAction;
begin
  Result := TScopeFailureAction.Create(AAction);
end;

end.
