unit Pangea.Tuple;

interface

type
  TTuple<T1, T2> = record
  public
    Value1: T1;
    Value2: T2;

    constructor Create(const AValue1: T1; const AValue2: T2);
    procedure Unpack(out AValue1: T1; out AValue2: T2);
  end;

type
  TTuple<T1, T2, T3> = record
  public
    Value1: T1;
    Value2: T2;
    Value3: T3;

    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3);
    procedure Unpack(out AValue1: T1; out AValue2: T2; out AValue3: T3);
  end;

type
  TTuple<T1, T2, T3, T4> = record
  public
    Value1: T1;
    Value2: T2;
    Value3: T3;
    Value4: T4;

    constructor Create(const AValue1: T1; const AValue2: T2; const AValue3: T3; const AValue4: T4);
    procedure Unpack(out AValue1: T1; out AValue2: T2; out AValue3: T3; out AValue4: T4);
  end;

implementation

constructor TTuple<T1,T2>.Create(const AValue1: T1; const AValue2: T2);
begin
  Value1 := AValue1;
  Value2 := AValue2;
end;

procedure TTuple<T1,T2>.Unpack(out AValue1: T1; out AValue2: T2);
begin
  AValue1 := Value1;
  AValue2 := Value2;
end;

constructor TTuple<T1,T2,T3>.Create(const AValue1: T1; const AValue2: T2; const AValue3: T3);
begin
  Value1 := AValue1;
  Value2 := AValue2;  
  Value3 := AValue3;  
end;

procedure TTuple<T1,T2,T3>.Unpack(out AValue1: T1; out AValue2: T2; out AValue3: T3);
begin
  AValue1 := Value1;
  AValue2 := Value2;  
  AValue3 := Value3;  
end;

constructor TTuple<T1,T2,T3,T4>.Create(const AValue1: T1; const AValue2: T2; const AValue3: T3; const AValue4: T4);
begin
  Value1 := AValue1;
  Value2 := AValue2; 
  Value3 := AValue3; 
  Value4 := AValue4;   
end;

procedure TTuple<T1,T2,T3,T4>.Unpack(out AValue1: T1; out AValue2: T2; out AValue3: T3; out AValue4: T4);
begin
  AValue1 := Value1;
  AValue2 := Value2;  
  AValue3 := Value3;  
  AValue4 := Value4;  
end;

end.
