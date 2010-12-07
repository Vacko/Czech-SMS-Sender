unit Shistory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Buttons, StdCtrls;

type
  TForm1 = class(TForm)
    historylistof_m: TListView;
    HDelete: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Hmessage: TMemo;
    HResend: TButton;
    HClose: TButton;
    add_tofriends: TButton;
    procedure FormCreate(Sender: TObject);
    procedure HCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure historylistof_mSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure HResendClick(Sender: TObject);
    procedure HDeleteClick(Sender: TObject);
    procedure add_tofriendsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
 Shistory_unit, countries_operators, main, Sadd,
 o2, vodafone, Tmobile;

{$R *.dfm}

procedure TForm1.HResendClick(Sender: TObject);
var
 i : integer;
begin
 main.Form5.Mantenumber.Clear;

 main.Form5.Mtext.Text := Hmessage.Text;
 main.Form5.Mphonenumber.Text := copy(Label10.Caption, 8, 6);


  for I := Low(Countries) to high(Countries) do
   if Countries[i] = Label11.Caption then
     main.Form5.Mcountry.ItemIndex := i;

   if main.Form5.Mcountry.text = 'Czech Republic' then
    begin
      for I := Low(O_Czech_Republic) to high(O_Czech_Republic) do
       if O_Czech_Republic[i] = Label12.Caption then
         main.Form5.Moperator.ItemIndex := i;

       if main.Form5.Moperator.Text = 'T-Mobile' then
         for I := Low(N_tmobile) to high(N_tmobile) do
           main.Form5.Mantenumber.Items.Add(IntToStr(N_tmobile[i]));
            for I := Low(N_tmobile) to high(N_tmobile) do
              if N_tmobile[i] = StrToInt(copy(Label10.Caption, 5, 3)) then
                main.Form5.Mantenumber.ItemIndex := i;

       if main.Form5.Moperator.Text = 'Vodafone' then
         for I := Low(N_vodafone) to high(N_vodafone) do
           main.Form5.Mantenumber.Items.Add(IntToStr(N_vodafone[i]));
            for I := Low(N_vodafone) to high(N_vodafone) do
             if N_vodafone[i] = StrToInt(copy(Label10.Caption, 5, 3)) then
               main.Form5.Mantenumber.ItemIndex := i;

       if main.Form5.Moperator.Text = 'O2' then
         for I := Low(N_o2) to high(N_o2) do
          main.Form5.Mantenumber.Items.Add(IntToStr(N_o2[i]));
           for I := Low(N_o2) to high(N_o2) do
            if N_o2[i] = StrToInt(copy(Label10.Caption, 5, 3)) then
              main.Form5.Mantenumber.ItemIndex := i;
    end;


 main.Form5.operators_settings.ActivePage := Trim(main.Form5.Moperator.Text);
 main.Form5.Length_sms(main.Form5.Moperator.Text);
 Close;
end;

procedure TForm1.HCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TForm1.HDeleteClick(Sender: TObject);
begin
 If historylistof_m.Items.Count > 0 then
  Begin
   History := History_List.Items[historylistof_m.ItemIndex];
   Dispose(History);
   History_List.Delete(historylistof_m.ItemIndex);
   historylistof_m.Items.Delete(historylistof_m.ItemIndex);
   history_savelist;
  end;
end;

procedure TForm1.add_tofriendsClick(Sender: TObject);
begin
  Sadd.Form3.Sadd_name.Clear;
  Sadd.Form3.Sadd_surname.Clear;
  his := 1;
  Sadd.form3.show;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
 history_loadlist;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 history_loadlist;
 Form1.Position:=poMainFormCenter;
 form1.Caption := Pname + ' - History of sent messages';
end;

procedure TForm1.historylistof_mSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
 m, n, o, i : integer;
begin
 if selected then
  begin
    for i := 0 to History_List.Count-1 do
     begin
      History := History_List.Items[i];

      if History.datum = Trim(item.Caption) then
       begin
        Label7.Caption := History.datum;
        Label8.Caption := History.Jmeno + ' ' + History.Primeni;

        if History.country = 'Czech Republic' then
         Label10.Caption := '+420' + History.Cislo;

        Label11.Caption := History.country;
        Label12.Caption := History.operator1;
        Hmessage.Text := History.Text;

        Sadd.Form3.Sadd_number.Text := copy(History.Cislo, 4, 6);
        Sadd.Form3.Sadd_bnumber.Clear;
        if History.country = 'Czech Republic' then
         if History.operator1 = 'T-Mobile' then
          begin
           Sadd.Form3.Sadd_operator.ItemIndex := 0;
            for m := Low(N_tmobile) to high(N_tmobile) do
               Sadd.Form3.Sadd_bnumber.Items.Add(IntToStr(N_tmobile[m]));
                 for m := Low(N_tmobile) to high(N_tmobile) do
                   if N_tmobile[m] = StrToInt(copy(History.Cislo, 1, 3)) then
                     Sadd.Form3.Sadd_bnumber.ItemIndex := m;
           end;
         if History.operator1 = 'Vodafone' then
          begin
           Sadd.Form3.Sadd_operator.ItemIndex := 1;
            for n := Low(N_vodafone) to high(N_vodafone) do
             Sadd.Form3.Sadd_bnumber.Items.Add(IntToStr(N_vodafone[n]));
              for n := Low(N_vodafone) to high(N_vodafone) do
               if N_vodafone[n] = StrToInt(copy(History.Cislo, 1, 3)) then
                 Sadd.Form3.Sadd_bnumber.ItemIndex := n;
          end;
         if History.operator1 = 'O2' then
          begin
           Sadd.Form3.Sadd_operator.ItemIndex := 2;
            for o := Low(N_o2) to high(N_o2) do
             Sadd.Form3.Sadd_bnumber.Items.Add(IntToStr(N_o2[o]));
              for o := Low(N_o2) to high(N_o2) do
               if N_o2[o] = StrToInt(copy(History.Cislo, 1, 3)) then
                 Sadd.Form3.Sadd_bnumber.ItemIndex := o;
          end;
       end;
    end;

   if Trim(Label8.Caption) = '' then add_tofriends.Enabled := True
                                else add_tofriends.Enabled := False;
  end;
end;

end.
