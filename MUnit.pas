unit MUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//--------------------------------------------------------------------------------------------------
  AboutUnit, tokenizer, processor, operators, TextMessages,
//--------------------------------------------------------------------------------------------------
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls, Menus, ImgList;

type
  TMForm = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    PMsgHost: TPanel;
    MsgHeader: TPanel;
    CodeText: TMemo;
    ToolbarImages: TImageList;
    TBNew: TToolButton;
    TBOpen: TToolButton;
    TBSave: TToolButton;
    ToolButton5: TToolButton;
    TBStart: TToolButton;
    TBStop: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    HelpPopup: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ShowAbout: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    LBMessages: TListBox;
    PCWorkarea: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    MConsole: TMemo;
    procedure ClickResizer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowAboutClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TBNewClick(Sender: TObject);
    procedure TBOpenClick(Sender: TObject);
    procedure TBSaveClick(Sender: TObject);
    procedure CodeTextKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBStartClick(Sender: TObject);
    procedure TBStopClick(Sender: TObject);
    procedure CodeTextChange(Sender: TObject);
    procedure CodeTextClick(Sender: TObject);
  private
    sOpenedFile: string;
    bNewFile: boolean;
    bFileSaved: boolean;
    bInProcess: boolean;

    FTokenizer: TStringTokenizer;
    FProcessor: TCodeProcessor;

    Procedure NewFile();
    Procedure OpenFile(sFileName: string);
    Procedure SaveFile();
    Procedure SaveFileAs(sFileName: string);

    Procedure SetCursor(iLine, iChar: integer);

  public
    { Public declarations }
    Stat: TStatusPanel;     // ��������, �� ������� ����� ������������ �����
    PosData: TStatusPanel;
  end;

var
  MForm: TMForm;

implementation

{$R *.dfm}

// ������� �� ������� ����� ���������
Procedure WriteMsg(sMessage: string);
begin
  MForm.MConsole.Lines.Append(sMessage);
end;

// ������� ������ � ����������� ������� ������
Procedure WriteError(sMessage: string);
begin
  with MForm do begin
    LBMessages.Items.Append(sMessage);

    // ���� ���� ������� �������, �� ������������� ��� � ��������� � ������� �������������� ������
    if bInProcess then begin
      TBStop.Click;
      PCWorkarea.ActivePageIndex := 0;
      if PMsgHost.Tag <> 0 then ClickResizer(MsgHeader);
    end;
  end;
end;

// ������� ����� ����
Procedure TMForm.NewFile();
begin
  // ���� ���� �� ��������, �� ��������� ���
  if not bFileSaved then SaveFile;

  // ���������� ��� ���� ���� �������� ��������� ������� �����
  sOpenedFile := '';
  bNewFile := true;
  bFileSaved := true;
  CodeText.Clear;
end;

// ��������� ����������� ����
Procedure TMForm.OpenFile(sFileName: string);
begin
  // ���� ���� �� ��������, �� ��������� ���
  if not bFileSaved then SaveFile;

  // ��������� � ����� �� ����� � ��������� ��� ����������
  sOpenedFile := sFileName;
  bNewFile := false;
  bFileSaved := true;
  CodeText.Lines.LoadFromFile(sOpenedFile);
end;

// ��������� ���� �� ����
Procedure TMForm.SaveFile();
begin
  // ���� ���� �����, �� ��������� ������ ���������� ����� � ��������� ���
  if bNewFile then with SaveDialog do begin
    Filter := '��������� �������� (*.txt)|*txt';
    FileName := ExtractFilePath(Application.ExeName)+'NewOne.txt';
    if Execute then SaveFileAs(FileName);
  end else if not bFileSaved then begin
    // ����� ������ ���������� ����� � ����, � �������� ��� �����������
    CodeText.Lines.SaveToFile(sOpenedFile);
    bFileSaved := true;
  end;
end;

// ��������� ����� � ��������� ��������� ����
Procedure TMForm.SaveFileAs(sFileName: string);
begin
  sOpenedFile := sFileName;
  if ExtractFileExt(sOpenedFile) <> '.txt' then sOpenedFile := sOpenedFile + '.txt';
  CodeText.Lines.SaveToFile(sOpenedFile);
  bNewFile := false;
  bFileSaved := true;
end;

(**
 * ����� ������ ��� ���������� �������� "�����������" � "������������" ������.
 *)
procedure TMForm.ClickResizer(Sender: TObject);
var
  oHeader: TPanel; // �������������� sender, ���� �� ������������� ���������� � �����.
  oHost: TPanel;   // ��� ��� �� ������, ������� � ����� ����������, ����� ����������� ��� ������ ��������.
begin
  oHeader := TPanel(Sender);
  oHost := TPanel(oHeader.Parent);
  if oHost.Tag <> 0 then begin
    // ���� ���� ��������, ������ ������������ �������� ��� ���������
    oHost.Height := oHost.Tag;
    oHost.Tag := 0;
  end else begin
    // ������������ ����� ������� ������, ������� ���������� ������������ :)
    oHost.Tag := oHost.Height;
    oHost.Height := oHeader.Height + oHost.BorderWidth * 2;
  end;
