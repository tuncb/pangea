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
    procedure TestMemoryGuardOnFailure();
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

procedure LogDestruction(const ANrObjects: Integer;
  var ADestructorCallCounter: Integer;
  const AExecuteGuard: TFunc<TArray<TDestructorLogger>, IScopeAction>);
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

end;

function CreateDummy(): TDummy;
begin
  ClearAndGuardObjectsOnFailure(Result);
  Result := TDummy.Create();
end;

procedure TTestMemoryGuard.TestSyntax();
var
  LDummy1, LDummy2, LDummy3: TDummy;
begin
  ClearAndGuardObjectsOnExit(LDummy1, LDummy2, LDummy3);
  LDummy1 := TDummy.Create();
  LDummy2 := TDummy.Create();
  LDummy3 := CreateDummy();
end;

procedure TTestMemoryGuard.TestMemoryGuardOnExit();

  procedure TestForNrObjects(const ANrObjects: Integer;
    const AExecuteGuard: TFunc<TArray<TDestructorLogger>, IScopeAction>);
  var
    LDestructionCounter: Integer;
  begin
    LDestructionCounter := 0;
    LogDestruction(ANrObjects, LDestructionCounter,
      function(AObjects: TArray<TDestructorLogger>): IScopeAction
      var
        LIndex: Integer;
      begin
        Result := AExecuteGuard(AObjects);
        for LIndex := Low(AObjects) to High(AObjects) do
        begin
          Assert.IsFalse(Assigned(AObjects[LIndex]));
        end;
      end);
    Assert.AreEqual(LDestructionCounter, ANrObjects);
  end;

begin
  TestForNrObjects(1, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(AObjects[0]);
    end);

  TestForNrObjects(2, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(AObjects[0], AObjects[1]);
    end);

  TestForNrObjects(3, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(AObjects[0], AObjects[1], AObjects[2]);
    end);

  TestForNrObjects(4, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3]);
    end);

  TestForNrObjects(5, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4]);
    end);

  TestForNrObjects(6, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5]);
    end);

  TestForNrObjects(7, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6]);
    end);

  TestForNrObjects(8, function(AObjects: TArray<TDestructorLogger>): IScopeAction
    begin
      Result := ClearAndGuardObjectsOnExit(
        AObjects[0], AObjects[1], AObjects[2], AObjects[3], AObjects[4], AObjects[5],
        AObjects[6], AObjects[7]);
    end);
end;

procedure TTestMemoryGuard.TestMemoryGuardOnFailure();
begin

end;


initialization
  TDUnitX.RegisterTestFixture(TTestMemoryGuard);

end.
