unit tokenizer;
(**
 * Модуль лексического анализатора. Содержит все необходимые инструменты для получения лексем
 * кода из строки текста.
 *
 * Основным классом модуля является TStringTokenizer, этот класс реализует анализ и
 * разделение текста на лексемы.
 *
 *)

interface

uses
  Windows, Classes,
//--- Собственные модули ---------------------------------------------------------------------------
  TextMessages,
//--------------------------------------------------------------------------------------------------
  SysUtils;

Type
  // Предопределение класса лексемы, TToken и TStringTokenizer полностью взаимосвязаны.
  TToken = class;

  (**
   * Перечисление базовых видов лексем.
   *
   *)
  TTokenType = (
    ttNone,      // Пустой тип, обозначение отсутствия типа
    ttUndef,     // Непонятная, неизвестная лексима
    ttMSComment, // Лексема многострочного комментария, вид : /* ... */
    ttSSComment, // Лексема однострочного комментария, вид : // ...
    ttType,      // Лексема обозначения типа, int к примеру
    ttKeyword,   // Лексема ключевого слова, как for или while
    ttIdent,     // Лексема идентификатора константы, переменной или функции
    ttDigit,     // Число, просто нетипизированное число
    ttNumINT,    // Целое число, возможно со знаком
    ttNumFLOAT,  // Вещественное число, со знаком и точкой
    ttString,    // Лексема строки, возможно в многострочной записи, вид : " ... "
    ttSymbol     // Символ, любой операторный символ : . + - * >= != и тому подобное
  );

  (**
   * Класс лексического анализатора. Выполняет прямую функцию по разбору текста на лексемы.
   * Подготавливает исходный код к разбору синтаксиса.
   * Способен одним методом удалить все комментарии из кода.
   * Вместе с этим является итератором лексем, функции итератора позволяют
   * значительно облегчить проход по коду.
   *
   *)
  TStringTokenizer = class
    Private
      (**
       * Хранилище лексем. Прямой доступ к объект не рекомендую,
       * лучше пользоваться специальными методами из области Protected данного классса.
       *)
      FTokens: TList;

      (**
       * Для воплощения механизма итератора необходимо хранить внутренний индекс в массиве.
       * Именно для этого служит данное поле.
       * Поле содержит индекс обозреваемой на данный момент лексемы.
       *)
      FCurrentIndex: integer;

    Protected
      (**
       * Метод для добавления лексемы в хранилище. Метод используется только в классе TToken!
       * Использовать его самостоятельно крайне не рекомендуется.
       * Объект TToken самостоятельно зарегистрирует себя при создании с помощью этого метода.
       *
       * Параметры:
       *   oToken - Лексема, которую необходимо зарегистрировать в хранилище.
       *)
      Procedure AddToken(oToken: TToken);

      (**
       * Метод удаляет лексему из хранилища. Так же может использоваться только в классе TToken.
       * Объект TToken самостоятельно удаляет себя из хранилища во время вызова его деструктора.
       *
       * Параметры:
       *   oToken - Лексема, которую надо удалить из хранилища.
       *)
      Procedure RemoveToken(oToken: TToken);

      (**
       * Метод вернет количество лексем в хранилище.
       * Возвращает число в диапазоне 0..32м
       *)
      Function GetCount: integer;

      (**
       * Метод по переданному индексу выбирает из хранилища лексему.
       * Возможен вариант, когда результатом метода будет nil! Такое возможно, если
       * индекс запрашиваемого элемента больше числа элементов хранилища, или меньше нуля.
       *
       * Параметры:
       *   Index - Индекс запрашиваемой лексемы.
       *
       * Возвращает лексему или nil, если передан неверный индекс
       *
       *)
      Function GetToken(Index: integer): TToken;

      (**
       * Метод импирического анализа лексемы для извлечения более детального ее типа.
       * Производится простой осмотр лексемы и проверка на соответствие некоторым критериям,
       * в случае совпадения с критериями делается предположение более точного типа лексемы.
       *
       * Параметры:
       *   sToken     - Подлежащая анализу лексема.
       *   eStartType - Результат первичного определения типа лексимы.
       *
       * Примечания:
       *   Производит перевод типов:
       *   - ttDigit -> ttNumINT | ttNumFLOAT
       *   - ttIdent -> ttIdent | ttType | ttKeyword
       *
       * Возвращает новый тип лексемы.
       *
       *)
      Function GuessTokenType( sToken: string; eStartType: TTokenType ): TTokenType;

    Public
      (**
       * Конструктор объекта, служит для заполнения некоторых полей объекта.
       *
       *)
      constructor Cerate;

      (**
       * Деструктор. Замещает деструктор базового класса. Очищает всю подчиненную память.
       *
       *)
      destructor Destroy; override;

      (**
       * Полностью очищает хранилище лексем.
       *
       *)
      Procedure Clear;

      (**
       * Удаляет из кода все комментарии.
       *
       *)
      Procedure ClearComments;

      (**
       * Реализует непосредственную функцию анализатора - первичный разбор кода на лексемы.
       *
       * Параметры:
       *   sStream - Текст исходного кода программы.
       *
       * Если разбор был удачный, возвращает true, иначе - false.
       *
       *)
      Function Parse(sStream: string): boolean;

      (**
       * Реализация механизма итератора.
       * Возвращает текущую осматриваемую лексему.
       * Может вернуть и nil, если лексем нет вобще или достигнут конец файла.
       *
       *)
      Function Current: TToken;

      (**
       * Реализация механизма итератора.
       * Перемещается на следующую лексему и возвращает ее подобно методу Current.
       * Так же способен вернуть nil по тем же причинам.
       *
       *)
      Function Next: TToken;

      (**
       * Реализация механизма итератора.
       * Проверяет, достигнут ли конец файла. Вернет true тогда, когда лексем большен не останется.
       *
       *)
      Function EOF: boolean;

      (**
       * Реализация механизма итератора.
       * Сбрасывает внутренний индекс осмотра. После этого Current станет указывать
       * на самую первую лексему.
       *
       *)
      Procedure Rewind;

      (**
       * Свойство возвращает общее число лексем в хранилище.
       *
       *)
      Property Count: integer read GetCount;

      (**
       * Свойтво позволяет обращаться к лексемам по их фактическому индексу.
       * Является свойством по умолчанию, что позволяет использовать объект
       * анализатора подобно массиу.
       *
       * Параметры:
       *   Index - Индекс запрашиваемой лексемы.
       *
       *)
      Property Tokens[Index: integer]: TToken read GetToken; default;
  end;


  (**
   * Класс лексемы, неразрывно связан с классом анализатора.
   * Во время создания самостоятельно себя регистрирует в анализаторе.
   * При удалении самостоятельно снимает регистрацию.
   * Содержит в себе тип лексемы и ее значение, это не всегда одна буква, слово и даже строка.
   *
   *)
  TToken = class
    Protected
      (**
       * Ссылка на хозяина лексемы - анализатор.
       * Служит для оповещения о регистрации/разрегистрации, а так же для
       * некоторых других механизмов
       *
       *)
      FOwner: TStringTokenizer;

      (**
       * Тип хранимой лексемы, определяется единожды, но может быть
       * переопределен только в анализаторе.
       *
       *)
      FType: TTokenType;

      (**
       * Значение лексимы, фактически это самое основное поле лексемы.
       *
       *)
      FValue: string;

      (**
       * Отладочная информация, показывает строку в коде, где расположена лексема.
       *
       *)
      FLine: integer;

      (**
       * Отладочная информация, показывает букву на строке, с которой начинается лексема.
       *
       *)
      FSymbol: integer;

      (**
       * Расширение механики итератора для анализатора.
       * Возвращает следующую лексему. Может вернуть и nil, если данная лексема последняя.
       *
       *)
      Function GetNext: TToken;

      (**
       * Расширение механизма итератора для анализатора.
       * Возвращает предыдущую лексему. Так же может вернуть nil, если данная лексема первая.
       *
       *)
      Function GetPrev: TToken;

      (**
       * Возвращает индекс данной лексемы в хранилище анализатора.
       *
       *)
      Function GetIndex: integer;

    Public
      (**
       * Конструктор объекта лексемы. Производит регистрацию в анализаторе.
       *
       *)
      constructor Create(aOwner: TStringTokenizer);

      (**
       * Деструктор лексемы. снимает регистрацию в анализаторе и освобождает занимаемую память.
       *
       *)
      destructor Destroy; override;

      (**
       * Возвращает значение лексемы.
       * Только для чтения.
       *
       *)
      Property Value: string read FValue;

      (**
       * Возвращает тип лексемы.
       * Толкьо для чтения.
       *
       *)
      Property TokenType: TTokenType read FType;

      (**
       * Возвращает строку начала лексемы.
       * Только для чтения.
       *
       *)
      Property Line: integer read FLine;

      (**
       * Возвращает букву начала лексемы.
       * Только для чтения.
       *
       *)
      Property Symbol: integer read FSymbol;

      (**
       * Возвращает следующую лексему, может вернуть и nil.
       * Только для чтения.
       *
       *)
      Property Next: TToken read GetNext;

      (**
       * Возвращает индекс лексемы в хранилище анализатора.
       * Только для чтения.
       *
       *)
      Property Index: integer read GetIndex;

      (**
       * Возвращает предыдущую лексему. Может вернуть и nil.
       * Только для чтения.
       *
       *)
      Property Prev: TToken read GetPrev;
  end;

