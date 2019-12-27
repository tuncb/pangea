unit Pangea.Pipeline.FunctionFactory;

interface

uses
  Pangea.Pipeline;

type
  TFunctionFactory = class
  public
    class function GetConstantValueFunction<T>(const AValue: T): TMutateFunc<T>;
    class function GetConstantValueMapFunction<T, R>(const AValue: R): TMapFunc<T, R>;
  end;

implementation

class function TFunctionFactory.GetConstantValueFunction<T>(const AValue: T): TMutateFunc<T>;
begin
  Result := function(const AIn: T): T
    begin
      Result := AValue;
    end;
end;

class function TFunctionFactory.GetConstantValueMapFunction<T,R>(const AValue: R): TMapFunc<T, R>;
begin
  Result := function(const AIn: T): R
    begin
      Result := AValue;
    end;
end;

end.

