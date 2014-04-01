unit UGlobal;

interface

const
  FileName = 'groups.txt';
  MaxPeopleCount = 20;
  MaxGroupCount = 20;
  MaxBusCount = 10;

type
  TAAllocation = array [1..MaxPeopleCount,1..MaxGroupCount] of string;
  TAActiveTourists =  array [1..MaxPeopleCount,1..MaxGroupCount] of boolean;
  TAGroupsCount = array [1..MaxGroupCount] of byte;
  TABus = array [1..MaxBusCount] of byte;

var
  Allocation: TAAllocation;
  ActiveTourists: TAActiveTourists;
  G: TAGroupsCount;
  B: TABus;
  PersonPerGroup,GroupCount,BusCount: byte;
  SGH,SGW: byte;

procedure ReadGroups;
procedure CountFreeGroups;

implementation

///
///  Подсчёт количества
///  туристов в группе
///
procedure CountFreeGroups;
var
i,j: byte;
c: byte;
begin
  for j:=1 to GroupCount do
  begin
    c:=0;
    for i:=1 to PersonPerGroup do
      if ActiveTourists[i,j] then
        c:=c+1;
    G[j]:=c;
  end;
end;

///
///  Считывание распределения туристов
///  по группам
///
procedure ReadGroups;
var
f: TextFile;
i,j: byte;
str,tmp: string;
begin
  AssignFile(f,FileName);
  reset(f);
  read(f,GroupCount); readln(f,PersonPerGroup);

  for i:=1 to PersonPerGroup do
  begin
    j:=0;
    readln(f,str);
    while pos(#9,str)<>0 do
    begin
      tmp:=copy(str,1,pos(#9,str)-1);
      delete(str,1,pos(#9,str));
      j:=j+1;
      Allocation[i,j]:=tmp;
    end;
    j:=j+1;
    Allocation[i,j]:=str;
  end;

  for i:=1 to PersonPerGroup do
    for j:=1 to GroupCount do
      if Allocation[i,j]<>'0' then
        ActiveTourists[i,j]:=true
      else
        ActiveTourists[i,j]:=false;

  CloseFile(f);
end;

initialization
  SGH:=20;
  SGW:=30;
  PersonPerGroup:=1;
  GroupCount:=1;
end.