const

  // Содержит количество названий типов в массиве CA_TYPES
  CI_TYPESCOUNT: integer = 3;

  // Содержит набор доступных названий типов, служит для импирического анализа.
  CA_TYPES: array [1..3] of string = (
    'int', 'float', 'bool'
  );

  // Содержит количество доступных ключевых слов в массиве CA_KEYWORDS
  CI_KEYWORDCOUNT: integer = 15;

  // Содержит набор доступных названий ключевых слов, служит для импирического анализа.
  CA_KEYWORDS: array [1..15] of string = (
    'int', 'float', 'bool', 'true', 'false', 'for', 'while', 'do', 'if', 'else',
    'const', 'return', 'continue', 'break', 'echo'
  );

  (**
   * Таблица приоритетов типов лексем для разбора, на случая, если семантика лексем пересекается.
   *
   * Благодаря этой таблице строка, к примеру, " int 25; " будет разобрана именно как строка, т.к.
   * слова заключены в кавычки и приоритет у строки выше чем у идентифиаторов, чисел и символов.
   *
   * Так же благодаря этой таблице любые комментарии будут верно определены, а их комментариев
   * не будет влиять на ход работы программы.
   *
   * Примечание:
   *   Зависимость приоритета -- чем меньше число, тем выше приоритет.
   *)
  CA_PRIORITIES: array [TTokenType] of byte = (
  //ttNone  ttUndef  ttMSComment  ttSSComment  ttType  ttKeyword  ttIdent  ttDigit  ttNumINT  ttNumFLOAT  ttString  ttSymbol
    255,    100,     10,          10,          100,    100,       100,     100,     100,      100,        50,       100
  );

