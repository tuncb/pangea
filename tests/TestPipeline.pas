unit TestPipeline;

interface

uses
  DUnitX.TestFramework;

type
  TTestForEach = class
  public
    [Test]
    procedure TestArray();
    [Test]
    procedure TestList();
  end;

  TTestMap = class
  public
    [Test]
    procedure TestOneToOneMap();
    [Test]
    procedure TestOneToOneTypeChangeMap();
  end;

implementation

uses
  Pangea.MemoryGuard,
  Pangea.Pipeline,
  Pangea.Pipeline.ArrayRange,
  Pangea.Pipeline.ExecutionPolicy,
  Pangea.Pipeline.ExecutionPolicy.Parallel,
  Pangea.Pipeline.FunctionFactory,
  Pangea.Pipeline.ListRange,
  Pangea.Pipeline.Range,
  System.Generics.Collections;

type
  TPipelineTestUtilities = class
  public
    class function CreateHomogenousRange<T>(AValue: T; ANrItems: Integer; AList: TList<T>): IRange<T>;
    class function GetAssertEqualFunc<T>(const AExpected: T): TMutateFunc<T>;
  end;

const
  NCOUNT = 100;

procedure TestForEach(const ARange: IRange<Integer>);
const
  VALUE = 55;
begin
  TPipeline<Integer>
    .Start(ARange)
    .ForEach(TFunctionFactory.GetConstantValueFunction<Integer>(VALUE))
    .ForEach(TPipelineTestUtilities.GetAssertEqualFunc<Integer>(VALUE));

  TPipeline<Integer>
    .Start(ARange)
    .ForEach(TFunctionFactory.GetConstantValueFunction<Integer>(0), ParallelExecutionPolicy)
    .ForEach(TFunctionFactory.GetConstantValueFunction<Integer>(VALUE), ParallelExecutionPolicy)
    .ForEach(TPipelineTestUtilities.GetAssertEqualFunc<Integer>(VALUE), ParallelExecutionPolicy);
end;

procedure TTestForEach.TestArray();
var
  LArray: TArray<Integer>;
  LRange: IRange<Integer>;
begin
  SetLength(LArray, NCOUNT);
  LRange := TArrayRange<Integer>.Create(LArray);
  TestForEach(LRange);
end;

procedure TTestForEach.TestList();
var
  LList: TList<Integer>;
  LRange: IRange<Integer>;
begin
  GuardMemoryOnExit(LList);
  LRange := TPipelineTestUtilities.CreateHomogenousRange<Integer>(0, NCOUNT, LList);
  TestForEach(LRange);
end;

procedure TTestMap.TestOneToOneMap();
var
  LList: TList<Integer>;
  LRange: IRange<Integer>;
  LMappedList: TList<Integer>;
  LPlus10Func: TMapFunc<Integer, Integer>;
begin
  GuardMemoryOnExit(LList, LMappedList);
  LMappedList := TList<Integer>.Create();

  LRange := TPipelineTestUtilities.CreateHomogenousRange<Integer>(0, NCOUNT, LList);

  LPlus10Func := function(const AValue: Integer): Integer
    begin
      Result := AValue + 10;
    end;

  TPipeline<Integer>
    .Start(LRange)
    .Map<Integer>(TListRange<Integer>.Create(LMappedList), LPlus10Func)
    .ForEach(TPipelineTestUtilities.GetAssertEqualFunc<Integer>(10));
end;

procedure TTestMap.TestOneToOneTypeChangeMap();
const
  VALUE = 25.5;
var
  LList: TList<Integer>;
  LMappedList: TList<Double>;
begin
  GuardMemoryOnExit(LList, LMappedList);
  LMappedList := TList<Double>.Create();

  TPipeline<Integer>
    .Start(TPipelineTestUtilities.CreateHomogenousRange<Integer>(0, NCOUNT, LList))
    .Map<Double>(TListRange<Double>.Create(LMappedList), TFunctionFactory.GetConstantValueMapFunction<Integer, Double>(VALUE))
    .ForEach(TPipelineTestUtilities.GetAssertEqualFunc<Double>(VALUE));
end;

class function TPipelineTestUtilities.CreateHomogenousRange<T>(AValue: T; ANrItems: Integer; AList: TList<T>): IRange<T>;
var
  AConstantValueFunc: TMutateFunc<T>;
begin
  GuardMemoryOnFailure(AList);
  AList := TList<T>.Create();
  AList.Count := ANrItems;
  Result := TListRange<T>.Create(AList);
  TPipeline<T>
    .Start(Result)
    .ForEach(TFunctionFactory.GetConstantValueFunction<T>(AValue));
end;

class function TPipelineTestUtilities.GetAssertEqualFunc<T>(const AExpected: T): TMutateFunc<T>;
begin
  Result := function(const AValue: T): T
    begin
      Assert.AreEqual(AExpected, AValue);
      Result := AValue;
    end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestForEach);
  TDUnitX.RegisterTestFixture(TTestMap);

end.