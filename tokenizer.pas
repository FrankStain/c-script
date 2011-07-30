unit tokenizer;
(**
 * ������ ������������ �����������. �������� ��� ����������� ����������� ��� ��������� ������
 * ���� �� ������ ������.
 *
 * �������� ������� ������ �������� TStringTokenizer, ���� ����� ��������� ������ �
 * ���������� ������ �� �������.
 *
 *)

interface

uses
  Windows, Classes,
//--- ����������� ������ ---------------------------------------------------------------------------
  TextMessages,
//--------------------------------------------------------------------------------------------------
  SysUtils;

Type
  // ��������������� ������ �������, TToken � TStringTokenizer ��������� �������������.
  TToken = class;

  (**
   * ������������ ������� ����� ������.
   *
   *)
  TTokenType = (
    ttNone,      // ������ ���, ����������� ���������� ����
    ttUndef,     // ����������, ����������� �������
    ttMSComment, // ������� �������������� �����������, ��� : /* ... */
    ttSSComment, // ������� ������������� �����������, ��� : // ...
    ttType,      // ������� ����������� ����, int � �������
    ttKeyword,   // ������� ��������� �����, ��� for ��� while
    ttIdent,     // ������� �������������� ���������, ���������� ��� �������
    ttDigit,     // �����, ������ ���������������� �����
    ttNumINT,    // ����� �����, �������� �� ������
    ttNumFLOAT,  // ������������ �����, �� ������ � ������
    ttString,    // ������� ������, �������� � ������������� ������, ��� : " ... "
    ttSymbol     // ������, ����� ����������� ������ : . + - * >= != � ���� ��������
  );

  (**
   * ����� ������������ �����������. ��������� ������ ������� �� ������� ������ �� �������.
   * �������������� �������� ��� � ������� ����������.
   * �������� ����� ������� ������� ��� ����������� �� ����.
   * ������ � ���� �������� ���������� ������, ������� ��������� ���������
   * ����������� ��������� ������ �� ����.
   *
   *)
  TStringTokenizer = class
    Private
      (**
       * ��������� ������. ������ ������ � ������ �� ����������,
       * ����� ������������ ������������ �������� �� ������� Protected ������� �������.
       *)
      FTokens: TList;

      (**
       * ��� ���������� ��������� ��������� ���������� ������� ���������� ������ � �������.
       * ������ ��� ����� ������ ������ ����.
       * ���� �������� ������ ������������ �� ������ ������ �������.
       *)
      FCurrentIndex: integer;

    Protected
      (**
       * ����� ��� ���������� ������� � ���������. ����� ������������ ������ � ������ TToken!
       * ������������ ��� �������������� ������ �� �������������.
       * ������ TToken �������������� �������������� ���� ��� �������� � ������� ����� ������.
       *
       * ���������:
       *   oToken - �������, ������� ���������� ���������������� � ���������.
       *)
      Procedure AddToken(oToken: TToken);

      (**
       * ����� ������� ������� �� ���������. ��� �� ����� �������������� ������ � ������ TToken.
       * ������ TToken �������������� ������� ���� �� ��������� �� ����� ������ ��� �����������.
       *
       * ���������:
       *   oToken - �������, ������� ���� ������� �� ���������.
       *)
      Procedure RemoveToken(oToken: TToken);

      (**
       * ����� ������ ���������� ������ � ���������.
       * ���������� ����� � ��������� 0..32�
       *)
      Function GetCount: integer;

      (**
       * ����� �� ����������� ������� �������� �� ��������� �������.
       * �������� �������, ����� ����������� ������ ����� nil! ����� ��������, ����
       * ������ �������������� �������� ������ ����� ��������� ���������, ��� ������ ����.
       *
       * ���������:
       *   Index - ������ ������������� �������.
       *
       * ���������� ������� ��� nil, ���� ������� �������� ������
       *
       *)
      Function GetToken(Index: integer): TToken;

      (**
       * ����� ������������� ������� ������� ��� ���������� ����� ���������� �� ����.
       * ������������ ������� ������ ������� � �������� �� ������������ ��������� ���������,
       * � ������ ���������� � ���������� �������� ������������� ����� ������� ���� �������.
       *
       * ���������:
       *   sToken     - ���������� ������� �������.
       *   eStartType - ��������� ���������� ����������� ���� �������.
       *
       * ����������:
       *   ���������� ������� �����:
       *   - ttDigit -> ttNumINT | ttNumFLOAT
       *   - ttIdent -> ttIdent | ttType | ttKeyword
       *
       * ���������� ����� ��� �������.
       *
       *)
      Function GuessTokenType( sToken: string; eStartType: TTokenType ): TTokenType;

    Public
      (**
       * ����������� �������, ������ ��� ���������� ��������� ����� �������.
       *
       *)
      constructor Cerate;

      (**
       * ����������. �������� ���������� �������� ������. ������� ��� ����������� ������.
       *
       *)
      destructor Destroy; override;

      (**
       * ��������� ������� ��������� ������.
       *
       *)
      Procedure Clear;

      (**
       * ������� �� ���� ��� �����������.
       *
       *)
      Procedure ClearComments;

      (**
       * ��������� ���������������� ������� ����������� - ��������� ������ ���� �� �������.
       *
       * ���������:
       *   sStream - ����� ��������� ���� ���������.
       *
       * ���� ������ ��� �������, ���������� true, ����� - false.
       *
       *)
      Function Parse(sStream: string): boolean;

      (**
       * ���������� ��������� ���������.
       * ���������� ������� ������������� �������.
       * ����� ������� � nil, ���� ������ ��� ����� ��� ��������� ����� �����.
       *
       *)
      Function Current: TToken;

      (**
       * ���������� ��������� ���������.
       * ������������ �� ��������� ������� � ���������� �� ������� ������ Current.
       * ��� �� �������� ������� nil �� ��� �� ��������.
       *
       *)
      Function Next: TToken;

      (**
       * ���������� ��������� ���������.
       * ���������, ��������� �� ����� �����. ������ true �����, ����� ������ ������� �� ���������.
       *
       *)
      Function EOF: boolean;

      (**
       * ���������� ��������� ���������.
       * ���������� ���������� ������ �������. ����� ����� Current ������ ���������
       * �� ����� ������ �������.
       *
       *)
      Procedure Rewind;

      (**
       * �������� ���������� ����� ����� ������ � ���������.
       *
       *)
      Property Count: integer read GetCount;

      (**
       * ������� ��������� ���������� � �������� �� �� ������������ �������.
       * �������� ��������� �� ���������, ��� ��������� ������������ ������
       * ����������� ������� ������.
       *
       * ���������:
       *   Index - ������ ������������� �������.
       *
       *)
      Property Tokens[Index: integer]: TToken read GetToken; default;
  end;


  (**
   * ����� �������, ���������� ������ � ������� �����������.
   * �� ����� �������� �������������� ���� ������������ � �����������.
   * ��� �������� �������������� ������� �����������.
   * �������� � ���� ��� ������� � �� ��������, ��� �� ������ ���� �����, ����� � ���� ������.
   *
   *)
  TToken = class
    Protected
      (**
       * ������ �� ������� ������� - ����������.
       * ������ ��� ���������� � �����������/��������������, � ��� �� ���
       * ��������� ������ ����������
       *
       *)
      FOwner: TStringTokenizer;

      (**
       * ��� �������� �������, ������������ ��������, �� ����� ����
       * ������������� ������ � �����������.
       *
       *)
      FType: TTokenType;

      (**
       * �������� �������, ���������� ��� ����� �������� ���� �������.
       *
       *)
      FValue: string;

      (**
       * ���������� ����������, ���������� ������ � ����, ��� ����������� �������.
       *
       *)
      FLine: integer;

      (**
       * ���������� ����������, ���������� ����� �� ������, � ������� ���������� �������.
       *
       *)
      FSymbol: integer;

      (**
       * ���������� �������� ��������� ��� �����������.
       * ���������� ��������� �������. ����� ������� � nil, ���� ������ ������� ���������.
       *
       *)
      Function GetNext: TToken;

      (**
       * ���������� ��������� ��������� ��� �����������.
       * ���������� ���������� �������. ��� �� ����� ������� nil, ���� ������ ������� ������.
       *
       *)
      Function GetPrev: TToken;

      (**
       * ���������� ������ ������ ������� � ��������� �����������.
       *
       *)
      Function GetIndex: integer;

    Public
      (**
       * ����������� ������� �������. ���������� ����������� � �����������.
       *
       *)
      constructor Create(aOwner: TStringTokenizer);

      (**
       * ���������� �������. ������� ����������� � ����������� � ����������� ���������� ������.
       *
       *)
      destructor Destroy; override;

      (**
       * ���������� �������� �������.
       * ������ ��� ������.
       *
       *)
      Property Value: string read FValue;

      (**
       * ���������� ��� �������.
       * ������ ��� ������.
       *
       *)
      Property TokenType: TTokenType read FType;

      (**
       * ���������� ������ ������ �������.
       * ������ ��� ������.
       *
       *)
      Property Line: integer read FLine;

      (**
       * ���������� ����� ������ �������.
       * ������ ��� ������.
       *
       *)
      Property Symbol: integer read FSymbol;

      (**
       * ���������� ��������� �������, ����� ������� � nil.
       * ������ ��� ������.
       *
       *)
      Property Next: TToken read GetNext;

      (**
       * ���������� ������ ������� � ��������� �����������.
       * ������ ��� ������.
       *
       *)
      Property Index: integer read GetIndex;

      (**
       * ���������� ���������� �������. ����� ������� � nil.
       * ������ ��� ������.
       *
       *)
      Property Prev: TToken read GetPrev;
  end;

