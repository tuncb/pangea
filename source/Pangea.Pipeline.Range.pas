unit Pangea.Pipeline.Range;

interface

const
  INVALID_INDEX = -1;

type
  IRange<T> = interface['{E365281B-CECC-4643-A7BF-D671821464D7}']
    function GetInclusiveStart(): Integer;
    function GetInclusiveEnd(): Integer;

    function GetValue(const AIndex: Integer): T;
    procedure SetValue(const AIndex: Integer; const AValue: T);

    procedure Resize(const AInclusiveEnd: Integer);

    property Values[const AIndex: Integer]: T read GetValue write SetValue; default;
  end;

implementation

end.