unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, shellapi, XPMan, ImgList, ExtCtrls, jpeg;

type
  TForm5 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    sort_by_operators: TComboBox;
    number_list: TListView;
    XPManifest1: TXPManifest;
    GroupBox3: TGroupBox;
    MantenumberCountry: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Mphonenumber: TEdit;
    Mantenumber: TComboBox;
    Moperator: TComboBox;
    Mcountry: TComboBox;
    GroupBox4: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Msmscount: TLabel;
    Label7: TLabel;
    Msmslong: TLabel;
    maxchars: TLabel;
    Msmscountmax: TLabel;
    Label9: TLabel;
    Mtext: TMemo;
    GroupBox5: TGroupBox;
    operators_settings: TNotebook;
    GroupBox6: TGroupBox;
    Label8: TLabel;
    Label10: TLabel;
    t_mobile_username: TEdit;
    t_mobile_password: TEdit;
    t_mobile_login: TButton;
    t_mobile_logout: TButton;
    GroupBox7: TGroupBox;
    t_mobile_normal: TRadioButton;
    t_mobile_display: TRadioButton;
    GroupBox8: TGroupBox;
    t_mobile_yes: TRadioButton;
    t_mobile_no: TRadioButton;
    GroupBox9: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    o2_username: TEdit;
    o2_password: TEdit;
    o2_login: TButton;
    o2_logout: TButton;
    Mcountriesimglist: TImageList;
    MCZoperators: TImageList;
    main_editfriend: TImage;
    main_addfriend: TImage;
    main_deletefriend: TImage;
    main_history: TImage;
    main_sendmessage: TImage;
    main_end: TImage;
    main_updates: TImage;
    main_updates_up: TImage;
    procedure FormCreate(Sender: TObject);
    procedure McountryChange(Sender: TObject);
    procedure MoperatorChange(Sender: TObject);
    procedure McountryDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Length_sms(operator1 : string);
    procedure MtextChange(Sender: TObject);
    procedure number_listSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure o2_loginClick(Sender: TObject);
    procedure o2_logoutClick(Sender: TObject);
    procedure t_mobile_logoutClick(Sender: TObject);
    procedure t_mobile_loginClick(Sender: TObject);
    procedure MoperatorDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure sort_by_operatorsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure main_addfriendClick(Sender: TObject);
    procedure main_deletefriendClick(Sender: TObject);
    procedure main_historyClick(Sender: TObject);
    procedure main_sendmessageClick(Sender: TObject);
    procedure main_endClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

uses
 Sadd, countries_operators, Scontact_list, Shistory_unit, Shistory,
 
 O2, TMobile, vodafone;  // CZ operators

{$R *.dfm}

procedure TForm5.FormCreate(Sender: TObject);
var
i : integer;
Stream : TFileStream;
begin
 if not FileExists('contacts.smv') then
  begin
   Stream := TFileStream.Create(GetExeDir + 'contacts.smv', fmCreate or fmShareDenyNone);
   Stream.Free;
  end;
 if not FileExists('history.smv') then
  begin
   Stream := TFileStream.Create(GetExeDir + 'history.smv', fmCreate or fmShareDenyNone);
   Stream.Free;
  end;

 history_createlist;
 Contacts_create;

 Contacts_LoadList;

 form5.Left := trunc(screen.Width / 2 - form5.Width / 2);
 form5.top := trunc(screen.height / 2 - form5.Height / 2);
 SetWindowLong(Mphonenumber.Handle, GWL_STYLE, GetWindowLong(Mphonenumber.Handle, GWL_STYLE) or ES_NUMBER);
 SetWindowLong(o2_username.Handle, GWL_STYLE, GetWindowLong(o2_username.Handle, GWL_STYLE) or ES_NUMBER);

  for i := Low(Countries) to High(Countries) do
   Mcountry.Items.Add(Countries[i]);

  for i := Low(O_Czech_Republic) to High(O_Czech_Republic) do
   begin
    Moperator.Items.Add(O_Czech_Republic[i]);
    sort_by_operators.Items.Add(O_Czech_Republic[i]);
   end;
  for i := Low(N_tmobile) to High(N_tmobile) do
   Mantenumber.Items.Add(IntToStr(N_tmobile[i]));

 sort_by_operators.Items.Add('All');
 sort_by_operators.ItemIndex := 3;
 Mcountry.ItemIndex := 0;
 Moperator.ItemIndex := 0;
 Mantenumber.ItemIndex := 0;

 operators_settings.ActivePage := Trim(Moperator.Text);
 GroupBox5.Caption := ' SMS Settings - ' + Trim(Moperator.Text) + ' ';
 MantenumberCountry.Caption := '+420';
 Form5.Caption := Pname;


 MobileSMS := TMobileSMS.Create(nil);
 CZO2SMS   := TCZO2SMS.Create(nil);
 CZVODAFONESMS := TCZVODAFONESMS.Create(nil);

 Length_sms(Moperator.Text);