const

  // �������� ���������� �������� ����� � ������� CA_TYPES
  CI_TYPESCOUNT: integer = 3;

  // �������� ����� ��������� �������� �����, ������ ��� ������������� �������.
  CA_TYPES: array [1..3] of string = (
    'int', 'float', 'bool'
  );

  // �������� ���������� ��������� �������� ���� � ������� CA_KEYWORDS
  CI_KEYWORDCOUNT: integer = 15;

  // �������� ����� ��������� �������� �������� ����, ������ ��� ������������� �������.
  CA_KEYWORDS: array [1..15] of string = (
    'int', 'float', 'bool', 'true', 'false', 'for', 'while', 'do', 'if', 'else',
    'const', 'return', 'continue', 'break', 'echo'
  );

  (**
   * ������� ����������� ����� ������ ��� �������, �� ������, ���� ��������� ������ ������������.
   *
   * ��������� ���� ������� ������, � �������, " int 25; " ����� ��������� ������ ��� ������, �.�.
   * ����� ��������� � ������� � ��������� � ������ ���� ��� � ��������������, ����� � ��������.
   *
   * ��� �� ��������� ���� ������� ����� ����������� ����� ����� ����������, � �� ������������
   * �� ����� ������ �� ��� ������ ���������.
   *
   * ����������:
   *   ����������� ���������� -- ��� ������ �����, ��� ���� ���������.
   *)
  CA_PRIORITIES: array [TTokenType] of byte = (
  //ttNone  ttUndef  ttMSComment  ttSSComment  ttType  ttKeyword  ttIdent  ttDigit  ttNumINT  ttNumFLOAT  ttString  ttSymbol
    255,    100,     10,          10,          100,    100,       100,     100,     100,      100,        50,       100
  );

