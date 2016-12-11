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
   Form1.Image1.Canvas.TextOut(mx,my,field[y+1,x+1].caption);
  end;
 end;

 Form1.lbl_points.caption := IntToStr(points);

end;

//____ERZEUGUNG_EINES_NEUEN_SPIELSTEINS___||___GENERATING_NEW_TILE____
procedure generateNewTile(rounds : Integer);
var x,y,i,break : Integer;
begin

 for i := 1 to rounds do begin
   break:=0;
    repeat
      x := random(6)+1;
      y := random(6)+1;
      INC(break);
    until (field[x,y].value = tile_null.value) or (break = 46656);

    field[x,y].value := 2;
    field[x,y].caption := '2';
    field[x,y].color := RGBToColor(230,230,230);

    drawField();
 end;

end;

//________ZURÜCKSETZEN___||___RESET________
procedure reset();
var i,j :Integer;
begin

 points := 0;

 for i := 1 to 6 do begin
    for j := 1 to 6 do begin
       field[i,j].value := tile_null.value;
       field[i,j].color := tile_null.color;
       field[i,j].caption := tile_null.caption;
    end;
  end;

 Form1.lbl_points.caption := IntToStr(points);

 generateNewTile(2);


end;

//________SPIELSTEINE_HOCH___||___TILES_UP________
procedure onUp();
begin
 Inc(points);
 generateNewTile(1);
end;

//________SPIELSTEINE_RUNTER___||___TILES_DOWN________
procedure onDown();
begin

 generateNewTile(1);
end;

//________SPIELSTEINE_NACH_RECHTS___||___TILES_TO_THE_RIGHT________
procedure onRight();
begin

 generateNewTile(1);
end;
//________SPILESTEINE_NACH_LINKS___||___TILES_TO_THE_LEFT________
procedure onLeft();
begin

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

