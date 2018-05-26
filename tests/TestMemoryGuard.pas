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
  TDummy = class
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

procedure LogDestruction(
  const ANrObjects: Integer;
  const AExecuteGuard: TFunc<TArray<TDestructorLogger>, IScopeAction>;
  const AIsExceptionRaised: Boolean;
  var ADestructorCallCounter: Integer);
var
  LObjects: TArray<TDestructorLogger>;
  LIndex: Integer;
begin
  SetLength(LObjects, ANrObjects);

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

function CreateDummy(): TDummy;
begin
  GuardMemoryOnFailure(Result);
  Result := TDummy.Create();
end;

procedure TTestMemoryGuard.TestSyntax();
var
  LDummy1, LDummy2, LDummy3: TDummy;
begin
  GuardMemoryOnExit(LDummy1, LDummy2, LDummy3);
  LDummy1 := TDummy.Create();
  LDummy2 := TDummy.Create();
  LDummy3 := CreateDummy();
end;

procedure TestForNrObjects(
  const ANrObjects, ANrExpectedDestructions: Integer;
  const AIsExceptionRaised: Boolean;
  const AExecuteGuard: TFunc<TArray<TDestructorLogger>, IScopeAction>);
var
  LDestructionCounter: Integer;
begin
  LDestructionCounter := 0;
  LogDestruction(ANrObjects,
    function(AObjects: TArray<TDestructorLogger>): IScopeAction
    var
      LIndex: Integer;
    begin
      Result := AExecuteGuard(AObjects);
      for LIndex := Low(AObjects) to High(AObjects) do
      begin
        Assert.IsFalse(Assigned(AObjects[LIndex]));
      end;
    end,
    AIsExceptionRaised, LDestructionCounter);

  Assert.AreEqual(LDestructionCounter, ANrExpectedDestructions);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnExit();
begin
  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(1, 1, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0]);
        end);
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(2, 2, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0], AObjects[1]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(3, 3, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(AObjects[0], AObjects[1], AObjects[2]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(4, 4, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(5, 5, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(6, 6, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(7, 7, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(8, 8, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnExit(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6], AObjects[7]);
        end)
    end, EDummyException);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnFailureWithFailure();
begin
  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(1, 1, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0]);
        end);
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(2, 2, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0], AObjects[1]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(3, 3, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(AObjects[0], AObjects[1], AObjects[2]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(4, 4, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(5, 5, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(6, 6, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(7, 7, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6]);
        end)
    end, EDummyException);

  Assert.WillRaise(procedure()
    begin
      TestForNrObjects(8, 8, True, function(AObjects: TArray<TDestructorLogger>): IScopeAction
        begin
          Result := GuardMemoryOnFailure(
            AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
            AObjects[6], AObjects[7]);
        end)
    end, EDummyException);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnFailureWithoutFailure();
var
  LObjects: TArray<TDestructorLogger>;
  LIndex: Integer;
begin
  TestForNrObjects(8, 0, False, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      LObjects := AObjects;
      Result := GuardMemoryOnFailure(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6], AObjects[7]);
    end);

  for LIndex := Low(LObjects) to High(LObjects) do
  begin
    Assert.IsTrue(Assigned(LObjects[LIndex]));
    FreeAndNil(LObjects[LIndex]);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMemoryGuard);

end.