implementation
//--- TStringTokenizer -----------------------------------------------------------------------------

(**
 * ����������� ������� �����������.
 *
 *)
constructor TStringTokenizer.Cerate;
begin
  // ������� ��������� ������, ��� ���� ���� ������ ������.
  FTokens := TList.Create;
  // ������ ����� ���������, �� ������ ������.
  Rewind;
end;

(**
 * ���������� ������� �����������.
 *
 *)
destructor TStringTokenizer.Destroy;
begin
  // ������� ���������, ��� ������������ ������.
  Clear;
  // ������� ���������, ������ ������ ������� ��� ����������� ������.
  FTokens.Free;
  // �������� ���������� ������������� �������.
  inherited;
end;

(**
 * ����� ������� ���������.
 *
 * ������:
 *   ������� ���� ������ �� ����� ������������ � ���������. ����� ���������� ������
 *   �������� ����������� ������, ��������� �� ��������� ��� ����� ����.
 *
 *)
Procedure TStringTokenizer.Clear;
begin
  // ���� � ��������� ���� �������, ����� ������� ����� ������ �������.
  while FTokens.Count > 0 do TToken(FTokens.Items[0]).Free;
end;

(**
 * ����� ������� ���� �� ������������.
 *
 * ������:
 *   ������� ��������� ���������� ������ ������� ���������, ������ ������
 *   ��������� ���� ������������ �������, � ������������� ������.
 *
 *)
Procedure TStringTokenizer.ClearComments;
var
  // ������� �� ���������
  iWalk: integer;
