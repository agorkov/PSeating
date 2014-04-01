unit UFMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Menus;

type
  TFMain = class(TForm)
    SGAllocation: TStringGrid;
    SGFG: TStringGrid;
    LEBusCount: TLabeledEdit;
    UDBusCount: TUpDown;
    SGBus: TStringGrid;
    BProcess: TButton;
    BChange: TButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure SGAllocationDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure LEBusCountChange(Sender: TObject);
    procedure SGAllocationClick(Sender: TObject);
    procedure BProcessClick(Sender: TObject);
    procedure BChangeClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}
uses
  UGlobal, UProcess, UFSettings, UFAbout, shellAPI;

///
///  Вывод данных на экран
///
procedure UpdateScreen;
var
i,j: byte;
begin
  for i:=1 to PersonPerGroup do
    for j:=1 to GroupCount do
      if Allocation[i,j]='' then
        ActiveTourists[i,j]:=false;

  ///
  ///  Таблица размещения туристов
  ///  по экскурсионным группам
  ///
  FMain.SGAllocation.RowCount:=PersonPerGroup;
  FMain.SGAllocation.ColCount:=GroupCount;
  for i:=0 to PersonPerGroup-1 do
    FMain.SGAllocation.RowHeights[i]:=UGlobal.SGH;
  for j:=0 to GroupCount-1 do
    FMain.SGAllocation.ColWidths[j]:=UGlobal.SGW;
  for i:=1 to PersonPerGroup do
    for j:=1 to GroupCount do
      if Allocation[i,j]<>'0' then
      FMain.SGAllocation.Cells[j-1,i-1]:=UGlobal.Allocation[i,j];

  ///
  ///  Таблица свободных мест в
  ///  каждой группе
  ///
  FMain.SGFG.RowCount:=1;
  FMain.SGFG.ColCount:=UGlobal.GroupCount;
  FMain.SGFG.RowHeights[0]:=UGlobal.SGH;
  for j:=0 to GroupCount-1 do
    FMain.SGFG.ColWidths[j]:=UGlobal.SGW;
  UGlobal.CountFreeGroups;
  for j:=0 to GroupCount-1 do
    FMain.SGFG.Cells[j,0]:=inttostr(UGlobal.G[j+1]);

  ///
  ///  Таблица автобусов
  ///
  FMain.SGBus.RowCount:=1;
  FMain.SGBus.ColCount:=UGlobal.BusCount;
  FMain.SGBus.RowHeights[0]:=UGlobal.SGH;
  for j:=0 to BusCount-1 do
    FMain.SGBus.ColWidths[j]:=UGlobal.SGW;
  for i:=1 to BusCount do
    if FMain.SGBus.Cells[i-1,0]='' then
      FMain.SGBus.Cells[i-1,0]:='0';

  ///
  ///  Количество автобусов
  ///
  //FMain.UDBusCount.Position:=UGlobal.BusCount;
end;

///
///  Перерисовка экрана после изменеия количества автобусов
///
procedure TFMain.LEBusCountChange(Sender: TObject);
begin
  UGlobal.BusCount:=strtoint(LEBusCount.Text);
  if FMain.Tag=1 then
    UpdateScreen;
end;

procedure TFMain.N2Click(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TFMain.N3Click(Sender: TObject);
begin
  UFAbout.FAbout.ShowModal;
end;

///
///  Отрисовка ячеек в таблице размещения
///
procedure TFMain.SGAllocationDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if not ActiveTourists[ARow+1,ACol+1] then
    SGAllocation.Canvas.Font.Color:=clred
  else
    SGAllocation.Canvas.Font.Color:=clBlack;
  if Allocation[ARow+1,ACol+1]<>'0' then
    SGAllocation.Canvas.TextOut(rect.left+3, rect.top+3,Allocation[ARow+1,ACol+1]);
end;

///
///  Исключение туристов из
///  экскурсионных групп
///
procedure TFMain.SGAllocationClick(Sender: TObject);
begin
  SGAllocation.Cells[SGAllocation.Col,SGAllocation.Row]:='';
  if Allocation[SGAllocation.Row+1,SGAllocation.Col+1]<>'0' then
    ActiveTourists[SGAllocation.Row+1,SGAllocation.Col+1]:=not ActiveTourists[SGAllocation.Row+1,SGAllocation.Col+1];
  UpdateScreen;
end;

///
///  Вызов меню настроек
///
procedure TFMain.BChangeClick(Sender: TObject);
begin
  UFSettings.FSettings.ShowModal;
  FormActivate(nil);
end;

///
///  Поиск решения
///
procedure TFMain.BProcessClick(Sender: TObject);
var
i: byte;
f: TextFile;
begin
  if FileExists('out.txt') then
  begin
    AssignFile(f,'out.txt');
    Erase(f);
  end;
  for i:=1 to BusCount do
    B[i]:=strtoint(SGBus.Cells[i-1,0]);
  UProcess.DoTask;
  if FileExists('out.txt') then
    ShellExecute(Handle,'open','c:\windows\notepad.exe','out.txt',nil,SW_SHOWNORMAL)
  else
    ShowMessage('К сожалению рассадка невозможна');
end;

procedure TFMain.FormActivate(Sender: TObject);
var
f: TextFile;
begin
  if FileExists(UGlobal.FileName) then
    UGlobal.ReadGroups ;
  UpdateScreen;
  FMain.Tag:=1;
  if FileExists('out.txt') then
  begin
    AssignFile(f,'out.txt');
    Erase(f);
  end;
end;

procedure TFMain.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize:=false;
end;

end.
