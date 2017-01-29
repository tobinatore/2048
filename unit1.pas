unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LCLType,
  StdCtrls, ExtCtrls, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    grp_points: TGroupBox;
    grp_highscore: TGroupBox;
    Image1: TImage;
    lbl_points: TLabel;
    lbl_highscore: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  type r_tile = record
    value: Integer;
    caption: String;
    color : TColor;
  end;

 type a_container = array[1..4,1..4] of r_tile;
 type a_colors = array[0..9000] of TColor;

 var
  Form1: TForm1;
  tile_null : r_tile;
  field: a_container;
  notShown : Boolean;
  colors: a_colors;
  points,highscore,win : Integer;
  name : String;
  sl : TStringList;

implementation

uses Unit2;
{$R *.lfm}

{ TForm1 }

function won() : Boolean;
var x,y : Integer;
 var hasWon : Boolean;
begin
 hasWon:= false;
 for y := 1 to 4 do begin
     for x := 1 to 4 do begin
          if field[y,x].value >= win then hasWon := true;
     end;
 end;

 result := hasWon;
end;

procedure Delay(msec: integer);
var start, stop: LongInt;
begin
  start := GetTickCount64;
  repeat
    stop := GetTickCount64;
    Application.ProcessMessages;
  until (stop-start)>=msec;
end;


//DRAW_FIELD_____________________________
procedure drawField();
var x,y,mx,my : Integer;
begin

 for y := 0 to 3 do begin
  for x := 0 to 3 do begin
   Form1.Image1.Canvas.Brush.Color := colors[field[y+1,x+1].value];
   Form1.Image1.Canvas.Rectangle(x*90,y*90,(x+1)*90,(y+1)*90);
   mx := (x*90+(x+1)*90) Div 2 - 3;
   my := (y*90+(y+1)*90) Div 2 - 5;

   if field[y+1,x+1].value <> 0 then
   Form1.Image1.Canvas.TextOut(mx,my,inttostr(field[y+1,x+1].value));
  end;
 end;

 Form1.lbl_points.caption := IntToStr(points);
 Form1.Image1.refresh;

 if won() and notShown then begin
 showmessage('Herzlichen Glückwunsch ' + name +  ', du hast die ' + IntToStr(win) +' erreicht!');
 notShown := false;
 end;
end;

//____TEST_OB_FELD_VOLL___||___TESTING_FIELD_FOR_FREE_SPACES____
function isFull(simpleCheck:Char):Boolean;
var noCellsFree : Boolean;
    y,x : Integer;
begin

 noCellsFree := true;

 if simpleCheck = 'n' then begin
 for y := 1 to 4 do begin
    for x := 1 to 4 do begin
     if field[y,x].value = tile_null.value then begin
        noCellsFree := false;
     end
     else if (field[y,x].value=field[y+1,x].value) and (y + 1 < 5)  then begin
        noCellsFree := false;
     end
     else if (field[y,x].value=field[y-1,x].value) and (y - 1 > 0) then begin
        noCellsFree := false;
     end
     else if (field[y,x].value=field[y,x+1].value) and (x + 1 < 5) then begin
        noCellsFree := false;
     end
     else if (field[y,x].value=field[y,x-1].value) and (x - 1 > 0) then begin
        noCellsFree := false;
     end;
    end;
  end;
  end
 else begin
  for y := 1 to 4 do begin
    for x := 1 to 4 do begin
     if field[y,x].value = tile_null.value then begin
        noCellsFree := false;
     end;
 end;
    end;
  end;

 result := noCellsFree;

end;