end;

procedure TForm5.FormDestroy(Sender: TObject);
begin
 history_destroylist;
 Contacts_destroy;

 MobileSMS.Free;
 CZO2SMS.Free;
 CZVODAFONESMS.Free;
end;

procedure TForm5.McountryChange(Sender: TObject);
var
 i : integer;
begin
 Moperator.Items.Clear;
 Mantenumber.Items.Clear;
 sort_by_operators.Items.Clear;

 if Trim(Mcountry.Text) = 'Czech Republic' then
  begin
    for i := Low(O_Czech_Republic) to High(O_Czech_Republic) do
     begin
      Moperator.Items.Add(O_Czech_Republic[i]);
      sort_by_operators.Items.Add(O_Czech_Republic[i]);
     end;
    for i := Low(N_tmobile) to High(N_tmobile) do
      Mantenumber.Items.Add(IntToStr(N_tmobile[i]));
  end;

 sort_by_operators.Items.Add('All');
 Contacts_LoadList;
 sort_by_operators.ItemIndex := sort_by_operators.Items.Count-1;
 Moperator.ItemIndex := 0;
 Mantenumber.ItemIndex := 0;
 operators_settings.ActivePage := Trim(Moperator.Text);
 Length_sms(Moperator.Text);
end;

procedure TForm5.MoperatorChange(Sender: TObject);
var
i : integer;
begin
 Mantenumber.Clear;

 if Trim(Mcountry.Text) = 'Czech Republic' then
  begin
   if Trim(Moperator.Text) = 'T-Mobile' then
     for i := Low(N_tmobile) to High(N_tmobile) do
      Mantenumber.Items.Add(IntToStr(N_tmobile[i]));

   if Trim(Moperator.Text) = 'Vodafone' then
     for i := Low(N_vodafone) to High(N_vodafone) do
      Mantenumber.Items.Add(IntToStr(N_vodafone[i]));

   if Trim(Moperator.Text) = 'O2' then
     for i := Low(N_o2) to High(N_o2) do
      Mantenumber.Items.Add(IntToStr(N_o2[i]));
  end;

  Mantenumber.ItemIndex := 0;
  Length_sms(Moperator.Text);

  operators_settings.ActivePage := Trim(Moperator.Text);
  GroupBox5.Caption := ' SMS Settings - ' + Trim(Moperator.Text) + ' ';
end;

procedure TForm5.MtextChange(Sender: TObject);
begin
 Length_sms(Moperator.Text);
end;

procedure TForm5.number_listSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  i,m,n,o,p : integer;
  cislo : string;
begin
if selected then
 begin
  try
    for i:=0 to Contact_List.Count-1 do
     begin
       Contacts:=Contact_List.Items[i];

        if Contacts.country = 'Czech Republic' then
           cislo := '+420' + Contacts.Cislo;

       if cislo = Trim(item.SubItems.Text) then
        begin
         Mantenumber.Clear;

          if Trim(Mcountry.Text) = 'Czech Republic' then
            begin
             if Contacts.operator1 = 'T-Mobile' then
              begin
                Moperator.ItemIndex := 0;
                for m := Low(N_tmobile) to High(N_tmobile) do
                  Mantenumber.Items.Add(IntToStr(N_tmobile[m]));
              end;

             if Contacts.operator1 = 'Vodafone' then
              begin
               Moperator.ItemIndex := 1;
               for m := Low(N_vodafone) to High(N_vodafone) do
                 Mantenumber.Items.Add(IntToStr(N_vodafone[m]));
              end;

             if Contacts.operator1 = 'O2' then
              begin
               Moperator.ItemIndex := 2;
               for m := Low(N_o2) to High(N_o2) do
                Mantenumber.Items.Add(IntToStr(N_o2[m]));
              end;
           end;

          Mantenumber.ItemIndex := 0;
          Length_sms(Moperator.Text);

          operators_settings.ActivePage := Trim(Moperator.Text);
          GroupBox5.Caption := ' SMS Settings - ' + Trim(Moperator.Text) + ' ';

          if Trim(Moperator.Text) = 'T-Mobile' then
            for n := Low(N_tmobile) to High(N_tmobile) do
              if StrToInt(copy(Contacts.Cislo, 1,3)) = N_tmobile[n] then
                Mantenumber.ItemIndex := n;
          if Trim(Moperator.Text) = 'Vodafone' then
            for o := Low(N_vodafone) to High(N_vodafone) do
              if StrToInt(copy(Contacts.Cislo, 1,3)) = N_vodafone[o] then
                Mantenumber.ItemIndex := o;
          if Trim(Moperator.Text) = 'O2' then
            for p := Low(N_o2) to High(N_o2) do
              if StrToInt(copy(Contacts.Cislo, 1,3)) = N_o2[p] then
                Mantenumber.ItemIndex := p;
          Mphonenumber.Text := copy(Contacts.Cislo, 4, 6);
          //item.Selected := false;
        end;
    end;
 except
  on exception do
    MessageDlg('Error Searching',mtError,[mbOK],0);
 end;
 end;
