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
  System.Generics.Collections,
  Pangea.MemoryGuard,
  Pangea.Pipeline,
  Pangea.Pipeline.Range,
  Pangea.Pipeline.ArrayRange,
  Pangea.Pipeline.ListRange;

const
  NCOUNT = 100;

procedure TestForEach(const ARange: IRange<Integer>);
const
  VALUE = 55;
var
  LSetFunc: TMutateFunc<Integer>;
begin
  LSetFunc := function(const AValue: Integer): Integer
    begin
      Result := VALUE;
    end;

  TPipeline<Integer>
    .Start(ARange)
    .ForEach(LSetFunc);

  ARange.Reset();
  repeat
    Assert.AreEqual(VALUE, ARange.Current);
  until ARange.MoveNext();
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