implementation
//--- TStringTokenizer -----------------------------------------------------------------------------

(**
 * Конструктор объекта анализатора.
 *
 *)
constructor TStringTokenizer.Cerate;
begin
  // Создаем хранилище лексем, это ведь тоже объект класса.
  FTokens := TList.Create;
  // Делаем сброс итератора, на всякий случай.
  Rewind;
end;

(**
 * Деструктор объекта анализатора.
 *
 *)
destructor TStringTokenizer.Destroy;
begin
  // Очищаем хранилище, это обязательный момент.
  Clear;
  // Удаляем хранилище, теперь объект очистил всю подчиненную память.
  FTokens.Free;
  // Вызываем деструктор родительского объекта.
  inherited;
end;

(**
 * Метод очистки хранилища.
 *
 * Теория:
 *   Лексемы сами следят за своей регистрацией в хранилище. будет достаточно только
 *   Вызывать деструкторы лексем, удаляться из хранилищя они будут сами.
 *
 *)
Procedure TStringTokenizer.Clear;
begin
  // Пока в хранилище есть элменты, нужно удалять самую первую лексему.
  while FTokens.Count > 0 do TToken(FTokens.Items[0]).Free;
end;

(**
 * Метод очистки кода от комментариев.
 *
 * Теория:
 *   Очистка полностью аналогична полной очистке хранилища, только теперь
 *   удаляются лишь определенные лексемы, с определенными типами.
 *
 *)
Procedure TStringTokenizer.ClearComments;
var
  // бегунок по хранилищу
  iWalk: integer;
begin
  // сбрасываем бегунок
  iWalk := 0;

  // Нужно осмотреть все элементы хранилища
  while iWalk < FTokens.Count do begin
    if TToken(FTokens.Items[iWalk]).TokenType in [ttSSComment, ttMSComment] then begin
      // Если данная лексема является комментарием, удаляем ее
      // Важный момент, удалясь, лексема вынимает себя из хранилища, что приводит
      // к уменьшению общего числа лексем в хранилище.
      // Имено поэтому в случае удаления лексемы не стоит увеличивать бегунок.
      TToken(FTokens.Items[iWalk]).Free;

      // Иначе просто переходим к следующему элементу.
    end else inc( iWalk );
  end;
