unit TestOptional;

interface

uses
  DUnitX.TestFramework,
  Pangea.Optional;

type
  TTestOptional = class
  public
    [Test]
    procedure TestEmpty();
    [Test]
    procedure TestFilled();
    [Test]
    procedure TestMap();
    [Test]
    procedure TestOrElse();
  end;

implementation

procedure TTestOptional.TestEmpty();
const
  VAL = 20;
var
  LOptional: TOptional<Integer>;
begin
  LOptional := EMPTY;
  Assert.IsFalse(LOptional.HasValue);
  Assert.IsTrue(LOptional.ValueOr(VAL) = VAL);
end;

procedure TTestOptional.TestFilled();
const
  VAL = 10;
  NOT_VAL = 20;
var
  LOptional: TOptional<Integer>;
begin
  LOptional := VAL;
  Assert.IsTrue(LOptional.HasValue);
  Assert.IsTrue(LOptional.Value = VAL);
  Assert.IsTrue(LOptional.ValueOr(NOT_VAL) = VAL);

  LOptional.Reset();
  Assert.IsFalse(LOptional.HasValue);
end;

function DecreaseTenIfPositive(const AValue: Integer): TOptional<Integer>; overload;
begin
  Result := EMPTY;
  if (AValue > 0) then
    Result := AValue - 10;
end;

function DecreaseTen(const AValue: Integer): Integer; overload;
begin
  Result := AValue - 10;
end;

procedure TTestOptional.TestMap();
var
  AValue: TOptional<Integer>;
begin
  AValue := TOptional<Integer>(30)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(0, AValue.Value);

  AValue := TOptional<Integer>(20)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive);

  Assert.IsFalse(AValue.HasValue);

  AValue := TOptional<Integer>(30)
    .Map(DecreaseTen)
    .Map(DecreaseTen)
    .Map(DecreaseTen);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(0, AValue.Value);

  AValue := TOptional<Integer>(20)
    .Map(DecreaseTen)
    .Map(DecreaseTen)
    .Map(DecreaseTen)
    .Map(DecreaseTen);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(-20, AValue.Value);
end;

procedure TTestOptional.TestOrElse();
var
  AIsFunctorCalled: Boolean;
begin
  AIsFunctorCalled := False;

  TOptional<Integer>(20)
    .Map(DecreaseTen)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .OrElse(procedure()
      begin
        AIsFunctorCalled := True;
      end);

  Assert.IsTrue(AIsFunctorCalled);

  AIsFunctorCalled := False;
  TOptional<Integer>(20)
    .Map(DecreaseTenIfPositive)
    .Map(DecreaseTenIfPositive)
    .OrElse(procedure()
      begin
        AIsFunctorCalled := True;
      end);

  Assert.IsFalse(AIsFunctorCalled);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOptional);

end.


