program Project6;

uses
  Forms,
  main in 'main.pas' {Form5},
  Shistory in 'Shistory.pas' {Form1},
  Scontact_list in 'Scontact_list.pas',
  Sadd in 'Sadd.pas' {Form3},
  vodafone in 'Czech Republic\vodafone.pas',
  o2 in 'Czech Republic\o2.pas',
  TMobile in 'Czech Republic\TMobile.pas',
  PNGZLIB in 'PNG\PNGZLIB.pas',
  PNGImage in 'PNG\PNGImage.pas',
  countries_operators in 'countries_operators.pas',
  Shistory_unit in 'Shistory_unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