begin
  // ���������� �������
  iWalk := 0;

  // ����� ��������� ��� �������� ���������
  while iWalk < FTokens.Count do begin
    if TToken(FTokens.Items[iWalk]).TokenType in [ttSSComment, ttMSComment] then begin
      // ���� ������ ������� �������� ������������, ������� ��
      // ������ ������, �������, ������� �������� ���� �� ���������, ��� ��������
      // � ���������� ������ ����� ������ � ���������.
      // ����� ������� � ������ �������� ������� �� ����� ����������� �������.
      TToken(FTokens.Items[iWalk]).Free;

      // ����� ������ ��������� � ���������� ��������.
    end else inc( iWalk );
  end;
end;

(**
 * ����������� ������� � ���������
 *
 *)
Procedure TStringTokenizer.AddToken(oToken: TToken);
begin
  FTokens.Add(oToken);
end;

(**
 * ������ ������� � �����������
 *
 *)
Procedure TStringTokenizer.RemoveToken(oToken: TToken);
begin
  FTokens.Remove(oToken);
end;

(**
 * ����������� ���������� ������ � ���������
 *
 *)
Function TStringTokenizer.GetCount: integer;
begin
  Result := FTokens.Count;
end;

(**
 * ����������� ������� �� �� ������� � ���������.
 *
 *)
Function TStringTokenizer.GetToken(Index: integer): TToken;
begin
  // ���� ������ �������� � �������� ���������� ��� ���������, ���������� �������
  if (Index >= 0) or (Index < FTokens.Count) then Result := TToken(FTokens.Items[Index])
  // ����� ���������� nil.
  else Result := nil;
end;

(**
 * ������������ ������ ���� �������, ������ ������� �������������� ��� �������.
 *
 *)
Function TStringTokenizer.GuessTokenType( sToken: string; eStartType: TTokenType ): TTokenType;
var
  // ������������� �������, ����� ��� ������������
  iWalk: integer;
begin
  // ������ ������ �������, ��� �����, ����� �� ��� ����������
  Result := eStartType;
  // ������� ���������� ��� ������ ��� �����������, �� � ������������ ������ ������, ��� ��� � ����.
  if Result in [ttString, ttSSComment, ttMSComment] then exit;

  // ����� �������
  iWalk := 1;
  // �������, ���� ����� ������� �������� ��������������� ����?
  while iWalk <= CI_TYPESCOUNT do begin
    if CA_TYPES[iWalk] = sToken then begin
      Result := ttType;
      break;
    end;
    inc(iWalk);
  end;
  // ���� ���, �� ���������������
  if Result <> eStartType then exit;

  // ����� ���������� �������
  iWalk := 1;
  // ���������, �������� ��� ������� �������� �������� ������?
  while iWalk <= CI_KEYWORDCOUNT do begin
    if CA_KEYWORDS[iWalk] = sToken then begin
      Result := ttKeyword;
      break;
    end;
    inc(iWalk);
  end;
  // ��������� ������, ���� ������� ���������� ���
  if Result <> eStartType then exit;

  // ���� ������� �������� ������, ����� ���������� ��� �����
  if Result = ttDigit then begin
    Result := ttNumINT;
    // ������������ ��� ������ �� ������� ����������� ���������� �����.
    if Pos('.', sToken) > 0 then Result := ttNumFLOAT;
  end;

end;


