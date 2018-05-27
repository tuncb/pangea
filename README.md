# pangea
modern design patterns for delphi

## Scope action

Defines actions that will be executed at the end of scope

```pascal
type
  IScopeAction = interface ['{CD7D4D9B-2CDD-4406-9B2D-E76F79F0973F}']
    procedure Cancel(); // cancels the action
  end;

// Executes the action on scope exit
function ExecuteOnScopeExit(const AAction: TProc): IScopeAction;.
// Executes the action on scope exit if there is no error propagating 
function ExecuteOnScopeSuccess(const AAction: TProc): IScopeAction;
// Executes the action on scope exit if there is an error propagating 
function ExecuteOnScopeFailure(const AAction: TProc): IScopeAction;  
```

## Memory Guard

Defines automatic memory management that will be executed at the end of scope

**GuardMemoryOnExit**

Assigns nil to the given objects and FreeAndNils them on scope exit
```pascal
procedure Fun();
var
  LDummy1, LDummy2: TDummy; // TDummy = class
begin
  GuardMemoryOnExit(LDummy1, LDummy2);
  LDummy1 := TDummy.Create();
  LDummy2 := TDummy.Create();
end;
```
Roughly equal to
```pascal
procedure Fun();
var
  LDummy1, LDummy2: TDummy; // TDummy = class
begin
  LDummy1 := nil;
  LDummy2 := nil;
  try
    LDummy1 := TDummy.Create();
    LDummy2 := TDummy.Create();
  finally
    FreeAndNil(LDummy1);
    FreeAndNil(LDummy2);   
  end;
end;
```

**GuardMemoryOnFailure**

Assigns nil to the given objects and FreeAndNils them on scope exit if there is an error propagating
```pascal
function Fun(): TDummy;
begin
  GuardMemoryOnFailure(Result);
  Result := TDummy.Create();
end;
```
Roughly equal to
```pascal
function Fun(): TDummy;
begin
  Result := nil;
  try
    Result := TDummy.Create();
  except
    FreeAndNil(Result);
    raise;
  end;
end;
```
