unit TestMemoryGuard;

interface

uses
  DUnitX.TestFramework,
  Pangea.MemoryGuard;

type
  TTestMemoryGuard = class
  public
    [Test]
    procedure TestMemoryGuardOnExitWithFailure();
    [Test]
    procedure TestMemoryGuardOnExitWithoutFailure();      
    [Test]
    procedure TestMemoryGuardOnFailureWithFailure();
    [Test]
    procedure TestMemoryGuardOnFailureWithoutFailure();
  end;

implementation

uses
  Pangea.ScopeAction,
  System.SysUtils;

type
  TDestructorLogger = class
  strict private
    FPDestructorCallCounter: PInteger;
  public
    constructor Create(var ADestructorCallCounter: Integer);
    destructor Destroy(); override;
  end;

type
  EDummyException = class(Exception)
  end;

constructor TDestructorLogger.Create(var ADestructorCallCounter: Integer);
begin
  inherited Create();

  FPDestructorCallCounter := @ADestructorCallCounter;
end;

destructor TDestructorLogger.Destroy();
begin
  FPDestructorCallCounter^ := FPDestructorCallCounter^ + 1;
  inherited Destroy();
end;

// Disable warning for unititialized variable: LUninitializedDestructorLogger
{$WARN USE_BEFORE_DEF OFF}

procedure LogDestruction(
  const ANrObjects: Integer;
  const AExecuteGuard: TFunc<TArray<TDestructorLogger>, IScopeAction>;
  const AIsExceptionRaised: Boolean;
  var ADestructorCallCounter: Integer);
var
  LObjects: TArray<TDestructorLogger>;
  LIndex: Integer;
  LUninitializedDestructorLogger: TDestructorLogger;
begin
  SetLength(LObjects, ANrObjects);

  for LIndex := Low(LObjects) to High(Lobjects) do
  begin
    LObjects[LIndex] := LUninitializedDestructorLogger;
  end;

  AExecuteGuard(LObjects);

  for LIndex := Low(LObjects) to High(Lobjects) do
  begin
    LObjects[LIndex] := TDestructorLogger.Create(ADestructorCallCounter);
  end;

  if AIsExceptionRaised then
  begin
    raise EDummyException.Create('Planned Exception');
  end;

end;

{$WARN USE_BEFORE_DEF ON}

procedure TestForNrObjects(
  const ANrObjects, ANrExpectedDestructions: Integer;
  const AIsExceptionRaised: Boolean;
  const AExecuteGuardFun: TFunc<TArray<TDestructorLogger>, IScopeAction>);
var
  LDestructionCounter: Integer;
begin
  LDestructionCounter := 0;
  LogDestruction(ANrObjects,
    function(AObjects: TArray<TDestructorLogger>): IScopeAction
    var
      LIndex: Integer;
    begin
      Result := AExecuteGuardFun(AObjects);
      for LIndex := Low(AObjects) to High(AObjects) do
      begin
        Assert.IsFalse(Assigned(AObjects[LIndex]));
      end;
    end,
    AIsExceptionRaised, LDestructionCounter);

  Assert.AreEqual(LDestructionCounter, ANrExpectedDestructions);
end;

procedure TestForNrObjectsAndDestroy(const ANrObjects: Integer;
  const AExecuteGuardFun: TFunc<TArray<TDestructorLogger>, IScopeAction>);
var
  LObjects: TArray<TDestructorLogger>;
  LIndex: Integer;
begin
  TestForNrObjects(ANrObjects, 0, False, AExecuteGuardFun);

  for LIndex := Low(LObjects) to High(LObjects) do
  begin
    Assert.AreEqual(Assigned(LObjects[LIndex]), False);
    FreeAndNil(LObjects[LIndex]);
  end;
end;

procedure TTestMemoryGuard.TestMemoryGuardOnExitWithFailure();
const
  DO_RAISE = True;
begin
  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(1, 1, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0]);
        end);
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(2, 2, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0], AObjects[1]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(3, 3, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0], AObjects[1], AObjects[2]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(4, 4, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(5, 5, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(6, 6, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(7, 7, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(8, 8, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6], AObjects[7]);
        end)
    end, EDummyException);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnExitWithoutFailure();
const 
  DONT_RAISE = False;
begin
  TestForNrObjects(1, 1, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(AObjects[0]);
    end);

  TestForNrObjects(2, 2, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(AObjects[0], AObjects[1]);
    end);

  TestForNrObjects(3, 3, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(AObjects[0], AObjects[1], AObjects[2]);
    end);

  TestForNrObjects(4, 4, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
    end);

  TestForNrObjects(5, 5, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
    end);

  TestForNrObjects(6, 6, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
    end);

  TestForNrObjects(7, 7, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6]);
    end);                        

  TestForNrObjects(8, 8, DONT_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6], AObjects[7]);
    end);  
end;

procedure TTestMemoryGuard.TestMemoryGuardOnFailureWithFailure();
const
  DO_RAISE = True;
begin
  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(1, 1, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0]);
        end);
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(2, 2, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0], AObjects[1]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(3, 3, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0], AObjects[1], AObjects[2]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(4, 4, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(5, 5, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(6, 6, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(7, 7, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(8, 8, DO_RAISE, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6], AObjects[7]);
        end)
    end, EDummyException);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnFailureWithoutFailure();
begin
  TestForNrObjectsAndDestroy(1, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(AObjects[0]);
    end);

  TestForNrObjectsAndDestroy(2, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(AObjects[0], AObjects[1]);
    end);

  TestForNrObjectsAndDestroy(3, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(AObjects[0], AObjects[1], AObjects[2]);
    end);

  TestForNrObjectsAndDestroy(4, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
    end);

  TestForNrObjectsAndDestroy(5, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
    end);

  TestForNrObjectsAndDestroy(6, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
    end);

  TestForNrObjectsAndDestroy(7, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6]);
    end);                        

  TestForNrObjectsAndDestroy(8, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6], AObjects[7]);
    end);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMemoryGuard);

end.