end;

// ������������� �����
procedure TMForm.FormCreate(Sender: TObject);
begin
  // ���������� ������� ���������
  ClickResizer(MsgHeader);
  // ������� ��� ���� �����
  CodeText.Clear;
  LBMessages.Clear;
  MConsole.Clear;
  // ���������� ������ �����
  bFileSaved := true;
  bInProcess := false;
  TBStop.Down := true;
  // ���������� �������� � ������ ������� ��� �������� �������
  Stat := StatusBar1.Panels.Items[0];
  PosData := StatusBar1.Panels.Items[2];

  // ��������� � ������� �������������� ������
  PCWorkarea.ActivePageIndex := 0;

  // ������� ����� ����
  NewFile();
end;

procedure TMForm.ShowAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMForm.FormResize(Sender: TObject);
begin
  // ������������� ������ ������ ������� �� ������ ����
  Stat.Width := ClientWidth - 252;
end;

// ���������� ������� ����� ����
procedure TMForm.TBNewClick(Sender: TObject);
begin
  NewFile();
end;

// ���������� ������� ����
procedure TMForm.TBOpenClick(Sender: TObject);
begin
  with OpenDialog do begin
    Filter := '��������� �������� (*.txt)|*txt';
    FileName := ExtractFilePath(Application.ExeName)+'*.txt';
    if Execute then OpenFile(FileName);
  end;
end;

// ���������� ��������� ����
procedure TMForm.TBSaveClick(Sender: TObject);
begin
  SaveFile;
end;

// � ������ �������������� ������ ����� �������� ���������� �������, ��� ��� � ��������
procedure TMForm.CodeTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  x,y: integer;
begin
  bFileSaved := false;
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// � ������ �������������� ������ ����� �������� ���������� �������, ��� ��� � ��������
procedure TMForm.CodeTextChange(Sender: TObject);
var
  x,y: integer;
begin
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// � ������ �������������� ������ ����� �������� ���������� �������, ��� ��� � ��������
procedure TMForm.CodeTextClick(Sender: TObject);
var
  x,y: integer;
begin
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// ������ ���������� ���� �� ������� ��������������
procedure TMForm.TBStartClick(Sender: TObject);
begin
  // ���� ������������� ��� ������� ��� � ��� ��������� ����, �� ���������������.
  if (bInProcess) or (length(CodeText.Lines.Text) < 1) then begin
    bInProcess := true;
    TBStop.Click;
    exit;
  end;

  // ���������, ���������, ��������� ������ ������
  TBNew.Enabled := false;
  TBOpen.Enabled := false;
  TBSave.Enabled := false;

  // ��������� � ������� ��������������, ��������� ������ �������������� ������
  PCWorkarea.ActivePageIndex := 1;
  PCWorkarea.Pages[0].Enabled := false;

  // ������������� ��������� ������������� � ������ ���� ������ ��������������
  TBStop.Down := false;
  TBStart.Down := true;
  bInProcess := true;

  // ������� ����������� ���������� � ��������� ����
  FTokenizer := TStringTokenizer.Cerate;
  FProcessor := TCodeProcessor.Create(FTokenizer);

  // ��������� ����������� ������ ��������� ���� �� ������� �������������� ������
  if not FTokenizer.Parse(CodeText.Lines.Text) then begin
    WriteError('[ Tokenizer::Parse() ] can not parse this text.');
    exit;
  end;

  // ��������� �������������� ������
  if not FProcessor.Parse then begin
    WriteError(
      '[ Processor::Parse() ] Error: '+CA_MESSAGE[FProcessor.LastError]+' At symbol "'+
      FProcessor.ErrorToken.Value+'" (source: '+
      IntToStr(FProcessor.ErrorToken.Line)+', '+IntToStr(FProcessor.ErrorToken.Symbol)+')'
    );
    exit;
  end;

  // ������������� ��������� ������ � ������� � ������ ������
  pStdEcho := WriteMsg;
  pStdError := WriteError;

  // ��������� ������������������ ���
  FProcessor.Run;

  // ������� ��������� ������
  pStdEcho := nil;
  pStdError := nil;

  // ���������������...
  TBStop.Click;
end;

procedure TMForm.TBStopClick(Sender: TObject);
begin
  // ���� ������� ��� ����������, �� � ������������� ������ ;)
  if not bInProcess then exit;

  // �������� ����������� ���������, ��������� � ���������
  TBNew.Enabled := true;
  TBOpen.Enabled := true;
  TBSave.Enabled := true;

  // ������������ ������ �������������� ������ � ������������� ��������� ��������������
  PCWorkarea.Pages[0].Enabled := true;
  TBStop.Down := true;
  TBStart.Down := false;

  // ���������� ������� ������������ ����������� � ���������� ����
  FProcessor.Free;
  FTokenizer.Free;

  // ������� ��������� ������ ��������������...
  bInProcess := false;
end;

Procedure TMForm.SetCursor(iLine, iChar: integer);
begin

end;

end.
