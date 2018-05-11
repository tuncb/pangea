unit TestApply;

interface

uses
  DUnitX.TestFramework,
  Pangea.Apply;

type
  TTestApply = class
  public
    [Test]
    procedure TestSyntax();
  end;

implementation

uses
  Pangea.MemoryGuard,
  System.Generics.Collections;

function Square(const AValue: Double): Double;
begin
  Result := AValue * AValue;
end;

procedure TTestApply.TestSyntax();
const
  NR_NUMBERS = 50;
var
  LIndex: Integer;
  LList: TList<Double>;
  LIsEven, LLessOrEqualThan10: TFilterFun<Double>;
  LDoubleValue: TMapFun<Double>;
begin
  ClearThenFreeNilOnExit(LList);
  LList := TList<Double>.Create();

  for LIndex := 0 to NR_NUMBERS do
  begin
    LList.Add(LIndex);
  end;

  LIsEven := function(const AValue: Double): Boolean
    begin
      Result := not Odd(Trunc(AValue));
    end;

  LLessOrEqualThan10 := function(const AValue: Double): Boolean
    begin
      Result := AValue <= 10.0;
    end;

  LDoubleValue := function(const AValue: Double): Double
    begin
      Result := AValue * 2.0;
    end;

  TApply<Double>
    .Filter(LLessOrEqualThan10)
    .Map(Square)
    .Filter(LIsEven)
    .Map(LDoubleValue)
    .ApplyInParallel(LList);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestApply);

end.