end;

(**
 * Регистрация лексемы в хранилище
 *
 *)
Procedure TStringTokenizer.AddToken(oToken: TToken);
begin
  FTokens.Add(oToken);
end;

(**
 * Снятие лексемы с регистрации
 *
 *)
Procedure TStringTokenizer.RemoveToken(oToken: TToken);
begin
  FTokens.Remove(oToken);
end;

(**
 * Определение количества лексем в хранилище
 *
 *)
Function TStringTokenizer.GetCount: integer;
begin
  Result := FTokens.Count;
end;

(**
 * Определение лексемы по ее индексу в хранилище.
 *
 *)
Function TStringTokenizer.GetToken(Index: integer): TToken;
begin
  // Если индекс попадает в диапазон допустимых для хранилища, возаращаем лексему
  if (Index >= 0) or (Index < FTokens.Count) then Result := TToken(FTokens.Items[Index])
  // Иначе возвращаем nil.
  else Result := nil;
end;

(**
 * Импирический анализ типа лексемы, просто попытка детализировать тип лексемы.
 *
 *)
Function TStringTokenizer.GuessTokenType( sToken: string; eStartType: TTokenType ): TTokenType;
var
  // Универсальный бегунок, много где используется
  iWalk: integer;
begin
  // Сперва просто говорим, тип такой, какой мы уже определили
  Result := eStartType;
  // Лексема определена как строка или комментарий, то и догадываться больше нечего, так оно и есть.
  if Result in [ttString, ttSSComment, ttMSComment] then exit;

  // Сброс бегунка
  iWalk := 1;
  // Провера, быть может лексема является идентификатором типа?
  while iWalk <= CI_TYPESCOUNT do begin
    if CA_TYPES[iWalk] = sToken then begin
      Result := ttType;
      break;
    end;
    inc(iWalk);
  end;
  // Если так, то останавливаемся
  if Result <> eStartType then exit;

  // Снова сбрасываем бегунок
  iWalk := 1;
  // Проверяем, возможно эта лексема является ключевым словом?
  while iWalk <= CI_KEYWORDCOUNT do begin
    if CA_KEYWORDS[iWalk] = sToken then begin
      Result := ttKeyword;
      break;
    end;
    inc(iWalk);
  end;
  // Завершаем анализ, если удалось определить тип
  if Result <> eStartType then exit;

  // Если лексема является числом, нужно определить тип числа
  if Result = ttDigit then begin
    Result := ttNumINT;
    // определяется это просто по наличию разделителя десятичной части.
    if Pos('.', sToken) > 0 then Result := ttNumFLOAT;
  end;

end;


(**
 * Анализ исходного кода и создание списка лексем.
 *
 * Параметры:
 *   sStream - Исходный код, который и подлежит разбору.
 *
 *   Возвращает true в случае удачного разбора, false в случае какой либо ошибки при разборе.
 *
 * Теория:
 *   Все элементы содержимого исходного кода можно разделить на три базовых типа:
 *   - Символы : + - * / % и.т.д...
 *   - Цифры : от 0 до 9
 *   - Буквы : большие и маленькие, латинские, русские, арабские, в общем любые буквы
 *
 *   Из этих элементов строятся лексемы разного толка, лексема может состоять из одного или
 *   нескольких элементов. При чем в лексемах разного вида могут содержаться одни и те же элементы,
 *   как символ точки среди цифр вещественного числа, набор цифр и букв в названии идентификатора, и т.д.
 *
 *   При разборе же делается так:
 *   - Изначально тип текущей лексемы устанавливается как ttNone, осмотр кода начинается с первого элемента
 *   - Осматривается текущий элемент и на его основе делается вывод о типе текущей лексемы
 *   - Проходя последовательно по нескольким элементам, мы не наблюдаем изменения их типа
 *     и считаем, что эта последовательность является единой лексемой.
 *   - Когда тип текущего элемента изменяется, мы просто регистрируем рассмотренную лексему в хранилище,
 *     меняем тип ткущей лексемы на увиденный и осматриваем код дальше.
 *
 *   Это самый легкий и действенный способ разбора кода на лексемы, но он не позволяет правильно
 *   разобрать моменты, когда элементы разного вида составляют единую лексему.
 *   В виду этого, лучшим способом будет создать некоторую иерархию типов лексем, другими словами -
 *   Установить для лексем приоритеты.
 *   Установим, к примеру, что комметарии будут с самым высоким приоритетом, после регистрации начала
 *   комментария все элементы будут считаться его частью, пока не будет достигнут фактический конец
 *   комментария.
 *   Вторым по значимости типом установим строку. Благодаря более низкому приоритету, строка
 *   встретившаяся в комментарии будет расценена как его часть. И т. д.
 *
 *   Благодаря установке приоритетов можно сформировать очень жесткие условия определения типа лексемы,
 *   а следовательно, достаточно точно и верно разобрать код на лексемы с достаточно точной их типизацией.
 *   Такая точость первичного разбора сильно облегчит разработку и работу анализатора синтаксиса.
 *
 *)