//____ERZEUGUNG_EINES_NEUEN_SPIELSTEINS___||___GENERATING_NEW_TILE____
procedure generateNewTile(rounds : Integer);
var x,y,i,spawnFour : Integer;
begin

 if isFull('n') then begin
   showmessage('Verloren');
   if points > highscore then begin
   sl:=TStringList.Create;
   highscore := points;
   try
     sl.Add(IntToStr(points));
     sl.SaveToFile('highscore.txt');
   finally
     sl.free
   end;
   end;
 end
 else begin
 for i := 1 to rounds do begin

  if isFull('y') then begin
    end
  else begin
    repeat
      x := random(4)+1;
      y := random(4)+1;
    until field[y,x].value = 0;

    spawnFour := random(100)+1;
    if spawnFour < 80 then begin
    field[y,x].value := 2;
    field[y,x].caption := '2';
    field[y,x].color := colors[2];
    end
    else begin
     field[y,x].value := 4;
    field[y,x].caption := '4';
    field[y,x].color := colors[4];
    end;
    drawField();
  end;
 end;
end;
end;

//________ZURÜCKSETZEN___||___RESET________
procedure reset();
var x,y :Integer;
begin

 points := 0;

 for y := 1 to 4 do begin
    for x := 1 to 4 do begin
       field[y,x].value := tile_null.value;
       field[y,x].color := tile_null.color;
       field[y,x].caption := tile_null.caption;
    end;
  end;

 Form1.lbl_points.caption := IntToStr(points);
 Form1.lbl_highscore.caption := IntToStr(highscore);

 notShown := true;

 generateNewTile(2);


end;

//________SPIELSTEINE_HOCH___||___TILES_UP________
procedure onUp();
var x,y,i: integer;
begin

for x:=1 to 4 do begin
for y:=1 to 3 do begin
i := y+1;
while ((field[i-1,x].value) = 0) and (i > 1) do begin
   field[i-1,x].value:=field[i,x].value;
   field[i-1,x].color:=field[i,x].color;
   field[i,x].value:= 0;
   field[i,x].color:= RGBToColor(255,255,255);
   i -= 1;

end;

end;
end;