(**
 * ������ ��������� ���� � �������� ������ ������.
 *
 * ���������:
 *   sStream - �������� ���, ������� � �������� �������.
 *
 *   ���������� true � ������ �������� �������, false � ������ ����� ���� ������ ��� �������.
 *
 * ������:
 *   ��� �������� ����������� ��������� ���� ����� ��������� �� ��� ������� ����:
 *   - ������� : + - * / % �.�.�...
 *   - ����� : �� 0 �� 9
 *   - ����� : ������� � ���������, ���������, �������, ��������, � ����� ����� �����
 *
 *   �� ���� ��������� �������� ������� ������� �����, ������� ����� �������� �� ������ ���
 *   ���������� ���������. ��� ��� � �������� ������� ���� ����� ����������� ���� � �� �� ��������,
 *   ��� ������ ����� ����� ���� ������������� �����, ����� ���� � ���� � �������� ��������������, � �.�.
 *
 *   ��� ������� �� �������� ���:
 *   - ���������� ��� ������� ������� ��������������� ��� ttNone, ������ ���� ���������� � ������� ��������
 *   - ������������� ������� ������� � �� ��� ������ �������� ����� � ���� ������� �������
 *   - ������� ��������������� �� ���������� ���������, �� �� ��������� ��������� �� ����
 *     � �������, ��� ��� ������������������ �������� ������ ��������.
 *   - ����� ��� �������� �������� ����������, �� ������ ������������ ������������� ������� � ���������,
 *     ������ ��� ������ ������� �� ��������� � ����������� ��� ������.
 *
 *   ��� ����� ������ � ����������� ������ ������� ���� �� �������, �� �� �� ��������� ���������
 *   ��������� �������, ����� �������� ������� ���� ���������� ������ �������.
 *   � ���� �����, ������ �������� ����� ������� ��������� �������� ����� ������, ������� ������� -
 *   ���������� ��� ������ ����������.
 *   ���������, � �������, ��� ���������� ����� � ����� ������� �����������, ����� ����������� ������
 *   ����������� ��� �������� ����� ��������� ��� ������, ���� �� ����� ��������� ����������� �����
 *   �����������.
 *   ������ �� ���������� ����� ��������� ������. ��������� ����� ������� ����������, ������
 *   ������������� � ����������� ����� ��������� ��� ��� �����. � �. �.
 *
 *   ��������� ��������� ����������� ����� ������������ ����� ������� ������� ����������� ���� �������,
 *   � �������������, ���������� ����� � ����� ��������� ��� �� ������� � ���������� ������ �� ����������.
 *   ����� ������� ���������� ������� ������ �������� ���������� � ������ ����������� ����������.
 *
 *)
Function TStringTokenizer.Parse(sStream: string): boolean;
var
  // ������������� �����, ��� ������� ���� ��������� ��� �������
  sCurrentBlock: string;
  // ������������� �����, ������ ���������� ������ ��� ����� � ������������� ������������
  sStringBlock: string;
  // ������� ������ ������, �������� ������ �������� �������� (char - �������) � ������ �������
  iBlockWalker: integer;
  // ���������� ������ �������, ��������������� ����� �������� ������ ��������� �������
  iTokenStart: integer;
  // ���������� ������� ������ ������� � �������� ����
  iLinePos: integer;
  // ���������� �������� �������� � �������� ���� � ������ ������� ������
  iCharPos: integer;
  // ���������� ������ ������ ������������ � ������ ������ �������
  iStartLine: integer;
  // ���������� �������� ������ (�� ������) �������� ������������ �������
  iStartChar: integer;
  // ����������������� ��� �������� ������������ �������
  eCurrentType: TTokenType;
  // ������ �� ��������� ������������������ ������
  oToken: TToken;
  // ������ ��� ���������� �������� ��������� ��������� ������� ���� "������"
  bBreakStep: boolean;

  // ����������� ����������, ������������ ������� �������
  Procedure AppendToken(sTValue: string; eTType: TTokenType = ttNone);
  begin
    // ���������� ��� ������� �������, ���� �� �� ��� ������ ����������
    if eTType = ttNone then eTType := eCurrentType;

    oToken := TToken.Create(Self);
    oToken.FValue := sTValue;
    oToken.FType := GuessTokenType(sTValue, eTType);
    oToken.FLine := iStartLine;
    oToken.FSymbol := iStartChar;
  end;

