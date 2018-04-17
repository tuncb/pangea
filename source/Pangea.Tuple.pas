unit Pangea.Tuple;

interface

type
  TIgnore = record
  end;

type
  TTuple<T1, T2> = record
  public
    Value1: T1;
    Value2: T2;

    constructor Create(const AValue1: T1; const AValue2: T2);

    procedure Unpack(out AValue1: T1; out AValue2: T2);
    procedure Unpack(const AValue1: TIgnore; out AValue2: T2);
    procedure Unpack(out AValue1: T1; const AValue2: TIgnore);
  end;

const
  IGNORE: TIgnore = ();

implementation

end.