Function TStringTokenizer.Parse(sStream: string): boolean;
var
  // Промежуточный буфер, это текущий блок элементов для осмотра
  sCurrentBlock: string;
  // Промежуточный буфер, служит хранилищем данных для строк и многострочных комментариев
  sStringBlock: string;
  // Бегунок внутри буфера, содержит индекс текущего элемента (char - символа) в буфере осмотра
  iBlockWalker: integer;
  // Позиционер начала лексимы, устанавливается когда начинает разбор очередной лексемы
  iTokenStart: integer;
  // Позиционер текущей строки разбора в исходном коде
  iLinePos: integer;
  // Позиционер текущего элемента в исходном коде в рамках текущей строки
  iCharPos: integer;
  // Позиционер строки начала разбираемого в данный момент символа
  iStartLine: integer;
  // Позиционер элемента начала (на строке) текущего разбираемого символа
  iStartChar: integer;
  // Предположительный тип текущего разбираемого символа
  eCurrentType: TTokenType;
  // Ссылка на последний зарегистрированный символ
  oToken: TToken;
  // Флажок для маркировки признака окончания строковой лексемы типа "строка"
  bBreakStep: boolean;

  // Повсеместно вызывается, регистрирует текущую лексему
  Procedure AppendToken(sTValue: string; eTType: TTokenType = ttNone);
  begin
    // Определяем тип текущей лексемы, если он не был указан специально
    if eTType = ttNone then eTType := eCurrentType;

    oToken := TToken.Create(Self);
    oToken.FValue := sTValue;
    oToken.FType := GuessTokenType(sTValue, eTType);
    oToken.FLine := iStartLine;
    oToken.FSymbol := iStartChar;
  end;

