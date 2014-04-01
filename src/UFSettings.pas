unit UFSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids;

type
  TFSettings = class(TForm)
    SG: TStringGrid;
    LEM: TLabeledEdit;
    LEN: TLabeledEdit;
    UDM: TUpDown;
    UDN: TUpDown;
    BSave: TButton;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure LEMChange(Sender: TObject);
    procedure LENChange(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSettings: TFSettings;

implementation

{$R *.dfm}
uses
  UGlobal;

procedure TFSettings.BSaveClick(Sender: TObject);
var
f: TextFile;
M,N: byte;
i,j: byte;
str: string;
begin
  N:=UDN.Position; M:=UDM.Position;
  AssignFile(f,UGlobal.FileName);
  rewrite(f);
  writeln(f,M,' ',N);
  for i:=1 to N do
  begin
    str:='';
    for j:=1 to M do
      str:=str+SG.Cells[j-1,i-1]+#9;
    delete(str,length(str),1);
    writeln(f,str);
  end;
  CloseFile(f);
  FSettings.Close;
end;

procedure TFSettings.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize:=false;
end;

procedure TFSettings.LEMChange(Sender: TObject);
begin
  SG.ColCount:=UDM.Position;
end;

procedure TFSettings.LENChange(Sender: TObject);
begin
  SG.RowCount:=UDN.Position;
end;

end.
