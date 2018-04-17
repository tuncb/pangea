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

initialization
  TDUnitX.RegisterTestFixture(TTestOptional);

end.