begin
  // ����� ������� - ������� �������� �������� ������� �� ���� (������ 0x10).
  sStream := StringReplace(sStream,#10,'',[rfReplaceAll]);
  // ������� ����� - 1, ������� ������ ���� - 1, ��������� ������� ������� - ���� 1
  iLinePos := 1;
  iCharPos := 1;
  iStartLine := 1;
  iStartChar := 1;
  // ������� ������ �� �����������, �������� ��������
  oToken := nil;
  // ��� ������� ������� ��������� ��� �����������
  eCurrentType := ttNone;

  // ���� � ���� �������� ��������, ���������� ������
  while length(sStream) > 0 do begin
    // � ����� ����� ����������� ��� �������� �� ������� �������
    sCurrentBlock := copy(sStream, 1, pos(' ',sStream));
    if length(sCurrentBlock) > 0 then
      // ������������� � ����� �������� ���� ������� �� ����
      delete(sStream, 1, length(sCurrentBlock))
    else
    begin
      // ����� ����������, ��� �������� � ���� ������ ��� � � ����� ������ �� �������������
      // � ���� ������ �������� � ����� �� ��� ���� � ���������� ���������� ����
      sCurrentBlock := sStream;
      sStream := '';
    end;

    // ���������� ������� �������
    iBlockWalker := 1;
    iTokenStart := 1;

    // ������ � ����������� ����� ��������� �������, ������� ��� ������� ������������
    // ������ ���� ��� �� ������ � �� �����������
    if not(eCurrentType in [ttString, ttSSComment, ttMSComment]) then eCurrentType := ttNone;

    // �������� �� ������� ������� ������
    while iBlockWalker <= length(sCurrentBlock) do
    begin
      // ��������� ������� � ���� ������� �������� �� ������ ������������ � ������ �������
      case sCurrentBlock[iBlockWalker] of
        '"': begin // ���������� ������ ������ ��� ����� ������

          // ����� ������� - ������ ������ �������� ����������� ����� ����������� ��������
          // � ������� ����������� ��������, ���� �� ������� ������ ���� ������������ �������.
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttString] then
          begin

            // ���� ������� ����� ����������� � � ����� ������, ���� �������� ����� ���� �� ��������
            // ����� ������, ����� "������������" ��� ����. ��������� ����� ��� ������ "\".
            // ������ ������������� ��� � �����������.
            bBreakStep := false;
            if (eCurrentType = ttString) and (iBlockWalker > 1) then
            begin
              // ���� ��� �� ������ ������ ������ � ���������� ������ �������� ������������,
              // ������ �����, ��� ������ ������ ������� �� �������� ��������� ����� ������.
              if sCurrentBlock[iBlockWalker-1] = '\' then bBreakStep := true;
            end;


            // ��������� ������ ������ ���� ������� ������ �������������
            if not bBreakStep then
            begin
              if eCurrentType <> ttString then
              begin
                if (eCurrentType <> ttNone) then
                begin
                  // ���� ���������������� ��� ����������� �������, ���� ������� ���� � ��� ���� �� ������
                  AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                end;
                // ������ ��������� ������� ���, ���� ���� �������, ������ �� ��������� ������
                eCurrentType := ttString;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
                sStringBlock := '';
              end
               else begin
                // ��������� ��������� ������, �.�. ��������� �������� �� �����

                // �������� ������ �� ������
                sStringBlock := StringReplace(sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart + 1), '\"', '"', [rfReplaceAll]);
                // ������������ �������
                AppendToken(copy(sStringBlock, 2, length(sStringBlock) - 2), ttString);

                // ���������� ��� �������� �������
                eCurrentType := ttNone;
              end;
            end;
          end;
        end;

        #13: begin // ������ ����� ������ ������ ������������� � ����� �������
          // ���������� �� ��� �� ��������� ������ ��������� ����, �� ������ �� �������
          inc(iLinePos);
          iCharPos := 0;

          // ���� ���������������� ����������� ������, ���� ������ ��� �� ������ � �� �����������
          if not (eCurrentType in [ttNone, ttString, ttMSComment]) then
          begin
            if eCurrentType in [ttSSComment] then
              // ������� ��������� ������������� ����������� - ������ ������� ����� ������, ���� ������� �����
              AppendToken(copy(sStringBlock, 3, length(sStringBlock) - 2) + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart))
            else
              AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
            // ���������� ��� ���������������� �������
            eCurrentType := ttNone;
          end;

          // �������� ��������� ������������������ �������
          oToken := nil;
        end;

        #9,' ': if not (eCurrentType in [ttNone, ttString, ttSSComment, ttMSComment]) then begin
          // ������ ��� ������ ��������� ����� ������������� � ���������� ������� �������
          // ���� ������ ��� �� ����������� � �� ������
          // ������������ �������
          AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
          // ���������� ��� �������
          eCurrentType := ttNone;
        end;

        'a'..'z','A'..'Z','_': begin // ������� ������� ���������������
          // �������� �����������...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttIdent] then begin
            if eCurrentType <> ttIdent then
            begin
              // ���� ���� ����������� �������, ���� �� ����������������
              if eCurrentType <> ttNone then AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              // � ����� ���� ������ ������� ������� ������� ��������������
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttIdent;
            end;
          end;
        end;

        '0'..'9': begin // ������� ������� �����
          // ������������ �������� �����������...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttDigit] then
          begin
            if eCurrentType = ttNone then
            begin
              // �������� ��������� �����, ���� ������ ��� �� ���� ���������
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttDigit;
            end
            else
            if not (eCurrentType in [ttDigit, ttIdent]) then
            begin
              //���� ��� ����������� ������������� ��� �����, ���� �� �������

              if (eCurrentType = ttSymbol) and (sCurrentBlock[iBlockWalker - 1] in ['+','-']) and (oToken <> nil) then
              begin
                // ��� ������ �������� �����, ���� ����� ������ ���� ����,
                // �� �������� ��� ���� �����, � �� �������� ��� ���
                if not(oToken.TokenType in [ttDigit, ttIdent, ttNumINT, ttNumFLOAT]) then
                begin
                  // ������� ��� ������� - ������, ��� ����� ������ + ��� - � ����� �������
                  // �� ����� �������, ������ ����� ��������� ����� � �����, ���������� ������
                  // ������� ��� �������
                  eCurrentType := ttDigit;
                end
                else
                begin
                  // ������������ ��� ����������� �������
                  AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                  // ������ ������ ������� �����
                  iTokenStart := iBlockWalker;
                  iStartLine := iLinePos;
                  iStartChar := iCharPos;
                  eCurrentType := ttDigit;
                end;
              end
              else
              begin
                // ������������ ����������� �������
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                // ������ ������ ������� �����
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
                eCurrentType := ttDigit;
              end;
            end;
          end;
        end;

        '.': begin // ������ ����� �������������� �������� �� ���� ��������
          // ����������� �������� ����������...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then
          begin
            // ���������� ���� ������� ����� � ������, ���� ��������� ����������� ��� � ��� ��������
            if not(eCurrentType in [ttString, ttDigit]) then
            begin
              if eCurrentType <> ttNone then begin
                // ���� ���� ����������� �������, ������������ ��
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              end;
              // ���������� ��������� ������� ������
              eCurrentType := ttNone;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              // ������������ ������ �����
              AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
            end;
          end;
        end;

        '/': begin // ���� ����� �������� ������ �����������, � ����� � �������� �������...
          // ������ �������� �����������
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then begin

            if not (eCurrentType in [ttString]) then
            begin
              if eCurrentType <> ttNone then begin
                // ���� �� ����� ������� ���������� ����� �� ������ �������, ���� �� ����������������
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              end;

              // ���� ��� �� ����� ���������� ������ � �����...
              if 0 < (length(sCurrentBlock) - iBlockWalker) then
              begin
                case sCurrentBlock[iBlockWalker + 1] of
                  '/': begin
                    // ��� ����� - �������� ������ ������������� �����������
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                    eCurrentType := ttSSComment;
                  end;
                  '*': begin
                    // ���� � ������ - ������ �������������� �����������
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                    eCurrentType := ttMSComment;
                  end;
                  else begin
                    // � ���� ��� ��������, �� ��� ������ ���� �������
                    eCurrentType := ttNone;
                    AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
                  end;
                end;
              end else begin
                // � ���� ���������, �� ������������ ��� ��� ������ �������
                eCurrentType := ttNone;
                AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
              end;
            end;
          end
          else
          case eCurrentType of
            // ���������� ����� �������� ������ � ������������,
            // ����� �������������� ����� �������������� �����������
            ttMSComment: begin
              // ��������, �� ����� �� ��������� ����� ������� ���������? �������� �� ... */
              if (iBlockWalker > 1) and (sCurrentBlock[iBlockWalker - 1] = '*') then begin
                // �������� ����������� ����������� ������ � ������������ ���
                sStringBlock := sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart - 1);
                AppendToken(copy(sStringBlock, 3, length(sStringBlock) - 2));
                // � ����� ���������� ��������� �������
                eCurrentType := ttNone;
              end;
            end;
          end;
        end;

        '+','-','>','<','!','=','*','(',')',',',';','{','}','&','|','^','%':
        begin // ������� ������� ��������
          // ��������� ����������
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then
          begin
            case eCurrentType of
              ttNone:
              begin
                // �������� ��������� ����� ������, ���� ������ ��� �� ���������
                eCurrentType := ttSymbol;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
              end;
              ttSymbol:
              begin
                // � ���� ��� ���� ��������� ������, �� �������� ��� ���� ����������������
                case sCurrentBlock[iBlockWalker - 1] of
                  '>','<','!','=':
                  begin
                    // ���� ������ ����� ���� � �� ������ ���������, >= � �������
                    // ��� � ����������� ������� ������ �����
                    if sCurrentBlock[iBlockWalker] <> '=' then
                    begin
                      // ���� ��� ���, �� ������������ ������� ������ � ��������� � ��������
                      AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                      eCurrentType := ttSymbol;
                      iTokenStart := iBlockWalker;
                      iStartLine := iLinePos;
                      iStartChar := iCharPos;
                    end;
                  end;

                  else
                  begin
                    // ������������ ��� ���������� ������ � ��������� � ��������
                    AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                    eCurrentType := ttSymbol;
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                  end;
                end;
              end;

              else begin
                // ������������ ��� ���������� ������ � ��������� � ��������
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                eCurrentType := ttSymbol;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
              end;
            end;
          end;
        end;

        else begin // ����� ��� ����������, ��� � ���� �������� ����� ������ ������ �� �� ���� ���������
          // �� ���� �� ������ �� ��� ������ ���� ������ ����������
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttUndef] then
          begin
            // ������ ������������ ������� �������� ��� ����������� �������
            if eCurrentType = ttNone then
            begin
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttUndef;
            end
            else
            if eCurrentType <> ttUndef then
            begin
              // �� �������� �������������� ����� ������������� �������
              AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttUndef;
            end;
          end;
        end;
      end;
      // ���������� ������ �� ������
      inc(iBlockWalker);
      inc(iCharPos);
    end;

    // ��������� ���� ��� ����� � ������������, ���� ������� ����������� � ������ �����
    if eCurrentType in [ttString, ttSSComment, ttMSComment] then
      sStringBlock := sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart + 1)
    else
      // ����� ������ ����������� ���, ���� �� �������� ������ ���
      sStringBlock := '';

    // ���� ��� �������� �� ������, �� �����������, �� ��� �� �����������, ������������ ��� ��� �������
    if not (eCurrentType in [ttNone, ttString, ttSSComment, ttMSComment]) then begin
      AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
    end;
  end;

  // ���������� ��������
  Rewind;
  Result := true;