for x:=1 to 4 do begin
for y:=1 to 3 do begin
if (field[y,x].value) = (field[y+1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y+1,x].value;
   points += field[y,x].value;
   field[y+1,x].value:=0;
   if field[y,x].value < 2049 then begin
   field[y,x].color := colors[field[y,x].value];
   end
   else  field[y,x].color := colors[1];
end;
end;
end;

for x:=1 to 4 do begin
for y:=1 to 3 do begin
i := y+1;
while ((field[i-1,x].value) = 0) and (i > 1) do begin
   field[i-1,x].value:=field[i,x].value;
   field[i-1,x].color:=field[i,x].color;
   field[i,x].value:= 0;
   field[i,x].color:= RGBToColor(255,255,255);
   i -= 1;
end;
end;
end;

drawField();
Form1.Image1.refresh;
sleep(100);

 generateNewTile(1);
end;

//________SPIELSTEINE_RUNTER___||___TILES_DOWN________
procedure onDown();
var x,y,i: integer;
begin


for x:=1 to 4 do begin
for y:=4 downto 1 do begin
i := y+1;
while ((field[i,x].value) = 0) and (i < 5) do begin
   field[i,x].value:=field[i-1,x].value;
   field[i,x].color:=field[i-1,x].color;
   field[i-1,x].value:= 0;
   field[i-1,x].color:= RGBToColor(255,255,255);
   i += 1;
end;
end;
end;

for x:=1 to 4 do begin
for y:=4 downto 2 do begin
if (field[y,x].value) = (field[y-1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y-1,x].value;
   points += field[y,x].value;
   field[y-1,x].value:=0;
   field[y-1,x].color := colors[0];
   if field[y,x].value < 2049 then begin
   field[y,x].color := colors[field[y,x].value];
   end
   else  field[y,x].color := colors[1];
end;
end;
end;

for x:=1 to 4 do begin
for y:=4 downto 1 do begin
i := y+1;
while ((field[i,x].value) = 0) and (i < 5) do begin
   field[i,x].value:=field[i-1,x].value;
   field[i,x].color:=field[i-1,x].color;
   field[i-1,x].value:= 0;
   field[i-1,x].color:= RGBToColor(255,255,255);
   i += 1;
end;
end;
end;
 drawField();
 Form1.Image1.refresh;
 sleep(100);

 generateNewTile(1);
end;

//________SPIELSTEINE_NACH_RECHTS___||___TILES_TO_THE_RIGHT________
procedure onRight();
var y,x,i: integer;
begin

 for y:=1 to 4 do begin
for x:=3 downto 1 do begin
 i := x+1;
 while ((field[y,i].value) = 0) and (i < 5) do begin
    field[y,i].value:=field[y,i-1].value;
    field[y,i].color:=field[y,i-1].color;
    field[y,i-1].value:= 0;
    field[y,i-1].color:= RGBToColor(255,255,255);
    inc(i);
 end;
 end;
 end;

 for y:=1 to 4 do begin
 for x:=3 downto 1 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x+1].value:=field[y,x].value+ field[y,x+1].value;
    points += field[y,x+1].value;
    field[y,x].value:=0;
    field[y,x].color := colors[0];
    if field[y,x+1].value < 2049 then begin
   field[y,x+1].color := colors[field[y,x+1].value];
   end
   else  field[y,x+1].color := colors[1];
 end;
 end;
 end;

 for y:=1 to 4 do begin
for x:=3 downto 1 do begin
 i := x+1;
 while ((field[y,i].value) = 0) and (i < 5) do begin
    field[y,i].value:=field[y,i-1].value;
    field[y,i].color:=field[y,i-1].color;
    field[y,i-1].value:= 0;
    field[y,x-1].color := colors[0];
    field[y,i-1].color:= RGBToColor(255,255,255);
    inc(i);
 end;
 end;
 end;


  drawField();
 Form1.Image1.refresh;
 sleep(100);

  generateNewTile(1);

end;
//________SPIELESTEINE_NACH_LINKS___||___TILES_TO_THE_LEFT________
procedure onLeft();
var y,x,i: integer;
begin


for y:=1 to 4 do begin
for x:=2 to 4 do begin
 i := x-1;
 while (field[y,i].value = 0) and (i > 0) do begin
    field[y,i].value:=field[y,i+1].value;
    field[y,i].color:=field[y,i+1].color;
    field[y,i+1].value:= 0;
    field[y,i+1].color:= RGBToColor(255,255,255);
    i -= 1;
 end;
 end;
 end;

for y:=1 to 4 do begin
 for x:=1 to 3 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x].value:=field[y,x].value+ field[y,x+1].value;
    points += field[y,x].value;
    field[y,x+1].value:=0;
    field[y,x+1].color := colors[0];
   if field[y,x].value < 2049 then begin
   field[y,x].color := colors[field[y,x].value];
   end
   else  field[y,x].color := colors[1];
 end;
 end;
 end;

for y:=1 to 4 do begin
for x:=2 to 4 do begin
 i := x-1;
 while ((field[y,i].value) = 0) and (i > 0) do begin
    field[y,i].value:=field[y,i+1].value;
    field[y,i].color:=field[y,i+1].color;
    field[y,i+1].value:= 0;
    field[y,i+1].color:= RGBToColor(255,255,255);
    i -= 1;
 end;
 end;
 end;

drawField();
Form1.Image1.refresh;
sleep(100);

  generateNewTile(1);
 end;

//________INITIALISIERUNG___||___INITALIZATION________
procedure TForm1.FormCreate(Sender: TObject);
var i: Integer;
begin

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Brush.Style:=bsSolid;
  Image1.Canvas.Clear;
  Image1.Canvas.Clear; //Durch einen Bug in Lazarus wird es bei nur einem Mal ausführen schwarz gefärbt

  for i:= 0 to 2048 do begin

  case i of
  0: colors[i]:=RGBToColor(255,255,255);
  2: colors[i]:=RGBToColor(238,228,218);
  4: colors[i]:=RGBToColor(237,224,200);
  8: colors[i]:=RGBToColor(242,177,121);
  16: colors[i]:=RGBToColor(245,149,99);
  32: colors[i]:=RGBToColor(246,124,95);
  64: colors[i]:=RGBToColor(246,94,59);
  128: colors[i]:=RGBToColor(237,207,114);
  256: colors[i]:=RGBToColor(237,204,97);
  512: colors[i]:=RGBToColor(237,200,80);
  1024: colors[i]:=RGBToColor(237,197,63);
  2048: colors[i]:=RGBToColor(237,194,46);
  else colors[i]:=RGBToColor(206,160,0);
  end;
  end;
  sl := TStringList.Create;
  try
  sl.LoadFromFile('highscore.txt');
  lbl_highscore.Caption := sl[0];
  highscore := StrToInt(sl[0]);
  finally
    sl.free;
  end;
  tile_null.value := 0;
  tile_null.caption:= ' ';
  tile_null.color := RGBToColor(255,255,255);
  randomize;
  win := 2048;
  name := '';
  reset();


 end;


