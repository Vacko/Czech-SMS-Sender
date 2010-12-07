unit Sadd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, shellapi, main, StdCtrls, ComCtrls, ImgList, jpeg, ExtCtrls;

type
  TForm3 = class(TForm)
    XPManifest1: TXPManifest;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Sadd_name: TEdit;
    Sadd_surname: TEdit;
    Sadd_number: TEdit;
    Sadd_operator: TComboBox;
    Sadd_bnumber: TComboBox;
    MCZoperators: TImageList;
    Image1: TImage;
    Image2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Sadd_operatorChange(Sender: TObject);
    procedure Sadd_operatorDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  his : integer;

implementation

uses
 countries_operators, Scontact_list, Shistory_unit,
 O2, TMobile, vodafone;

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
var
 i : integer;
begin
  Form3.Caption := Pname + ' - Add Friend';
  Form3.Position:=poMainFormCenter;
  Sadd_operator.Clear;
  Sadd_bnumber.Clear;

  for i := Low(O_Czech_Republic) to High(O_Czech_Republic) do
   Sadd_operator.Items.Add(O_Czech_Republic[i]);
  for i := Low(N_tmobile) to High(N_tmobile) do
   Sadd_bnumber.Items.Add(IntToStr(N_tmobile[i]));

  Sadd_operator.ItemIndex := 0;
  Sadd_bnumber.ItemIndex := 0;
  his := 0;

  SetWindowLong(Sadd_number.Handle, GWL_STYLE, GetWindowLong(Sadd_number.Handle, GWL_STYLE) or ES_NUMBER);
end;

procedure TForm3.Image2Click(Sender: TObject);
var
 NextItem: TlistItem;
 i : integer;
begin
if ((length(Sadd_name.Text) > 0) or (length(Sadd_surname.Text) > 0)) and (length(Sadd_number.Text) = 6) then
begin
try
 New(Contacts);
 Contacts^.Jmeno := Sadd_name.Text;
 Contacts^.Primeni:= Sadd_surname.Text;
 Contacts^.Cislo := Sadd_bnumber.Text+Sadd_number.Text;
 Contacts^.operator1 := Trim(Sadd_operator.Text);
 Contacts^.country := 'Czech Republic';
 Contacts^.kolikrat := 0;

  NextItem := main.form5.number_list.Items.Add;
  NextItem.Caption:= Contacts^.Jmeno+' '+Contacts^.Primeni+'('+IntToStr(Contacts^.kolikrat)+'x)';

   if Contacts^.country = 'Czech Republic' then
    NextItem.SubItems.Add('+420' + Contacts^.Cislo);

  Contact_List.Add(Contacts);

  Contacts_SaveList;

    if his = 1 then
     begin
       for i := 0 to History_List.Count-1 do
        begin
          History := History_List.Items[i];

           if History.Cislo = Sadd_bnumber.Text+Sadd_number.Text then
            begin
              History^.Jmeno := Sadd_name.Text;
              History^.Primeni := Sadd_surname.Text;
            end;
        end;
       history_savelist;
     end;

  Close;
 except
  on exception do
    MessageDlg('Error',mtError,[mbOK],00);
 end;
end else
  MessageDlg('..........',mtError,[mbOK],00);
end;

procedure TForm3.Sadd_operatorChange(Sender: TObject);
var
 i : integer;
begin
 Sadd_bnumber.Clear;

   if Trim(Sadd_operator.Text) = 'T-Mobile' then
     for i := Low(N_tmobile) to High(N_tmobile) do
      Sadd_bnumber.Items.Add(IntToStr(N_tmobile[i]));

   if Trim(Sadd_operator.Text) = 'Vodafone' then
     for i := Low(N_vodafone) to High(N_vodafone) do
      Sadd_bnumber.Items.Add(IntToStr(N_vodafone[i]));

   if Trim(Sadd_operator.Text) = 'O2' then
     for i := Low(N_o2) to High(N_o2) do
      Sadd_bnumber.Items.Add(IntToStr(N_o2[i]));

  Sadd_bnumber.ItemIndex := 0;
end;

procedure TForm3.Sadd_operatorDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
 ComboBox : TComboBox;
 bitmap : TBitmap;
begin
  ComboBox := (Control as TComboBox);
  bitmap := TBitmap.Create;
  try
    MCZoperators.GetBitmap(Index, bitmap);
    with ComboBox.Canvas do
      begin
         Font.Color := clBlack;
            if odSelected in State then
               begin
                Font.Color := clblack;
                Brush.Color := clScrollBar;
               end;
          FillRect(Rect);
        //  TextOut(Rect.Left + 10,Rect.Top + 1, TComboBox(Control).Items[Index]);
          if Bitmap.Handle <> 0 then Draw(Rect.Left + 2, Rect.Top, Bitmap);
          Rect := Bounds(Rect.Left +4 + ComboBox.ItemHeight + 2, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
          DrawText(handle, PChar(ComboBox.Items[Index]), length(ComboBox.Items[index]), Rect, DT_VCENTER+DT_SINGLELINE);
     end;
   finally
    bitmap.Free;
   end;
end;

end.
