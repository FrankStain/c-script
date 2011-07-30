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
    Stat: TStatusPanel;     // Панелька, на которой будет отображаться текст
    PosData: TStatusPanel;
  end;

var
  MForm: TMForm;

implementation

{$R *.dfm}

// Выводим на консоль формы сообщение
Procedure WriteMsg(sMessage: string);
begin
  MForm.MConsole.Lines.Append(sMessage);
end;

// Выводим ошибку в специальную область ошибок
Procedure WriteError(sMessage: string);
begin
  with MForm do begin
    LBMessages.Items.Append(sMessage);

    // Если идет процесс разбора, то останавливаем его и переходим в область редактирования текста
    if bInProcess then begin
      TBStop.Click;
      PCWorkarea.ActivePageIndex := 0;
      if PMsgHost.Tag <> 0 then ClickResizer(MsgHeader);
    end;
  end;
end;

// создаем новый файл
Procedure TMForm.NewFile();
begin
  // Если файл не сохранен, то сохраняем его
  if not bFileSaved then SaveFile;

  // Сбрасываем все поля чтоб получить состояние чистого файла
  sOpenedFile := '';
  bNewFile := true;
  bFileSaved := true;
  CodeText.Clear;
end;

// Открываем сохраненный файл
Procedure TMForm.OpenFile(sFileName: string);
begin
  // Если файл не сохранен, то сохраняем его
  if not bFileSaved then SaveFile;

  // Цепляемся к файлу на диске и загружаем его содержимое
  sOpenedFile := sFileName;
  bNewFile := false;
  bFileSaved := true;
  CodeText.Lines.LoadFromFile(sOpenedFile);
end;

// Сохраняем файл на диск
Procedure TMForm.SaveFile();
begin
  // Если файл новый, то открываем диалог сохранения файла и сохраняем его
  if bNewFile then with SaveDialog do begin
    Filter := 'Текстовый документ (*.txt)|*txt';
    FileName := ExtractFilePath(Application.ExeName)+'NewOne.txt';
    if Execute then SaveFileAs(FileName);
  end else if not bFileSaved then begin
    // Иначе просто записываем текст в файл, к которому уже прицепились
    CodeText.Lines.SaveToFile(sOpenedFile);
    bFileSaved := true;
  end;
end;

// Сохраняем текст в конкретно указанный файл
Procedure TMForm.SaveFileAs(sFileName: string);
begin
  sOpenedFile := sFileName;
  if ExtractFileExt(sOpenedFile) <> '.txt' then sOpenedFile := sOpenedFile + '.txt';
  CodeText.Lines.SaveToFile(sOpenedFile);
  bNewFile := false;
  bFileSaved := true;
end;

(**
 * Метод служит для совершения действия "схлопывания" и "раскладывния" панели.
 *)
procedure TMForm.ClickResizer(Sender: TObject);
var
  oHeader: TPanel; // перефразировка sender, чтоб не монстрировать приведения к типам.
  oHost: TPanel;   // как раз та панель, которую и будем схлопывать, метод универсален для любого элемента.
begin
  oHeader := TPanel(Sender);
  oHost := TPanel(oHeader.Parent);
  if oHost.Tag <> 0 then begin
    // Хост явно схлопнут, значит пользователь приказал его разложить
    oHost.Height := oHost.Tag;
    oHost.Tag := 0;
  end else begin
    // Пользователь хочет сложить панель, покорно повинуемся пользователю :)
    oHost.Tag := oHost.Height;
    oHost.Height := oHeader.Height + oHost.BorderWidth * 2;
  end;
end;

// Инициализация фромы
procedure TMForm.FormCreate(Sender: TObject);
begin
  // Складываем область сообщений
  ClickResizer(MsgHeader);
  // очищаем все поля ввода
  CodeText.Clear;
  LBMessages.Clear;
  MConsole.Clear;
  // сбрасываем нужные флаги
  bFileSaved := true;
  bInProcess := false;
  TBStop.Down := true;
  // определяем панельки в строке статуса для быстрого доступа
  Stat := StatusBar1.Panels.Items[0];
  PosData := StatusBar1.Panels.Items[2];

  // переходим в область редактирования текста
  PCWorkarea.ActivePageIndex := 0;

  // создаем новый файл
  NewFile();
end;

procedure TMForm.ShowAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMForm.FormResize(Sender: TObject);
begin
  // автоизменение ширины строки статуса от ширины окна
  Stat.Width := ClientWidth - 252;
