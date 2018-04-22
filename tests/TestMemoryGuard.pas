unit TestMemoryGuard;

interface

uses
  DUnitX.TestFramework,
  Pangea.MemoryGuard;

type
  TTestMemoryGuard = class
  public
    [Test]
    procedure TestSyntax();
    [Test]
    procedure TestMemoryGuardOnExit();
  end;

implementation

uses
  Pangea.ScopeAction,
  System.SysUtils;

type
  TDestructorLogger = class
  strict private
    FIsDestructorCalled: PBoolean;
  public
    constructor Create(var AIsDestructorCalled: Boolean);
    destructor Destroy(); override;
  end;

type
  PTDestructorLogger = ^TDestructorLogger;

type
  TDummy = class
  end;

constructor TDestructorLogger.Create(var AIsDestructorCalled: Boolean);
begin
  inherited Create();

  AIsDestructorCalled := False;
  FIsDestructorCalled := @AIsDestructorCalled;
end;

destructor TDestructorLogger.Destroy();
begin
  FIsDestructorCalled^ := True;
  inherited Destroy();
end;

procedure LogDestruction(var AIsDestructorCalled: Boolean;
  const AExecuteGuard: TFunc<PTDestructorLogger, IScopeAction>);
var
  LLogger: TDestructorLogger;
begin
  AExecuteGuard(@LLogger);
  LLogger := TDestructorLogger.Create(AIsDestructorCalled);
end;

function CreateDummy(): TDummy;
begin
  ClearAndGuardMemoryOnFailure([PTObject(@Result)]);
  Assert.IsFalse(Assigned(Result));
  Result := TDummy.Create();
end;

procedure TTestMemoryGuard.TestSyntax();
var
  LDummy1, LDummy2, LDummy3: TDummy;
begin
  ClearAndGuardMemoryOnExit([@LDummy1, @LDummy2, @LDummy3]);
  Assert.IsFalse(Assigned(LDummy1));
  Assert.IsFalse(Assigned(LDummy2));
  Assert.IsFalse(Assigned(LDummy3));

  LDummy1 := TDummy.Create();
  LDummy2 := TDummy.Create();
  LDummy3 := CreateDummy();

  Assert.IsTrue(Assigned(LDummy1));
  Assert.IsTrue(Assigned(LDummy2));
  Assert.IsTrue(Assigned(LDummy3));
end;

procedure TTestMemoryGuard.TestMemoryGuardOnExit();
var
  LIsDestructorCalled: Boolean;
  LPLogger: PTDestructorLogger;
begin
  LIsDestructorCalled := False;
  LogDestruction(LIsDestructorCalled, function(APLogger: PTDestructorLogger): IScopeAction
    begin
      LPLogger := APLogger;
      Result := nil;
    end);
  Assert.IsFalse(LIsDestructorCalled);
  FreeAndNil(LPLogger^);

  LIsDestructorCalled := False;
  LogDestruction(LIsDestructorCalled, function(APLogger: PTDestructorLogger): IScopeAction
    begin
      Result := ClearAndGuardMemoryOnExit([@(APLogger^)]);
      Assert.IsFalse(Assigned(APLogger^));
    end);
  Assert.IsTrue(LIsDestructorCalled);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMemoryGuard);

end.
