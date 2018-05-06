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
    [Test]
    procedure TestTake();
    [Test]
    procedure TestConjunctionDisconjunction();
    [Test]
    procedure TestMapOr();
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

function GetDefault(): Integer;
begin
  Result := 100;
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

procedure TTestOptional.TestTake();
const
  VAL = 10;
var
  AOptionalValue: TOptional<Integer>;
  AValue: Integer;
begin
  AOptionalValue := VAL;
  AValue := AOptionalValue.Take().Value;

  Assert.AreEqual(VAL, AValue);
  Assert.IsFalse(AOptionalValue.HasValue);
end;

procedure TTestOptional.TestConjunctionDisconjunction();
const
  VAL = 10;
  OTHER_VAL = 20;
var
  AOptionalValue: TOptional<Integer>;
begin
  AOptionalValue := VAL;
  Assert.AreEqual(OTHER_VAL, AOptionalValue.Conjunction(OTHER_VAL).Value);

  AOptionalValue := EMPTY;
  Assert.AreEqual(OTHER_VAL, AOptionalValue.Disconjunction(OTHER_VAL).Value);
end;

procedure TTestOptional.TestMapOr();
const 
  VAL = 50;
var
  AValue: TOptional<Integer>;
begin
  AValue := TOptional<Integer>(25)
    .Map(DecreaseTenIfPositive)
    .MapOr(DecreaseTen, VAL)
    .MapOr(DecreaseTenIfPositive, VAL);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(-5, AValue.Value);

  AValue := TOptional<Integer>(5)
    .MapOr(DecreaseTenIfPositive, GetDefault)
    .MapOr(DecreaseTenIfPositive, GetDefault)
    .MapOr(DecreaseTenIfPositive, GetDefault);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(GetDefault, AValue.Value);

  AValue := TOptional<Integer>(5)
    .MapOr(DecreaseTenIfPositive, GetDefault)
    .MapOr(DecreaseTenIfPositive, VAL)
    .MapOr(DecreaseTenIfPositive, VAL);

  Assert.IsTrue(AValue.HasValue);
  Assert.AreEqual(VAL, AValue.Value);

end;

initialization
  TDUnitX.RegisterTestFixture(TTestOptional);

end.


