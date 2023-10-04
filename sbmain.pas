unit sbmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, ComCtrls, Spin;

type

  { Tsb }

  Tsb = class(TForm)
    bDeck: TSpinEdit;
    bGun: TSpinEdit;
    bMaint: TSpinEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    equip: TCheckGroup;
    GroupBox1: TGroupBox;
    gcspeed: TGroupBox;
    Label10: TLabel;
    cspeed: TListBox;
    lspeed: TLabel;
    smod: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lgearwt: TLabel;
    nwAdd: TButton;
    nwPosition: TComboBox;
    nwName: TComboBox;
    hull: TComboBox;
    Label1: TLabel;
    msg: TLabel;
    ldisplacement: TLabel;
    sDeck: TEdit;
    sGun: TEdit;
    sMaint: TEdit;
    weapons: TStringGrid;
    procedure equipItemClick(Sender: TObject; Index: integer);
    procedure hullChange(Sender: TObject);
    procedure nwAddClick(Sender: TObject);
    procedure skillChange(Sender: TObject);
    procedure weaponsButtonClick(Sender: TObject; aCol, aRow: Integer);
  private

  public
    function isWeaponValid(t:integer; pos:integer):boolean;
    function areWeaponsValid:boolean;
    function equipWeight(t:integer):integer;
    function speed(gear,cargo:integer; skill:single):integer;
    procedure recalc;
  end;

var
  sb: Tsb;

implementation

const SHK_MERCHANT=0;
const SHK_WARSHIP= 1;
const hulldata:array of array[1..16] of integer=
({    Cost,  ECost, Hull, Slots, MxWeight, Sail, MxCargo, MxContra, MxPeople,MxSpeed, HDDec, Accel, MinLvl, FreeWpn, FreeCrg,     Kind     }
 (  100000,      0,   10,     1,     5,      20,    1,        0,       1,     100,    50,     35,       0,      0,       0,   SHK_MERCHANT ),
 (  300000,      0,   25,     4,    12,      40,    3,        0,       2,     100,    45,     28,       0,      2,       0,   SHK_MERCHANT ),
 ( 1500000,      0,  110,     6,    55,      90,   10,        1,       5,      88,    30,     22,      20,      8,       6,   SHK_MERCHANT ),
 ( 2500000,      0,  150,     8,    75,     100,   20,        3,       8,      78,    20,     17,      25,     10,       8,   SHK_MERCHANT ),
 ( 4000000,      0,  200,     8,   100,     110,   35,        6,      10,      68,    13,     13,      30,     13,      12,   SHK_MERCHANT ),
 ( 8000000,      0,  260,    10,   130,     120,   50,        9,      15,      58,     8,     10,      35,     16,      24,   SHK_MERCHANT ),
 (12000000,      0,  330,    12,   165,     130,   70,       12,      20,      50,     6,      8,      40,     19,      40,   SHK_MERCHANT ),

 ( 9000000,      0,  165,     6,    82,     120,    0,        0,       6,      74,    20,     20,      31,     13,       0,   SHK_WARSHIP  ),
 (15000000,      0,  220,     8,   110,     130,    0,        0,       8,      64,    13,     14,      36,     16,       0,   SHK_WARSHIP  ),
 (22000000,      0,  285,    10,   142,     140,    0,        0,      10,      55,     8,     10,      41,     20,       0,   SHK_WARSHIP  ),
 (36000000,      0,  400,    12,   200,     160,    0,        0,      15,      48,     5,      8,      46,     25,       0,   SHK_WARSHIP  ),
 (       0,      0,  600,    14,   300,     200,    0,        0,      20,      40,     4,      6,      51,     32,       0,   SHK_WARSHIP  )
);

const weapondata:array of array[1..16] of integer=
({   Cost  Frags Weight Ammo    Min     Max     Min     Max  Fragments Damage  Sail   Hull    Sail    Armor   Reload  Volley}
 {                             range   range  damage  damage   count     arc    hit  damage  damage  pierce     time    time}
 (  50000,    0,    3,   60,      0,      8,      2,      4,      1,      10,   12,    100,     50,     10,      30,      7 ), //small ball
 ( 100000,    0,    6,   50,      0,     10,      4,      6,      1,      10,   14,    100,     50,     10,      30,      8 ), //med ball
 ( 500000,    0,   10,   30,      0,     12,      6,      9,      1,      10,   16,    100,     50,     10,      30,     10 ), //lrg ball
 ( 500000,    0,   10,   30,      4,     15,      2,      3,      4,     160,   20,    100,    100,      2,      30,     18 ), //small cat
 ( 800000,    0,   13,   20,      5,     20,      2,      4,      5,     260,   20,    100,    100,      2,      30,     24 ), //med cat
 (1200000,    0,   17,   12,      6,     25,      2,      5,      6,     360,   20,    100,    100,      2,      30,     30 ), //large cat
 (1000000,    0,   15,    6,      0,      4,     15,     22,      1,      10,    0,    100,      0,     15,      30,      3 ), //hvy ball
 (4000000, 1600,    7,   40,      0,     20,      4,     16,      1,      10,   10,    100,     30,     15,      45,      0 ), //light beam
 (5000000, 1800,    9,   40,      0,     23,      5,     22,      1,      10,   10,    100,     30,     15,      45,      0 ), //heavy beam
 (4000000, 1700,    5,   50,      0,     20,      0,      0,      1,     360,    0,      0,      0,      0,      45,      0 ), //mind blast
 (5000000, 1900,    7,   20,      0,     16,      4,      6,      5,      90,   50,     50,    100,      0,      45,     12 ), //frag cannon
 (5000000, 2000,    9,    6,     12,     32,      3,      6,      8,     360,   20,    100,    100,      3,      45,     36 )  //long tom
);

