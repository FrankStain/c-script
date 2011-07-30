unit TextMessages;

interface

uses
  Windows, Classes, SysUtils;

Type
  TParserErrorState = (
    esOK = 0, esNoScript, esUnexpSymbol, esNeedSymbol, esUnclosedExpression,
    esConstNotInit, esScriptStackError, esUnknownVar, esVarIsDuped, esFuncIsDuped,
    esConstAssignErr, esUndeclVar, esUndeclFunc
  );


const
  CA_MESSAGE: array [TParserErrorState] of string = (
     'All is okay!'                  // esOK
    ,'There are no script...'        // esNoScript
    ,'Unexpected token.'             // esUnexpSymbol
    ,'Symbol is needed.'             // esNeedSymbol
    ,'Uncomplited expression.'       // esUnclosedExpression
    ,'Constant must be initialized.' // esConstNotInit
    ,'Script is not complited.'      // esScriptStackError
    ,'Undeclarated variable.'        // esUnknownVar
    ,'Variable duplicated.'          // esVarIsDuped
    ,'Function duplicated'           // esFuncIsDuped
    ,'Const assigning error.'        // esConstAssignErr
    ,'Undeclarated variable.'        // esUndeclVar
    ,'Undeclarated function.'        // esUndeclFunc 
  );

implementation

end.