//________TASTE_WURDE_GEDRÜCKT___||___KEY_HAS_BEEN_PRESSED________


procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 case key of
 VK_Down: onDown();
 VK_Up: onUp();
 VK_Right: onRight();
 VK_Left: onLeft();
 end;
end;


procedure TForm1.MenuItem2Click(Sender: TObject);
var i : integer;
begin

 for i := 0 to 2048 do begin
 case i of
  0: colors[i]:=RGBToColor(255,255,255);
  2: colors[i]:=RGBToColor(221,236,169);
  4: colors[i]:=RGBToColor(210,230,141);
  8: colors[i]:=RGBToColor(198,225,112);
  16: colors[i]:=RGBToColor(190,220,168);
  32: colors[i]:=RGBToColor(167,209,137);
  64: colors[i]:=RGBToColor(146,196,109);
  128: colors[i]:=RGBToColor(127,177,178);
  256: colors[i]:=RGBToColor(83,151,152);
  512: colors[i]:=RGBToColor(41,125,125);
  1024: colors[i]:=RGBToColor(120,133,149);
  2048: colors[i]:=RGBToColor(72,93,112);
  else colors[i]:=RGBToColor(28,52,78);

  end;
 end;

 drawField();


end;

//________BENUTZER_SETZT_SPIEL_ZURÜCK___||___USER_RESETS_GAME________
procedure TForm1.MenuItem3Click(Sender: TObject);
begin
 reset();
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
var i : integer;
begin

 for i := 0 to 2048 do begin
 case i of
  2: colors[i]:=RGBToColor(238,228,218);
  4: colors[i]:=RGBToColor(237,224,200);
  8: colors[i]:=RGBToColor(242,177,121);
  16: colors[i]:=RGBToColor(245,149,99);
  32: colors[i]:=RGBToColor(246,124,95);
  64: colors[i]:=RGBToColor(246,94,59);
  128: colors[i]:=RGBToColor(237,207,114);
  256: colors[i]:=RGBToColor(237,204,97);
  512: colors[i]:=RGBToColor(237,200,80);
  1024: colors[i]:=RGBToColor(237,197,63);
  2048: colors[i]:=RGBToColor(237,194,46);
  else colors[i]:=RGBToColor(255,255,255);
  end;
  end;
 drawField();
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var i : integer;
begin

 for i := 0 to 2048 do begin
 case i of
  0: colors[i]:=RGBToColor(255,255,255);
  2: colors[i]:=RGBToColor(240,215,193);
  4: colors[i]:=RGBToColor(230,166,183);
  8: colors[i]:=RGBToColor(223,174,203);
  16: colors[i]:=RGBToColor(201,170,204);
  32: colors[i]:=RGBToColor(197,127,177);
  64: colors[i]:=RGBToColor(218,112,135);
  128: colors[i]:=RGBToColor(230,155,123);
  256: colors[i]:=RGBToColor(249,228,77);
  512: colors[i]:=RGBToColor(204,209,57);
  1024: colors[i]:=RGBToColor(189,206,163);
  2048: colors[i]:=RGBToColor(130,196,192);
  else colors[i]:=RGBToColor(167,196,226);
  end;
  end;
 drawField();

end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin

 Form2.ShowModal;

end;




//EOF
end.