end;

(**
 * ��� ���������.
 * ���������� ������� ������������ �������
 *
 *)
Function TStringTokenizer.Current: TToken;
begin
  // ���� ��� ����� ������, ���������� nil, ����� - ������� �� ������������� �������
  if EOF then Result := nil
  else Result := TToken(FTokens.Items[FCurrentIndex]);
end;

(**
 * ��� ��������.
 * �������� ������������ ������ ������ � ���������� ����� ������� �������
 *
 *)
Function TStringTokenizer.Next: TToken;
begin
  // �������� ������ ������ ���� �� ������ ����������� ���������
  if FTokens.Count > FCurrentIndex then inc(FCurrentIndex);
  // ���� ��������� �����, ���������� nil, ����� - ������� �� ������ �������
  if EOF then Result := nil
  else Result := TToken(FTokens.Items[FCurrentIndex]);
end;

(**
 * ��� ���������.
 * �������� �� ���������� ���������� �������� ���������
 *
 *)
Function TStringTokenizer.EOF: boolean;
begin
  Result := FCurrentIndex >= FTokens.Count;
end;

(**
 * ��� ���������.
 * ����� ����������� ������������� �������
 *
 *)
Procedure TStringTokenizer.Rewind;
begin
  FCurrentIndex := 0;
end;
//--------------------------------------------------------------------------------------------------
//--- TToken ---------------------------------------------------------------------------------------

