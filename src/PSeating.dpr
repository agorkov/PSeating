program PSeating;

uses
  Vcl.Forms,
  UFMain in 'UFMain.pas' {FMain},
  UGlobal in 'UGlobal.pas',
  UProcess in 'UProcess.pas' {$R *.res},
  UFSettings in 'UFSettings.pas' {FSettings},
  UFAbout in 'UFAbout.pas' {FAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFSettings, FSettings);
  Application.CreateForm(TFAbout, FAbout);
  Application.Run;
end.
