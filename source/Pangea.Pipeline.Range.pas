unit Pangea.Pipeline.Range;

interface

type
  IRange<T> = interface['{E365281B-CECC-4643-A7BF-D671821464D7}']
    function GetCurrent(): T;
    procedure SetCurrent(const AValue: T);
    function MoveNext(): Boolean;

    procedure Reset();

    property Current: T read GetCurrent write SetCurrent;
  end;

implementation



end.