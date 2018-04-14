unit TestAlgorithm;

interface

uses
  DUnitX.TestFramework,
  Pangea.Algorithm;

type
  TTestAlgorithm = class
  public
    [Test]
    procedure Test();
  end;

implementation

uses
  System.Generics.Collections,
  System.SysUtils;

procedure TTestAlgorithm.Test();
var
  LList: TList<Integer>;
  LTimesTen: TProc<Integer>;
begin
  LList.Add(1);
  LList.Add(2);

  LTimesTen := procedure(var AVal: Integer)
    begin
      AVal := AVal * 10;
    end;

  LList := TList<Integer>.Create();
  try
    TRange<Integer>(LList).ForEach(LTimesTen);
  finally
    FreeAndNil(LList);
  end;

end;

initialization
  TDUnitX.RegisterTestFixture(TTestAlgorithm);

end.