const hull_weapon_allowed:array of set of 0..11=
(
 [],                            // sloop
 [0],                           // yacht       smbal only
 [0,1,3,9],                     // clipper     sm/md bal, smcat, frag
 [0..4,7,9,10],                 // ketch       no lgcat hvbal hvbeam longtom
 [0..7,9,10],                   // caravel     all but hvbeam longtom
 [0..11],                       // carrack
 [0..11],                       // galleon
 [0..4,7,9,10],                 // corvette
 [0..10],                       // destroyer   all but long tom
 [0..11],                       // frigate
 [0..11],                       // cruiser
 [0..11]                        // Cyric
);

const arcdata:array of array[0..3,0..3] of integer=
({    Weapon slots            Weapon weight                  Armor                   Internal        }
 { Fwrd Port Rear Stbd      Fwrd Port Rear Stbd       Fwrd Port Rear Stbd       Fwrd Port Rear Stbd  }
( (  0,   0,   0,   0 ),   (  0,   0,   0,   0 ),   (   2,   3,   1,   3 ),   (   1,   1,   1,   1 ) ), // Sloop
( (  1,   1,   1,   1 ),   (  3,   5,   3,   5 ),   (   6,   8,   4,   8 ),   (   3,   4,   2,   4 ) ), // Yacht
( (  1,   2,   1,   2 ),   ( 10,  13,  10,  13 ),   (  29,  36,  18,  36 ),   (  14,  18,   9,  18 ) ), // Clipper
( (  1,   2,   1,   2 ),   ( 13,  20,  13,  20 ),   (  40,  50,  25,  50 ),   (  20,  25,  12,  25 ) ), // Ketch
( (  1,   3,   1,   3 ),   ( 17,  26,  17,  26 ),   (  53,  66,  33,  66 ),   (  26,  33,  16,  33 ) ), // Caravel
( (  1,   3,   1,   3 ),   ( 21,  31,  21,  31 ),   (  69,  86,  43,  86 ),   (  34,  43,  21,  43 ) ), // Carrack
( (  2,   3,   1,   3 ),   ( 26,  35,  26,  35 ),   (  88, 110,  55, 110 ),   (  44,  55,  27,  55 ) ), // Galleon

( (  1,   3,   1,   3 ),   ( 13,  32,  13,  32 ),   (  50,  63,  37,  63 ),   (  22,  27,  13,  27 ) ), // Corvette
( (  2,   3,   1,   3 ),   ( 27,  38,  27,  38 ),   (  67,  84,  50,  84 ),   (  29,  36,  18,  36 ) ), // Destroyer
( (  2,   3,   2,   3 ),   ( 31,  44,  31,  44 ),   (  87, 109,  65, 109 ),   (  38,  47,  23,  47 ) ), // Frigate
( (  2,   4,   2,   4 ),   ( 35,  50,  35,  50 ),   ( 122, 153,  91, 153 ),   (  53,  66,  33,  66 ) ), // Cruiser
( (  3,   5,   2,   5 ),   ( 51,  75,  51,  75 ),   ( 183, 229, 138, 229 ),   (  79,  99,  49,  99 ) )  // Dreadnought
);

{$R *.lfm}

{ Tsb }

procedure Tsb.hullChange(Sender: TObject);
begin
  ldisplacement.Caption:=inttostr(hulldata[hull.ItemIndex, 3]);
  if hull.ItemIndex<2
    then begin
      equip.Checked[0]:=false;
      equip.Checked[1]:=false;
    end;
  areWeaponsValid;
  recalc;
end;

procedure Tsb.equipItemClick(Sender: TObject; Index: integer);
begin
  // only sloops and yachts are restricted
  if (index<2) and (hull.ItemIndex<2) and equip.Checked[index]
    then begin
      equip.Checked[index]:=false;
      msg.Caption:='can''t have this item on a hull so small';
    end;
end;

procedure Tsb.nwAddClick(Sender: TObject);
begin
  if not isWeaponValid(nwName.ItemIndex, nwPosition.ItemIndex)
    then exit;
  if not areWeaponsValid
    then exit;
  weapons.InsertRowWithValues(weapons.RowCount, [nwName.Caption, nwPosition.Caption, '-']);
  if not areWeaponsValid
    then weapons.DeleteRow(weapons.RowCount-1);
  recalc;
