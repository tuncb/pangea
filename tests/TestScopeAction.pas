unit TestScopeAction;

interface

uses
  DUnitX.TestFramework,
  Pangea.ScopeAction;

type
  TTestScopeAction = class
  public
    [Test]
    procedure TestDoOnScopeExit();
    [Test]
    procedure TestDoOnScopeSuccess();
    [Test]
    procedure TestDoOnScopeFailure();
  end;

implementation

uses
  System.SysUtils;

type
  TWrapper<T> = class(TObject)
  strict private
    FValue: T;
  public
    constructor Create(const AValue: T);

    property Value: T read FValue write FValue;
  end;

constructor TWrapper<T>.Create(const AValue: T);
begin
  FValue := AValue;
end;

procedure MultiplyByTwoOnScopeExit(AWrapper: TWrapper<Integer>;
  const ADoBeforeChange: TProc<IScopeAction>);
var
  LAction: IScopeAction;
begin
  LAction := DoOnScopeExit(procedure()
    begin
      AWrapper.Value := AWrapper.Value * 2;
    end);
  ADoBeforeChange(LAction);
end;

procedure MultiplyByTwoOnScopeSuccess(AWrapper: TWrapper<Integer>;
  const ADoBeforeChange: TProc<IScopeAction>);
var
  LAction: IScopeAction;
begin
  LAction := DoOnScopeSuccess(procedure()
    begin
      AWrapper.Value := AWrapper.Value * 2;
    end);

  ADoBeforeChange(LAction);
end;

procedure MultiplyByTwoOnScopeFailure(AWrapper: TWrapper<Integer>;
  const ADoBeforeChange: TProc<IScopeAction>);
var
  LAction: IScopeAction;
begin
  LAction := DoOnScopeFailure(procedure()
    begin
      AWrapper.Value := AWrapper.Value * 2;
    end);

  ADoBeforeChange(LAction);
end;

procedure TTestScopeAction.TestDoOnScopeExit();
const
  VAL = 10;
var
  LWrapper: TWrapper<Integer>;
begin
  LWrapper := TWrapper<Integer>.Create(VAL);
  try
    MultiplyByTwoOnScopeExit(LWrapper, procedure(AAction: IScopeAction) begin end);
    Assert.AreEqual(LWrapper.Value, VAL * 2);

    LWrapper.Value := VAL;
    MultiplyByTwoOnScopeExit(LWrapper, procedure(AAction: IScopeAction)
      begin
        AAction.Cancel();
      end);
    Assert.AreEqual(LWrapper.Value, VAL);
  finally
    FreeAndNil(LWrapper);
  end;
end;

procedure TTestScopeAction.TestDoOnScopeSuccess();
const
  VAL = 10;
var
  LWrapper: TWrapper<Integer>;
begin
  LWrapper := TWrapper<Integer>.Create(VAL);
  try
    LWrapper.Value := VAL;
    MultiplyByTwoOnScopeSuccess(LWrapper, procedure(AAction: IScopeAction) begin end);
    Assert.AreEqual(LWrapper.Value, VAL * 2);

    try
      LWrapper.Value := VAL;
      MultiplyByTwoOnScopeSuccess(LWrapper, procedure(AAction: IScopeAction)
        begin
          raise Exception.Create('Dummy Exception');
        end);
    except
      Assert.AreEqual(LWrapper.Value, VAL);
    end;

  finally
    FreeAndNil(LWrapper);
  end;
end;

procedure TTestScopeAction.TestDoOnScopeFailure();
const
  VAL = 10;
var
  LWrapper: TWrapper<Integer>;
begin
  LWrapper := TWrapper<Integer>.Create(VAL);
  try
    LWrapper.Value := VAL;
    MultiplyByTwoOnScopeFailure(LWrapper, procedure(AAction: IScopeAction) begin end);
    Assert.AreEqual(LWrapper.Value, VAL);

    try
      LWrapper.Value := VAL;
      MultiplyByTwoOnScopeFailure(LWrapper, procedure(AAction: IScopeAction)
        begin
          raise Exception.Create('Dummy Exception');
        end);
    except
      Assert.AreEqual(LWrapper.Value, VAL * 2);
    end;

  finally
    FreeAndNil(LWrapper);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestScopeAction);

end.