end;

procedure TForm5.Length_sms(operator1 : string);
var
 maxSMS, maxChars1, minChars1 : integer;
 cop : string;
begin
 if Trim(Mcountry.Text) = 'Czech Republic' then
  begin
   if (Trim(operator1) = 'T-Mobile') and (MobileSMS.Loged = false) then
    begin
       minChars1 := Ctmobilemin;
       maxSMS    := 1;
       maxChars1 := Trunc(maxSMS*minChars1);
    end;
   if (Trim(operator1) = 'T-Mobile') and (MobileSMS.Loged) then
    begin
       minChars1 := Ctmobilemin;
       maxSMS    := 5;
       maxChars1 := Trunc(maxSMS*minChars1);
    end;
  if (Trim(operator1) = 'Vodafone') and (CZVODAFONESMS.Loged = false) then
    begin
       minChars1 := CVodafonemin;
       maxSMS    := 5;
       maxChars1 := Trunc(maxSMS*minChars1);
    end;
  if (Trim(operator1) = 'O2') and (CZO2SMS.Loged = false) then
    begin
     minChars1 := CO2min;
     maxSMS    := 1;
     maxChars1 := Trunc(maxSMS*minChars1);
    end;
  if (Trim(operator1) = 'O2') and (CZO2SMS.Loged) then
    begin
     minChars1 := CO2min_log;
     maxSMS    := 1;
     maxChars1 := Trunc(maxSMS*minChars1);
    end;
  end;

 Mtext.MaxLength := maxChars1;   

 if length(Mtext.Text) > Mtext.MaxLength then
  begin
   cop := copy(Mtext.Text, 1, Mtext.MaxLength);
   Mtext.Lines.Clear;
   Mtext.Text := cop;
  end;

 maxchars.Caption := IntToStr(length(Mtext.Text)) + '/ ' + IntToStr(maxChars1);
 Msmscount.Caption := Inttostr(length(Mtext.Text) div minChars1);
 Msmslong.Caption := InttoStr(length(Mtext.Text) mod minChars1) + ' / ' + IntToStr(minChars1) + ' Chars';
 Msmscountmax.Caption := '/ ' + IntToStr(maxSMS);

 if length(Mtext.Text) >= maxChars1 then
  begin
   Msmslong.Font.Color := clred;
   Msmscountmax.Font.Color := clred;
   Msmscount.Font.Color := clred;
   maxchars.Font.Color := clred;
  end else
  begin
   Msmslong.Font.Color := clblack;
   Msmscountmax.Font.Color := clblack;
   Msmscount.Font.Color := clblack;
   maxchars.Font.Color := clblack;
  end;
 
end;


procedure TForm5.main_addfriendClick(Sender: TObject);
begin
  Sadd.Form3.Sadd_name.Clear;
  Sadd.Form3.Sadd_surname.Clear;
  Sadd.Form3.Sadd_number.Clear;
  his := 0;
  Sadd.form3.show;
end;

procedure TForm5.main_deletefriendClick(Sender: TObject);
begin
 If number_list.Items.Count > 0 then
  Begin
   Contacts := Contact_list.Items[number_list.ItemIndex];
   Dispose(Contacts);
   Contact_list.Delete(number_list.ItemIndex);
   number_list.Items.Delete(number_list.ItemIndex);
   Contacts_savelist;
  end else
  
end;