(**
 * ����������� ������� �������.
 *
 *)
constructor TToken.Create(aOwner: TStringTokenizer);
begin
  FOwner := aOwner;
  // � ��� � ��������� ����������� � ��������� �������.
  FOwner.AddToken(Self);
  // ��������� ���� ������������
  FLine := 0;
  FSymbol := 0;
end;

(**
 * ���������� �������
 *
 *)
destructor TToken.Destroy;
begin
  // ������ ��������� � �����������
  FOwner.RemoveToken(Self);
  // ����� ������������ ���������
  inherited;
end;

(**
 * ���������� ���������.
 * ���������� ��������� �� ������� �������
 *
 *)
Function TToken.GetNext: TToken; 
begin
  Result := FOwner.GetToken(FOwner.FTokens.IndexOf(Self)+1);
end;

(**
 * ���������� ���������.
 * ���������� ���������� �� ������� �������
 *
 *)
Function TToken.GetPrev: TToken;
begin
  Result := FOwner.GetToken(FOwner.FTokens.IndexOf(Self)-1);
end;

(**
 * ���������� ���������.
 * ���������� ������ ������ ������� � ��������� �������
 *
 *)
Function TToken.GetIndex: integer;
begin
  Result := FOwner.FTokens.IndexOf(Self);
end;
//--------------------------------------------------------------------------------------------------
end.
