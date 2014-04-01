unit UProcess;

interface
uses
  UGlobal, System.SysUtils;

type
  TRass = array [1..MaxGroupCount,1..MaxBusCount] of boolean;

var
R: TRass;

procedure DoTask;

implementation

procedure INIT(fl: boolean);
var
i,j: byte;
begin
  if fl then
    for i:=1 to GroupCount do
      for j:=1 to BusCount do
        R[i,j]:=false;
end;

function Popitka(Apriori: byte): real;
var
i,j,k: byte;
res: real;
GNU: set of byte;
count: byte;
tmpB: TABus;
min,max: byte;
fl: boolean;
begin
  for i:=1 to BusCount do
    tmpB[i]:=B[i];
  GNU:=[1..UGlobal.GroupCount];
  res:=-1; count:=0;

  fl:=true;
  for j:=1 to BusCount-1 do
  begin
    for i:=1 to Apriori do
    begin
      k:=(j-1)*Apriori+i;
      if tmpB[j]>=G[k] then
      begin
        R[k,j]:=true;
        tmpB[j]:=tmpB[j]-G[k];
        EXCLUDE(GNU,k);
      end
      else
        fl:=false;
    end;
  end;

  if fl then
    while count<=50 do
    begin
      count:=count+1;
      i:=random(GroupCount)+1;
      j:=random(BusCount)+1;
      if (i in GNU) and (tmpB[j]>=G[i]) then
      begin
        count:=0;
        EXCLUDE(GNU,i);
        tmpB[j]:=tmpB[j]-G[i];
        R[i,j]:=true;
      end;
    end;

  if GNU=[] then
  begin
    min:=tmpB[1]; max:=tmpB[1];
    for i:=1 to BusCount do
    begin
      if tmpB[i]>max then
        max:=tmpB[i];
      if tmpB[i]<min then
        min:=tmpB[i];
    end;
    res:=max-min;
  end;
  Popitka:=res;
end;

function Placing(var BestR:TRass; Apriori: byte; var res: real): boolean;
var
count: LongWord;
BestRes: real;
i,j: byte;
fl: boolean;
begin
  fl:=false;
  INIT(true);
  count:=0;
  BestRes:=100000;
  while count<=100000 do
  begin
    count:=count+1;
    res:=Popitka(Apriori);
    if (res>=0) and (res<BestRes) then
    begin
     fl:=true;
     BestRes:=res;
     for i:=1 to GroupCount do
       for j:=1 to BusCount do
         BestR[i,j]:=R[i,j];
    end;
    INIT(true);
  end;
  res:=BestRes;
  Placing:=fl;
end;

procedure ResultOutput(R: TRass);
var
i,j: byte;
tmpB: TABus;
f: TextFile;
begin
  AssignFile(f,'out.txt');
  if not FileExists('out.txt') then
  begin
    rewrite(f);
    writeln(f,'Варианты рассадки:')
  end
  else
    Append(f);

  INIT(false);
  for i:=1 to BusCount do
    tmpB[i]:=B[i];

  writeln(f,'------------------------------');
  for i:=1 to GroupCount do
  begin
    write(f,i:3,'| ');
    for j:=1 to BusCount do
      if R[i,j] then
      begin
        tmpB[j]:=tmpB[j]-G[i];
        write(f,'1 ');
      end
      else
        write(f,'0 ');
    writeln(f);
  end;
  writeln(f);

  for i:=1 to BusCount do
    writeln(f,'В автобусе №',i,' свободно ',tmpB[i],' мест');
  CloseFile(f);
end;

procedure DoTask;
var
BestR: TRass;
i: integer;
fl: boolean;
prevres,res: real;
begin
  randomize;
  prevres:=100000;
  for i:=GroupCount div BusCount downto 0 do
  begin
    fl:=Placing(BestR,i,res);
    if fl and (res<PrevRes) then
    begin
      prevres:=res;
      ResultOutput(BestR);
    end;
  end;
end;

end.