procedure TForm5.main_endClick(Sender: TObject);
begin
 Close;
end;

procedure TForm5.main_historyClick(Sender: TObject);
begin
 Shistory.form1.show;
end;

procedure TForm5.main_sendmessageClick(Sender: TObject);
var
 resul, numb : string;
 i : integer;
begin
 resul := '';
 numb := Trim(Mantenumber.Text + Mphonenumber.Text);
 
if (Length(Mtext.Text) > 0) then
 begin
if (Length(Mphonenumber.Text) = 6) then
 begin
 Form5.Caption := Pname + ' - Sending SMS on number ' + numb;

  if Trim(Mcountry.Text) = 'Czech Republic' then
   begin
    if (Trim(Moperator.Text) = 'T-Mobile') and (MobileSMS.Loged = false) then
     begin
      if t_mobile_normal.Checked then MobileSMS.NormalOrOnDisplaySMS := 0
                                 else MobileSMS.NormalOrOnDisplaySMS := 1;
      MobileSMS.Number := StrtoInt(numb);
      MobileSMS.Text := Mtext.Text;
      resul := MobileSMS.SendSMSUnlogged;
     end;
   if (Trim(Moperator.Text) = 'Vodafone') and (CZVODAFONESMS.Loged = false) then
     begin
      CZVODAFONESMS.Number := StrtoInt(numb);
      CZVODAFONESMS.Text := Mtext.Text;
      CZVODAFONESMS.MyNumber := 0;
      resul := CZVODAFONESMS.SendSMSUnlogged;
     end;
   if (Trim(Moperator.Text) = 'O2') and (CZO2SMS.Loged = false) then
     begin
      CZO2SMS.Number := StrtoInt(numb);
      CZO2SMS.Text := Mtext.Text;
      resul := CZO2SMS.SendSMSUnlogged;
     end;
   if (Trim(Moperator.Text) = 'O2') and (CZO2SMS.Loged) then
     begin
      CZO2SMS.Number := StrtoInt(numb);
      CZO2SMS.Text := Mtext.Text;
      resul := CZO2SMS.SendSMSlogged;
     end;
   end;

   Form5.Caption := resul;

    if resul = 'SmS was successfully sent to ' + numb then
     begin
       for i:=0 to Contact_List.Count-1 do
        begin
          Contacts:=Contact_List.Items[i];
          New(History);
          History^.Jmeno := '';
          History^.Primeni:= '';

           if Contacts.Cislo = Trim(numb) then
            begin
             Contacts.kolikrat := Contacts.kolikrat+1;
             Contacts_SaveList;
             number_list.Clear;
             Contacts_LoadList;

             History^.Jmeno := Contacts.Jmeno;
             History^.Primeni:= Contacts.Primeni;
            end;
         end;

          try
           History^.Cislo := numb;
           History^.operator1 := Moperator.Text;
           History^.text := Mtext.Text;
           History^.country := Mcountry.Text;
           History^.datum := DateToStr(Date) + ' ' + TimeToStr(Time);
           History_list.Add(History);

           history_saveList;
          except
           on exception do
              MessageDlg('Error',mtError,[mbOK],00);
          end;
     end;
 end else
  Form5.Caption := Pname + ' - Wrong number';
 end else
  Form5.Caption := Pname + ' - You must write text of sms';
end;

procedure TForm5.sort_by_operatorsChange(Sender: TObject);
var
 F:TFileStream;
 Otevren:Boolean;
 NextItem: TlistItem;
begin
if not (Trim(sort_by_operators.Text) = 'All') then
begin
 While Contact_List.Count > 0 do
   Begin
    Contacts := Contact_List.Items[0];
    Dispose(Contacts);
    Contact_List.Delete(0);
   end;

    main.form5.number_list.Clear;
    Otevren := False;
    try try
     F := TFileStream.Create(GetExeDir+'contacts.smv',fmOpenRead);
     Otevren := True;
     try
      While F.Position < F.Size do
        Begin
         New(Contacts);
         F.ReadBuffer(Contacts^,SizeOf(Contacts^));
         if Contacts.operator1 = Trim(sort_by_operators.Text) then
          begin
            NextItem := main.form5.number_list.Items.Add;
            NextItem.Caption:= Contacts^.Jmeno+' '+Contacts^.Primeni+'('+IntToStr(Contacts^.kolikrat)+'x)';

             if contacts^.country = 'Czech Republic' then
               NextItem.SubItems.Add('+420' +contacts^.Cislo);

            Contact_List.Add(Contacts);
          end;
        end;
     except
      on exception do
        MessageDlg('Not enough memory',mtError,[mbOK],00);
     end;
    except
     on exception do
      MessageDlg('Error opening file',mtError,[mbOK],0);
    end;
    finally
     If Otevren = True then F.Free;
    end;
