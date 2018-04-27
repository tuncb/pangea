unit TestTuple;

interface

uses
  DUnitX.TestFramework,
  Pangea.Tuple;

type
  TTestTuple = class
  public
    [Test]
    procedure Test2Variables();
    [Test]
    procedure Test3Variables();
    [Test]
    procedure Test4Variables();
  end;

implementation
type
  TDummy = record
    Value: Char;
  end;

procedure TTestTuple.Test2Variables();
const
  VAL1: Integer = 10;
  VAL2: Double = 15.75;
var
  LValue1: Integer;
  LValue2: Double;
  LTuple: TTuple<Integer, Double>;
begin
  LTuple := TTuple<Integer, Double>.Create(VAL1, VAL2);
  Assert.AreEqual(VAL1, LTuple.Value1);
  Assert.AreEqual(VAL2, LTuple.Value2);

  LTuple.Unpack(LValue1, LValue2);
  Assert.AreEqual(VAL1, LValue1);
  Assert.AreEqual(VAL2, LValue2);  
end;

procedure TTestTuple.Test3Variables();
const
  VAL1: Integer = 10;
  VAL2: Double = 15.75;
  VAL3: string = 'name';
var
  LValue1: Integer;
  LValue2: Double;
  LValue3: string;
  LTuple: TTuple<Integer, Double, string>;
begin
  LTuple := TTuple<Integer, Double, string>.Create(VAL1, VAL2, VAL3);
  Assert.AreEqual(VAL1, LTuple.Value1);
  Assert.AreEqual(VAL2, LTuple.Value2);
  Assert.AreEqual(VAL3, LTuple.Value3);

  LTuple.Unpack(LValue1, LValue2, LValue3);
  Assert.AreEqual(VAL1, LValue1);
  Assert.AreEqual(VAL2, LValue2);  
  Assert.AreEqual(VAL3, LValue3);  
end;

procedure TTestTuple.Test4Variables();
const
  VAL1: Integer = 10;
  VAL2: Double = 15.75;
  VAL3: string = 'name';
  VAL4: TDummy = (Value: 'c');
var
  LValue1: Integer;
  LValue2: Double;
  LValue3: string;
  LValue4: TDummy;
  LTuple: TTuple<Integer, Double, string, TDummy>;
begin
  LTuple := TTuple<Integer, Double, string, TDummy>.Create(VAL1, VAL2, VAL3, VAL4);
  Assert.AreEqual(VAL1, LTuple.Value1);
  Assert.AreEqual(VAL2, LTuple.Value2);
  Assert.AreEqual(VAL3, LTuple.Value3);
  Assert.AreEqual(VAL4, LTuple.Value4);

  LTuple.Unpack(LValue1, LValue2, LValue3, LValue4);
  Assert.AreEqual(VAL1, LValue1);
  Assert.AreEqual(VAL2, LValue2);  
  Assert.AreEqual(VAL3, LValue3);  
  Assert.AreEqual(VAL4, LValue4);  
end;

end.
