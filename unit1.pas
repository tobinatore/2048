unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, LCLType,
  StdCtrls, ExtCtrls, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    btn_reset: TButton;
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
    procedure btn_resetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

 type a_container = array[1..6,1..6] of r_tile;

 var
  Form1: TForm1;
  tile_null : r_tile;
  field: a_container;
  points : Integer;

implementation

{$R *.lfm}

{ TForm1 }
procedure drawField();
var x,y,mx,my : Integer;
begin

 for y := 0 to 5 do begin
  for x := 0 to 5 do begin
   Form1.Image1.Canvas.Brush.Color := field[y+1,x+1].color;
   Form1.Image1.Canvas.Rectangle(x*90,y*90,(x+1)*90,(y+1)*90);
   mx := (x*90+(x+1)*90) Div 2 - 3;
   my := (y*90+(y+1)*90) Div 2 - 5;
   Form1.Image1.Canvas.TextOut(mx,my,inttostr(field[y+1,x+1].value));
  end;
 end;

 Form1.lbl_points.caption := IntToStr(points);

end;

//____TEST_OB_FELD_VOLL___||___TESTING_FIELD_FOR_FREE_SPACES____
function isFull():Boolean;
var noCellsFree : Boolean;
    y,x : Integer;
begin

 noCellsFree := true;

 for y := 1 to 6 do begin
    for x := 1 to 6 do begin
     if field[y,x].value = tile_null.value then noCellsFree := false;
    end;
  end;

 result := noCellsFree;

end;

//____ERZEUGUNG_EINES_NEUEN_SPIELSTEINS___||___GENERATING_NEW_TILE____
procedure generateNewTile(rounds : Integer);
var x,y,i : Integer;
begin

 if isFull() then begin
   showmessage('Verloren');
 end
 else begin
 for i := 1 to rounds do begin

    repeat
      x := random(6)+1;
      y := random(6)+1;
    until field[y,x].value = 0;

    field[y,x].value := 2;
    field[y,x].caption := '2';
    field[y,x].color := RGBToColor(230,230,230);

    drawField();
 end;
end;
end;

//________ZURÜCKSETZEN___||___RESET________
procedure reset();
var x,y :Integer;
begin

 points := 0;

 for y := 1 to 6 do begin
    for x := 1 to 6 do begin
       field[y,x].value := tile_null.value;
       field[y,x].color := tile_null.color;
       field[y,x].caption := tile_null.caption;
    end;
  end;

 Form1.lbl_points.caption := IntToStr(points);

 generateNewTile(2);


end;

//________SPIELSTEINE_HOCH___||___TILES_UP________
procedure onUp();
var x,y,i: integer;
begin