begin
  // Самое главное - удалить признаки перевода каретки из кода (символ 0x10).
  sStream := StringReplace(sStream,#10,'',[rfReplaceAll]);
  // Текущая линия - 1, текущий символ тоже - 1, стартовые позиции лексемы - тоже 1
  iLinePos := 1;
  iCharPos := 1;
  iStartLine := 1;
  iStartChar := 1;
  // Никаких лексем не создавалось, параметр обнуляем
  oToken := nil;
  // Тип текущей лексемы определям как неизвестный
  eCurrentType := ttNone;

  // Пока в коде остаются элементы, продолжаем разбор
  while length(sStream) > 0 do begin
    // В буфер будем закладывать все элементы до первого пробела
    sCurrentBlock := copy(sStream, 1, pos(' ',sStream));
    if length(sCurrentBlock) > 0 then
      // Скопированные в буфер элементы надо удалить из кода
      delete(sStream, 1, length(sCurrentBlock))
    else
    begin
      // Может получиться, что пробелов в коде больше нет и в буфер ничего не скопировалось
      // В этом случае копируем в буфер всё что есть и опустошаем содержимое кода
      sCurrentBlock := sStream;
      sStream := '';
    end;

    // Сбрасываем бегунки позиций
    iBlockWalker := 1;
    iTokenStart := 1;

    // Строки и комментарии могут содержать пробелы, поэтому тип лексемы сбрасывается
    // только если это не строка и не комментарий
    if not(eCurrentType in [ttString, ttSSComment, ttMSComment]) then eCurrentType := ttNone;

    // Проходим по каждому элемену буфера
    while iBlockWalker <= length(sCurrentBlock) do
    begin
      // Первичная догадка о типе лексемы строится на основе встреченного в буфере символа
      case sCurrentBlock[iBlockWalker] of
        '"': begin // Встретился символ начала или конца строки

          // Самое главное - всегда делать проверку приоритетов между разбираемой лексемой
          // и текущим встреченным символом, чтоб не сломать разбор боле приоритетной лексемы.
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttString] then
          begin

            // знак кавычек может содержаться и в самой строке, чтоб отличить такой знак от признака
            // конца строки, нужно "экранировать" сам знак. Поставить перед ним символ "\".
            // Именно экранирование тут и проверяется.
            bBreakStep := false;
            if (eCurrentType = ttString) and (iBlockWalker > 1) then
            begin
              // если это не первый символ буфера и предыдущий символ является экранирующим,
              // делаем вывод, что данный символ кавычек не является признаком конца строки.
              if sCurrentBlock[iBlockWalker-1] = '\' then bBreakStep := true;
            end;


            // Развиваем логику только если сброшен флажок экранирования
            if not bBreakStep then
            begin
              if eCurrentType <> ttString then
              begin
                if (eCurrentType <> ttNone) then
                begin
                  // Надо зарегистрировать уже разобранную лексему, если таковой есть и это явно не строка
                  AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                end;
                // задаем состояние разбора так, чтоб было понятно, сейчас мы разбираем строку
                eCurrentType := ttString;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
                sStringBlock := '';
              end
               else begin
                // Завершаем разбирать строку, т.к. достигнут критерий ее конца

                // Собираем строку из буфера
                sStringBlock := StringReplace(sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart + 1), '\"', '"', [rfReplaceAll]);
                // Регистрируем лексиму
                AppendToken(copy(sStringBlock, 2, length(sStringBlock) - 2), ttString);

                // сбрасываем тип текущего символа
                eCurrentType := ttNone;
              end;
            end;
          end;
        end;

        #13: begin // Символ конца строки строго сигнализирует о конце лексемы
          // фактически мы уже на следующей строке исходного кода, на первом ее символе
          inc(iLinePos);
          iCharPos := 0;

          // надо зарегистрировать разобранный символ, если только это не строка и не комментарий
          if not (eCurrentType in [ttNone, ttString, ttMSComment]) then
          begin
            if eCurrentType in [ttSSComment] then
              // Признак окончания однострочного комментария - именно признак конца строки, надо склеить буфер
              AppendToken(copy(sStringBlock, 3, length(sStringBlock) - 2) + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart))
            else
              AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
            // Сбрасываем тип рассматриваемого символа
            eCurrentType := ttNone;
          end;

          // обнуляем последний зарегистрированную лексему
          oToken := nil;
        end;

        #9,' ': if not (eCurrentType in [ttNone, ttString, ttSSComment, ttMSComment]) then begin
          // Пробел или символ табуляции прямо символизируют о завершении текущей лексемы
          // Если только это не комментарий и не строка
          // регистрируем лексему
          AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
          // сбрасываем тип лексимы
          eCurrentType := ttNone;
        end;

        'a'..'z','A'..'Z','_': begin // Область разбора идентификаторов
          // Проверка приоритетов...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttIdent] then begin
            if eCurrentType <> ttIdent then
            begin
              // Если есть разбираемая лексема, надо ее зарегистрировать
              if eCurrentType <> ttNone then AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              // А потом явно задать аначало разбора лексемы идентификатора
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttIdent;
            end;
          end;
        end;

        '0'..'9': begin // Область разбора чисел
          // Обязательная проверка приоритетов...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttDigit] then
          begin
            if eCurrentType = ttNone then
            begin
              // Начинаем разбирать число, если ничего еще не было разобрано
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttDigit;
            end
            else
            if not (eCurrentType in [ttDigit, ttIdent]) then
            begin
              //если уже разбирается идентификатор или число, сюда не заходим

              if (eCurrentType = ttSymbol) and (sCurrentBlock[iBlockWalker - 1] in ['+','-']) and (oToken <> nil) then
              begin
                // Это хитрая разборка числа, если перед числом есть знак,
                // то возможно это знак числа, а не операции над ним
                if not(oToken.TokenType in [ttDigit, ttIdent, ttNumINT, ttNumFLOAT]) then
                begin
                  // текущий тип лексимы - символ, это точно символ + или - и левее символа
                  // не стоит операнд, значит можно приписать смвол к числу, достаточно просто
                  // сменить тип лексимы
                  eCurrentType := ttDigit;
                end
                else
                begin
                  // Регистрируем уже разобранную лексиму
                  AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                  // Задаем начало разбора числа
                  iTokenStart := iBlockWalker;
                  iStartLine := iLinePos;
                  iStartChar := iCharPos;
                  eCurrentType := ttDigit;
                end;
              end
              else
              begin
                // регистрируем разобранную лексиму
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                // Задаем начало разбора числа
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
                eCurrentType := ttDigit;
              end;
            end;
          end;
        end;

        '.': begin // символ точки обрабатывается отдельно от всех символов
          // Непременная проверка приоритета...
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then
          begin
            // пропускаем мимо разбора числа и строки, хотя благодаря приоритетам это и так делается
            if not(eCurrentType in [ttString, ttDigit]) then
            begin
              if eCurrentType <> ttNone then begin
                // Если есть разобранная лексема, регистрируем ее
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              end;
              // Сбрасываем состояние разбора лексем
              eCurrentType := ttNone;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              // регистрируем символ точки
              AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
            end;
          end;
        end;

        '/': begin // слеш может являться частью комментария, а может и символом делеиня...
          // сперва проверка приоритетов
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then begin

            if not (eCurrentType in [ttString]) then
            begin
              if eCurrentType <> ttNone then begin
                // если до этого момента разбирался какая то другая лексема, надо ее зарегистрировать
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              end;

              // если это не самый послледний символ в блоке...
              if 0 < (length(sCurrentBlock) - iBlockWalker) then
              begin
                case sCurrentBlock[iBlockWalker + 1] of
                  '/': begin
                    // Два слеша - означает начало однострочного комментария
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                    eCurrentType := ttSSComment;
                  end;
                  '*': begin
                    // слеш и звезда - начало многострочного комментария
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                    eCurrentType := ttMSComment;
                  end;
                  else begin
                    // а если что тодругое, то это просто знак деления
                    eCurrentType := ttNone;
                    AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
                  end;
                end;
              end else begin
                // А если последний, то регистрируем его как символ деления
                eCurrentType := ttNone;
                AppendToken(sCurrentBlock[iBlockWalker], ttSymbol);
              end;
            end;
          end
          else
          case eCurrentType of
            // Приоритеты могут совпасть только у комментариев,
            // здесь обрабатывается конец многострочного комментария
            ttMSComment: begin
              // Проверим, не стоит ли элементом ранее символа звездочки? Проверка на ... */
              if (iBlockWalker > 1) and (sCurrentBlock[iBlockWalker - 1] = '*') then begin
                // собираем разобранный комментарий вместе и регистрируем его
                sStringBlock := sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart - 1);
                AppendToken(copy(sStringBlock, 3, length(sStringBlock) - 2));
                // а затем сбрасываем состояние разбора
                eCurrentType := ttNone;
              end;
            end;
          end;
        end;

        '+','-','>','<','!','=','*','(',')',',',';','{','}','&','|','^','%':
        begin // область разбора символов
          // Проверяем приоритеты
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttSymbol] then
          begin
            case eCurrentType of
              ttNone:
              begin
                // Начинаем разбирать новый символ, если ничего еще не разбирали
                eCurrentType := ttSymbol;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
              end;
              ttSymbol:
              begin
                // А если уже итак разбираем символ, то возможно его надо зарегистрировать
                case sCurrentBlock[iBlockWalker - 1] of
                  '>','<','!','=':
                  begin
                    // Таке символ могут быть и со знаком равенства, >= к примеру
                    // тут и проверяется наличие такого знака
                    if sCurrentBlock[iBlockWalker] <> '=' then
                    begin
                      // если его нет, то регистрируем прошлый символ и переходим к текущему
                      AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                      eCurrentType := ttSymbol;
                      iTokenStart := iBlockWalker;
                      iStartLine := iLinePos;
                      iStartChar := iCharPos;
                    end;
                  end;

                  else
                  begin
                    // регистрируем уже разобраный символ и переходим к текущему
                    AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                    eCurrentType := ttSymbol;
                    iTokenStart := iBlockWalker;
                    iStartLine := iLinePos;
                    iStartChar := iCharPos;
                  end;
                end;
              end;

              else begin
                // регистрируем уже разобраный символ и переходим к текущему
                AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
                eCurrentType := ttSymbol;
                iTokenStart := iBlockWalker;
                iStartLine := iLinePos;
                iStartChar := iCharPos;
              end;
            end;
          end;
        end;

        else begin // Может так получиться, что в коде окажется какой нибудь символ не из выше описанных
          // Но даже не смотря на это сперва надо сверит приоритеты
          if CA_PRIORITIES[eCurrentType] >= CA_PRIORITIES[ttUndef] then
          begin
            // Просто регистрируем цепочку символов как неизвестную лексиму
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
              // не забываем регистрировать ранее рассмотренную лексиму
              AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
              iTokenStart := iBlockWalker;
              iStartLine := iLinePos;
              iStartChar := iCharPos;
              eCurrentType := ttUndef;
            end;
          end;
        end;
      end;
      // сдвигаемся дальше по буферу
      inc(iBlockWalker);
      inc(iCharPos);
    end;

    // Склеиваем стек для строк и комментариев, если таковые разбираются в данным моент
    if eCurrentType in [ttString, ttSSComment, ttMSComment] then
      sStringBlock := sStringBlock + copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart + 1)
    else
      // Иначе просто освобождаем его, чтоб не мусорить лишний раз
      sStringBlock := '';

    // Если под разбором не строка, не комментарий, но что то осмысленное, регистрируем это как лексему
    if not (eCurrentType in [ttNone, ttString, ttSSComment, ttMSComment]) then begin
      AppendToken(copy(sCurrentBlock, iTokenStart, iBlockWalker - iTokenStart));
    end;
  end;

  // Сбрасываем итератор
  Rewind;
  Result := true;