end;

// Инструкция создать новый файл
procedure TMForm.TBNewClick(Sender: TObject);
begin
  NewFile();
end;

// Инструкция открыть файл
procedure TMForm.TBOpenClick(Sender: TObject);
begin
  with OpenDialog do begin
    Filter := 'Текстовый документ (*.txt)|*txt';
    FileName := ExtractFilePath(Application.ExeName)+'*.txt';
    if Execute then OpenFile(FileName);
  end;
end;

// Инструкция сохранить файл
procedure TMForm.TBSaveClick(Sender: TObject);
begin
  SaveFile;
end;

// В режиме редактирования текста фажно получить координаты курсора, это тут и делается
procedure TMForm.CodeTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  x,y: integer;
begin
  bFileSaved := false;
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// В режиме редактирования текста фажно получить координаты курсора, это тут и делается
procedure TMForm.CodeTextChange(Sender: TObject);
var
  x,y: integer;
begin
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// В режиме редактирования текста фажно получить координаты курсора, это тут и делается
procedure TMForm.CodeTextClick(Sender: TObject);
var
  x,y: integer;
begin
  y:=CodeText.Perform(EM_LINEFROMCHAR, CodeText.SelStart, 0) + 1;
  x:=CodeText.SelStart - CodeText.Perform(EM_LINEINDEX, Y - 1, 0) + 1;
  PosData.Text:=format(' %d : %d ',[y, x]);
end;

// Запуск исполнения кода из области редактирования
procedure TMForm.TBStartClick(Sender: TObject);
begin
  // если интерпретатор уже запущен или в нет исходного кода, то останавливаемся.
  if (bInProcess) or (length(CodeText.Lines.Text) < 1) then begin
    bInProcess := true;
    TBStop.Click;
    exit;
  end;

  // открывать, сохранять, создавать больше нельзя
  TBNew.Enabled := false;
  TBOpen.Enabled := false;
  TBSave.Enabled := false;

  // переходим в консоль интерпретатора, отключаем облать редактирования текста
  PCWorkarea.ActivePageIndex := 1;
  PCWorkarea.Pages[0].Enabled := false;

  // Визуализируем состояние интерпретации и ставим флаг работы интерпретатора
  TBStop.Down := false;
  TBStart.Down := true;
  bInProcess := true;

  // Создаем лексический анализатор и процессор кода
  FTokenizer := TStringTokenizer.Cerate;
  FProcessor := TCodeProcessor.Create(FTokenizer);

  // выполняем лексический анализ исходного кода из области редактирования текста
  if not FTokenizer.Parse(CodeText.Lines.Text) then begin
    WriteError('[ Tokenizer::Parse() ] can not parse this text.');
    exit;
  end;

  // выполняем синтаксический анализ
  if not FProcessor.Parse then begin
    WriteError(
      '[ Processor::Parse() ] Error: '+CA_MESSAGE[FProcessor.LastError]+' At symbol "'+
      FProcessor.ErrorToken.Value+'" (source: '+
      IntToStr(FProcessor.ErrorToken.Line)+', '+IntToStr(FProcessor.ErrorToken.Symbol)+')'
    );
    exit;
  end;

  // устанавливаем указатели вывода в консоль и вывода ошибок
  pStdEcho := WriteMsg;
  pStdError := WriteError;

  // запускаем интерпретированный код
  FProcessor.Run;

  // снимаем указатели вывода
  pStdEcho := nil;
  pStdError := nil;

  // останавливаемся...
  TBStop.Click;
end;

procedure TMForm.TBStopClick(Sender: TObject);
begin
  // если процесс уже остановлен, то и останавливать нечего ;)
  if not bInProcess then exit;

  // включаем возможность создавать, открывать и сохранять
  TBNew.Enabled := true;
  TBOpen.Enabled := true;
  TBSave.Enabled := true;

  // Активизируем облать редактирования текста и визуализируем состояние интерпретатора
  PCWorkarea.Pages[0].Enabled := true;
  TBStop.Down := true;
  TBStart.Down := false;

  // Уничтожаем объекты лексического анализатора и процессора кода
  FProcessor.Free;
  FTokenizer.Free;

  // снимаем состояние работы интерпретатора...
  bInProcess := false;
end;

Procedure TMForm.SetCursor(iLine, iChar: integer);
begin

end;

end.
