unit Pangea.Span;

interface

type
  TSpan<T> = record
  strict private
    FStart: ^T;
    FCount: Integer;

    function GetValue(const AIndex: Integer): T;
    procedure SetValue(const AIndex: Integer; const AValue: T);
  public
    class operator Explicit(const AArray: array of T): TSpan<T>;

    property Items[const AIndex: Integer]: T read GetValue write SetValue;
    property Count: Integer read FCount;
  end;

implementation

function TSpan<T>.GetValue(const AIndex: Integer): T;
begin
  Result := (FStart + AIndex)^;
end;

procedure TSpan<T>.SetValue(const AIndex: Integer; const AValue: T);
begin
  (FStart + AIndex)^ := AValue;
end;

class operator TSpan<T>.Explicit(const AArray: array of T): TSpan<T>;
begin
  Result.FCount := Length(AArray);
  if (Result.FCount = 0)
    raise Exception.Create('');
end;

end.