end;

(**
 * Для итератора.
 * Возвращает текущую обозреваемую лексиму
 *
 *)
Function TStringTokenizer.Current: TToken;
begin
  // если уже конец списка, возвращаем nil, иначе - лексему по итерационному индексу
  if EOF then Result := nil
  else Result := TToken(FTokens.Items[FCurrentIndex]);
end;

(**
 * Для тератора.
 * Сдвигает итерационный индекс дальше и возвращает новую текущую лексему
 *
 *)
Function TStringTokenizer.Next: TToken;
begin
  // Сдвигаем индекс только если он меньше размерности хранилища
  if FTokens.Count > FCurrentIndex then inc(FCurrentIndex);
  // если достигнут колец, возвращаем nil, иначе - лексему по новому индексу
  if EOF then Result := nil
  else Result := TToken(FTokens.Items[FCurrentIndex]);
end;

(**
 * Для итератора.
 * Проверка на достижение последнего элемента хранилища
 *
 *)
Function TStringTokenizer.EOF: boolean;
begin
  Result := FCurrentIndex >= FTokens.Count;
end;

(**
 * Для итератора.
 * Сброс внутреннего итерационного индекса
 *
 *)
Procedure TStringTokenizer.Rewind;
begin
  FCurrentIndex := 0;
end;
//--------------------------------------------------------------------------------------------------
//--- TToken ---------------------------------------------------------------------------------------

