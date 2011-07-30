program math_parser;

uses
  Forms,
  MUnit in 'MUnit.pas' {MForm},
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  operators in 'Operators.pas',
  processor in 'processor.pas',
  TextMessages in 'TextMessages.pas',
  tokenizer in 'tokenizer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMForm, MForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
