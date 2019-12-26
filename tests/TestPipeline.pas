unit TestPipeline;

interface

uses
  DUnitX.TestFramework;

type
  TTestForEach = class
  strict private
  public
    [Test]
    procedure TestArray();
    [Test]
    procedure TestList();
  end;

implementation

uses
  Pangea.MemoryGuard,
  Pangea.Pipeline,
  Pangea.Pipeline.ArrayRange,
  Pangea.Pipeline.ExecutionPolicy.Parallel,
  Pangea.Pipeline.ListRange,
  Pangea.Pipeline.Range,
  System.Generics.Collections;

const
  NCOUNT = 100;

procedure TestForEach(const ARange: IRange<Integer>);
const
  VALUE = 55;
var
  LSetFunc, LCheckValueFunc: TMutateFunc<Integer>;
begin
  LSetFunc := function(const AValue: Integer): Integer
    begin
      Result := VALUE;
    end;

  LCheckValueFunc := function(const AValue: Integer): Integer
    begin
      Assert.AreEqual(VALUE, AValue);
      Result := AValue;
    end;

  TPipeline<Integer>
    .Start(ARange)
    .ForEach(LSetFunc)
    .ForEach(LCheckValueFunc);

  TPipeline<Integer>
  .Start(ARange)
  .ForEach(function(const AValue: Integer): Integer
    begin
      Result := 0;
    end);

  TPipeline<Integer>
    .Start(ARange)
    .ForEach(LSetFunc, TParallelExecutionPolicy.Create())
    .ForEach(LCheckValueFunc, TParallelExecutionPolicy.Create());
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
  LList := TList<Integer>.Create();
  LList.Count := NCOUNT;

  LRange := TListRange<Integer>.Create(LList);
  TestForEach(LRange);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestForEach);

end.