(**
 * Конструктор объекта лексемы.
 *
 *)
constructor TToken.Create(aOwner: TStringTokenizer);
begin
  FOwner := aOwner;
  // А вот и обещенная регистрация в хранилище хозяина.
  FOwner.AddToken(Self);
  // Служебные поля сбрасываются
  FLine := 0;
  FSymbol := 0;
end;

(**
 * Деструктор объекта
 *
 *)
destructor TToken.Destroy;
begin
  // Сперва снимаемся с регистрации
  FOwner.RemoveToken(Self);
  // Потом окончательно удаляемся
  inherited;
end;

(**
 * Расширение итератора.
 * Возвращает следующую за текущей лексему
 *
 *)
Function TToken.GetNext: TToken; 
begin
  Result := FOwner.GetToken(FOwner.FTokens.IndexOf(Self)+1);
end;

(**
 * Расширение итератора.
 * Возвращает предыдущую за текущей лексему
 *
 *)
Function TToken.GetPrev: TToken;
begin
  Result := FOwner.GetToken(FOwner.FTokens.IndexOf(Self)-1);
end;

(**
 * Расширение итератора.
 * Возвращает индекс данной лексемы в хранилище хозяина
 *
 *)
Function TToken.GetIndex: integer;
begin
  Result := FOwner.FTokens.IndexOf(Self);
end;
//--------------------------------------------------------------------------------------------------
end.