for x:=1 to 6 do begin
for y:=1 to 5 do begin
if (field[y,x].value) = (field[y+1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y+1,x].value;
   field[y+1,x].value:=0; //erst mit Verschiebung sinnvoll
end;
i := y+1;
while ((field[i-1,x].value) = 0) and (i > 1) do begin
   field[i-1,x].value:=field[i,x].value;
   field[i-1,x].color:=field[i,x].color;
   field[i,x].value:= 0;
   field[i,x].color:= RGBToColor(255,255,255);//erst mit Verschiebung sinnvoll
   i -= 1;
end;
end;
end;

for x:=1 to 6 do begin
for y:=1 to 5 do begin
if (field[y,x].value) = (field[y+1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y+1,x].value;
   field[y+1,x].value:=0; //erst mit Verschiebung sinnvoll
end;
end;
end;

 generateNewTile(1);
end;

//________SPIELSTEINE_RUNTER___||___TILES_DOWN________
procedure onDown();
var x,y,i: integer;
begin

for x:=1 to 6 do begin
for y:=6 downto 2 do begin
if (field[y,x].value) = (field[y-1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y-1,x].value;
   field[y-1,x].value:=0; //erst mit Verschiebung sinnvoll
end;
end;
end;

for x:=1 to 6 do begin
for y:=1 to 5 do begin
i := y+1;
while ((field[i,x].value) = 0) and (i < 7) do begin
   field[i,x].value:=field[i-1,x].value;
   field[i,x].color:=field[i-1,x].color;
   field[i-1,x].value:= 0;
   field[i-1,x].color:= RGBToColor(255,255,255);//erst mit Verschiebung sinnvoll
   i += 1;
end;
end;
end;

for x:=1 to 6 do begin
for y:=6 downto 2 do begin
if (field[y,x].value) = (field[y-1,x].value) then begin
   field[y,x].value:= field[y,x].value+ field[y-1,x].value;
   field[y-1,x].value:=0; //erst mit Verschiebung sinnvoll
end;
end;
end;

 generateNewTile(1);
end;

//________SPIELSTEINE_NACH_RECHTS___||___TILES_TO_THE_RIGHT________
procedure onRight();
var y,x,i: integer;
begin

 for y:=1 to 6 do begin
 for x:=6 downto 2 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x+1].value:=field[y,x].value+ field[y,x+1].value;
    field[y,x].value:=0; //erst mit Verschiebung sinnvoll
 end;
 end;
 end;

 for y:=1 to 6 do begin
for x:=5 downto 1 do begin
 i := x+1;
 while ((field[y,i].value) = 0) and (i < 7) do begin
    field[y,i].value:=field[y,i-1].value;
    field[y,i].color:=field[y,i-1].color;
    field[y,i-1].value:= 0;
    field[y,i-1].color:= RGBToColor(255,255,255);//erst mit Verschiebung sinnvoll
    inc(i);
 end;
 end;
 end;

 for y:=1 to 6 do begin
 for x:=6 downto 2 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x+1].value:=field[y,x].value+ field[y,x+1].value;
    field[y,x].value:=0; //erst mit Verschiebung sinnvoll
 end;
 end;
 end;

  generateNewTile(1);

end;
//________SPIELESTEINE_NACH_LINKS___||___TILES_TO_THE_LEFT________
procedure onLeft();
var y,x,i: integer;
begin

for y:=1 to 6 do begin
 for x:=1 to 5 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x].value:=field[y,x].value+ field[y,x+1].value;
    field[y,x+1].value:=0; //erst mit Verschiebung sinnvoll
 end;
 end;
 end;

for y:=1 to 6 do begin
for x:=2 to 6 do begin
 i := x-1;
 while ((field[y,i].value) = 0) and (i > 0) do begin
    field[y,i].value:=field[y,i+1].value;
    field[y,i].color:=field[y,i+1].color;
    field[y,i+1].value:= 0;
    field[y,i+1].color:= RGBToColor(255,255,255);//erst mit Verschiebung sinnvoll
    i -= 1;
 end;
 end;
 end;

for y:=1 to 6 do begin
 for x:=1 to 5 do begin
 if (field[y,x].value) = (field[y,x+1].value) then begin
    field[y,x].value:=field[y,x].value+ field[y,x+1].value;
    field[y,x+1].value:=0; //erst mit Verschiebung sinnvoll
 end;
 end;
 end;
  generateNewTile(1);
 end;

//________INITIALISIERUNG___||___INITALIZATION________
procedure TForm1.FormCreate(Sender: TObject);
begin

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Brush.Style:=bsSolid;
  Image1.Canvas.Clear;
  Image1.Canvas.Clear; //Durch einen Bug in Lazarus wird es bei nur einem Mal ausführen schwarz gefärbt


  tile_null.value := 0;
  tile_null.caption:= ' ';
  tile_null.color := RGBToColor(255,255,255);
  randomize;
  reset();

end;

//________BENUTZER_SETZT_SPIEL_ZURÜCK___||___USER_RESETS_GAME________
procedure TForm1.btn_resetClick(Sender: TObject);
begin

 reset();
end;



//________TASTE_WURDE_GEDRÜCKT___||___KEY_HAS_BEEN_PRESSED________
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

 case key of
 VK_Down: onDown();
 VK_Up: onUp();
 VK_Right: onRight();
 VK_Left: onLeft();
 end;

end;




//EOF
end.

