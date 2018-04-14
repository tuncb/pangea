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
  end;

implementation

type
  PInteger = ^Integer;

procedure ExpectsNilInteger(AVar: PInteger);
begin
  Assert.IsTrue(AVar = nil);
end;

procedure ExpectsPIntegerEqualToValue(AVar: PInteger; AValue: Integer);
begin
  Assert.AreEqual(AVar^, AValue);
end;

procedure TTestOptional.TestEmpty();
var
  LOptional: TOptional<Integer>;
begin
  ExpectsNilInteger(EMPTY);

  LOptional := EMPTY;
  Assert.IsFalse(LOptional.HasValue);
  Assert.IsTrue(LOptional.ValueOr(20) = 20);
end;

procedure TTestOptional.TestFilled();
const
  VAL = 10;
var
  LOptional: TOptional<Integer>;
begin
  LOptional := VAL;
  Assert.IsTrue(LOptional.HasValue);
  Assert.IsTrue(LOptional.Value = VAL);
  Assert.IsTrue(LOptional.ValueOr(20) = VAL);
  ExpectsPIntegerEqualToValue(LOptional, VAL);

  LOptional.Reset();
  Assert.IsFalse(LOptional.HasValue);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestOptional);

end.