end;

procedure Tsb.skillChange(Sender: TObject);
begin
  recalc;
end;

procedure Tsb.weaponsButtonClick(Sender: TObject; aCol, aRow: Integer);
begin
  if (aCol=2) and (aRow>0) and (aRow<=weapons.RowCount)
    then weapons.DeleteRow(aRow);
  areWeaponsValid;
  recalc;
end;

function Tsb.isWeaponValid(t: integer; pos: integer): boolean;
var
  err:string;
begin
  if (t<0) or (t>Length(weapondata))
    then begin result:=false; exit end;
  if ((pos=0) or (pos=2)) and (t=6) // only heavy bal
    then err:='weapon not allowed in chase position';
  if ((pos=1) or (pos=3)) and not (t in [0,1,2,6,7,8,9])
    then err:='weapon not allowed on broadside position';
  if not (t in hull_weapon_allowed[hull.ItemIndex])
    then err:='weapon not compatible with this hull';
  msg.Caption:=err;
  result:=err='';
end;

function Tsb.areWeaponsValid: boolean;
var
  i,cap,t,side,h:integer;
  sidecnt,sidewt:array[0..3] of integer;
  err,kind,pos:string;
begin
  result:=false;
  h:=hull.ItemIndex;
  cap:=0;
  for i:=0 to 3
    do sidecnt[i]:=0;
  for i:=0 to 3
    do sidewt[i]:=0;
  for i:=1 to weapons.RowCount-1 do begin
    kind:=weapons.Cells[0,i];
    t:=weapons.Columns[0].PickList.IndexOf(kind);
    if (t<0) or (t>=length(weapondata))
      then begin msg.Caption:='invalid weapon type';exit end;
    pos:=weapons.Cells[1,i];
    side:=weapons.Columns[1].PickList.IndexOf(pos);
    if (side<0) or (side>3)
      then begin msg.Caption:='invalid weapon side';exit end;
    inc(sidecnt[side]);
    inc(sidewt[side], weapondata[t,3]);
    if t>=7
      then inc(cap);
  end;

  if sidewt[0]+sidewt[1]+sidewt[2]+sidewt[3]>hulldata[h,5]
    then err:='too much weapon weight';
  if cap>1
    then err:='too many capital weapons';
  for i:=0 to 3
    do if arcdata[h,0,i]<sidecnt[i]
         then err:='too many weapons on side: '+weapons.Columns[1].PickList.Strings[i];
  for i:=0 to 3
    do if arcdata[h,1,i]<sidewt[i]
         then err:='too much weapon weight on side: '+weapons.Columns[1].PickList.Strings[i];
  msg.Caption:=err;
  result:=err=''
end;

function Tsb.equipWeight(t: integer): integer;
var
  hullwt:integer;
begin
  hullwt:=hulldata[hull.ItemIndex, 3];
  case t of
    0: result:=(hullwt+10) div 24;
    1: result:=(hullwt+50) div 40;
  end;
end;

function Tsb.speed(gear, cargo: integer; skill: single): integer;
var
  h,max:integer;
  s:single;
begin
  h:=hull.ItemIndex;
  cargo:=cargo*2-hulldata[h,15];
  if cargo<0
    then cargo:=0;

  max:=hulldata[h,10];
  s:=max;
  s:=s*(1.0+skill);
  s:=s*(1.0-(gear+cargo)/hulldata[h,5]);
  if s<1
    then result:=1
    else if s>max
           then result:=max
           else result:=trunc(s)
end;

procedure Tsb.recalc;
var
  wt,i,h,maxwt:integer;
  deck_skill, repa_skill:single;
begin
  h:=hull.ItemIndex;
  maxwt:=hulldata[h,5];

  wt:=0;
  for i:=1 to weapons.RowCount-1
    do inc(wt, weapondata[weapons.Columns[0].PickList.IndexOf(weapons.Cells[0,i]), 3]);
  for i:=0 to 2
    do if equip.Checked[i]
         then inc(wt, equipWeight(i));
  lgearwt.Caption:=inttostr(wt);
  if wt>maxwt
    then msg.Caption:='too much gear weight';
  dec(wt, hulldata[h,14]);
  if wt<0
    then wt:=0;

  deck_skill:=0;
  try
    deck_skill:=sqrt(strtoint(sDeck.Text))/150 + bDeck.Value*0.03;
    repa_skill:=sqrt(strtoint(sMaint.Text))/150 + bMaint.Value*0.03;
    deck_skill:=(deck_skill*8+repa_skill*2)/10;
  except
    deck_skill:=0;
    msg.Caption:='skills invalid';
  end;
  smod.Caption:=format('%6.2f', [deck_skill]);

  lspeed.Caption:=inttostr(speed(wt,0,deck_skill));
  gcspeed.Enabled:=hulldata[h,16]=0;
  cspeed.Clear;
  for i:=1 to hulldata[h,7]
    do cspeed.Items.Add('%2d'#9'%3d', [i,speed(wt,i,deck_skill)]);
end;



end.