end else
 Contacts_LoadList;
end;


////////////////////////////////////////////////////////////////////////////
///
///                          BUTTONS LOG IN
///
///  //////////////////////////////////////////////////////////////////////

procedure TForm5.o2_loginClick(Sender: TObject);
begin
if (length(o2_username.Text) > 0) and (length(o2_password.Text) > 0) then
begin
 CZO2SMS.UserName := o2_username.Text;
 CZO2SMS.Password := o2_password.Text;
 CZO2SMS.MyNumber := StrToInt(o2_username.Text);
 CZO2SMS.LogIn;

 if CZO2SMS.Loged then
  begin
    o2_login.Enabled := False;
    o2_logout.Enabled := True;
    o2_username.Enabled := False;
    o2_password.Enabled := False;
    Length_sms(Moperator.Text);
    Form5.Caption := Pname + ' - Logged as ' + o2_username.Text;
  end else
    Form5.Caption := Pname + ' - Logging in - failed';
end else
  Form5.Caption := Pname + ' - Logging in - failed';
end;

procedure TForm5.t_mobile_loginClick(Sender: TObject);
begin
if (length(t_mobile_username.Text) > 0) and (length(t_mobile_password.Text) > 0) then
begin
 MobileSMS.UserName := t_mobile_username.Text;
 MobileSMS.Password := t_mobile_password.Text;
// MobileSMS.MyNumber := 732669455;
// MobileSMS.LogIn();

 if MobileSMS.Loged then
  begin
    t_mobile_login.Enabled := False;
    t_mobile_logout.Enabled := True;
    t_mobile_username.Enabled := False;
    t_mobile_password.Enabled := False;
    GroupBox6.Enabled := True;
    Length_sms(Moperator.Text);
    Form5.Caption := Pname + ' - Logged as ' + t_mobile_username.Text;
  end else
    Form5.Caption := Pname + ' - Logging in - failed';
end else
 Form5.Caption := Pname + ' - Logging in - failed';
end;

////////////////////////////////////////////////////////////////////////////
///
///                          BUTTONS LOG OUT
///
///  //////////////////////////////////////////////////////////////////////

procedure TForm5.o2_logoutClick(Sender: TObject);
begin
    CZO2SMS.LogOut;
    o2_login.Enabled := True;
    o2_logout.Enabled := False;
    o2_username.Enabled := True;
    o2_password.Enabled := True;
    Length_sms(Moperator.Text);
    Form5.Caption := Pname + ' - Logged out from account ' + o2_username.Text;
end;

procedure TForm5.t_mobile_logoutClick(Sender: TObject);
begin
    MobileSMS.LogOut;
    t_mobile_login.Enabled := True;
    t_mobile_logout.Enabled := False;
    t_mobile_username.Enabled := True;
    t_mobile_password.Enabled := True;
    GroupBox6.Enabled := False;
    Length_sms(Moperator.Text);
    Form5.Caption := Pname + ' - Logged out from account ' + t_mobile_username.Text;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
                       //         DRAWS      //
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure TForm5.McountryDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
 ComboBox : TComboBox;
 bitmap : TBitmap;
begin
  ComboBox := (Control as TComboBox);
  bitmap := TBitmap.Create;
  try
    Mcountriesimglist.GetBitmap(Index, bitmap);
    with ComboBox.Canvas do
      begin
         Font.Color := clBlack;
            if odSelected in State then
               begin
                Font.Color := clblack;
                Brush.Color := clScrollBar;
               end;
          FillRect(Rect);
      //    TextOut(Rect.Left + 1,Rect.Top + 1, TComboBox(Control).Items[Index]);
          if Bitmap.Handle <> 0 then Draw(Rect.Left + 2, Rect.Top, Bitmap);
          Rect := Bounds(Rect.Left +4 + ComboBox.ItemHeight + 2, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
          DrawText(handle, PChar(ComboBox.Items[Index]), length(ComboBox.Items[index]), Rect, DT_VCENTER+DT_SINGLELINE);
     end;
   finally
    bitmap.Free;
   end;
end;

procedure TForm5.MoperatorDrawItem(Control: TWinControl; Index: Integer;
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
