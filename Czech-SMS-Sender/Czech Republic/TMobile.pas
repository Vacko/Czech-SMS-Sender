unit TMobile;

interface

uses
 Windows, Dialogs, Graphics, SysUtils, Classes, idhttp, IdSSLOpenSSL,
 IdSSLOpenSSLHeaders, ComCtrls, ExtCtrls, jpeg, forms, StdCtrls, IdSSL;

 type TMobileSMS = Class(TObject)
    private
      http : Tidhttp;
//      SSL : TIdSSLIOHandlerSocketOpenSSL;
      SSLIOHandler: TIdSSLIOHandlerSocketBase;
      Params : TStringStream;
      code : TStringList;

      imageform : TForm;
      image1 : Timage;
      edit1  : Tedit;
      button1: Tbutton;

      FNumber : integer;
      FMyNumber : integer;
       FUserName : String;
       FPassword : String;
      FText : String;
      FNormalorOnDisplaySMS : integer;
      FReceiptOfTheReport : integer;
      FLoged : Boolean;
      FImgCode : String;

      Function GetExeDir : String;
      Function TextWithoutSpace(Text : String) : String;
      Function CheckSentSMS : string;
      Function GetCounter : string;
       Function CheckNumber(Number : Integer) : Boolean;
      procedure OnlyNumbers(var EditB: TEdit);
      procedure ButtonClicked(sender: TObject);
    public
      Function LogIn(RichEdit : TRichEdit) : Boolean;
      Procedure LogOut;
      Function SendSMSUnlogged : String;
    published
      Property Number: integer read FNumber write FNumber;
      Property MyNumber: integer read FMyNumber write FMyNumber;
       Property UserName: String read FUserName write FUserName;
       Property Password: String read FPassword write FPassword;
      Property Loged: Boolean read FLoged write FLoged;
      Property Text: String read FText write FText;
      Property NormalOrOnDisplaySMS : Integer read FNormalorOnDisplaySMS write FNormalorOnDisplaySMS default 0;
      Property ReceiptOfTheReport : Integer read FReceiptOfTheReport write FReceiptOfTheReport default 0;

      Constructor Create(AOwner: TComponent);
      Destructor Destroy;
 End;

 const
  N_tmobile : array[0..12] of integer = (603, 604, 605, 730, 731, 732, 733, 734, 735, 736, 737, 738, 739);
  Ctmobilemin = 160;
  Ctmobilemax_nolog = 160;
  Ctmobilemax_log = 765;

  SMSLSE = 'https://sms1.client.tmo.cz/closed.jsp';
  SMSNSE = 'http://sms.t-zones.cz/open.jsp';
  SMSLOG = 'https://www1.t-mobile.cz/.gang/login/tzones';
  SMSLOF = 'https://www.t-mobile.cz/.gang/logout/tzones';
  SMSIMG = 'http://sms.t-zones.cz/open/captcha.jpg';

var
 MobileSMS : TMobileSMS;

implementation

Constructor TMobileSMS.Create(AOwner: TComponent);
begin
 //IdSSLOpenSSLHeaders.Load;

 FNumber := 0;
 FMyNumber := 0;
 FUserName := '';;
 FPassword := '';
 FText := '';
 FImgCode := '';
 FNormalorOnDisplaySMS := 0;
 FReceiptOfTheReport := 0;
 FLoged := False;

 Params := TStringStream.create('');
 code   := TStringList.Create;
 
// SSLIOHandler:= TIdSSLIOHandlerSocketBase.Create;

// SSL := TIdSSLIOHandlerSocketOpenSSL.Create;
// SSL.SSLOptions.Method := sslvSSLv23;
// SSL.SSLOptions.Mode := sslmClient;
// SSL.SSLOptions.VerifyMode := [];
// SSL.SSLOptions.VerifyDepth := 0;
 
 http := Tidhttp.Create(nil);
 http.IOHandler := SSLIOHandler;
 http.AllowCookies:=true;
 http.Request.ContentType := 'application/x-www-form-urlencoded';
 http.Request.Connection:='Keep-Alive';
 http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
 http.HandleRedirects := True;
 http.RedirectMaximum := 15;
end;

Destructor TMobileSMS.Destroy;
begin
 Params.Free;
 Code.Free;
 SSLIOHandler.Free; 
 http.Free;
end;

function TMobileSMS.GetExeDir : String;
var
 x,y:String;
 x2,y2:String;
begin
       x := ParamStr(0);
       y := ExtractFileName(ParamStr(0));
    result:= copy(x,0,length(x) - length(y));
    x2 := ParamStr(0);
       y2 := ExtractFileName(ParamStr(0));
    result:= copy(x2,0,length(x2) - length(y2));
end;

procedure TMobileSMS.OnlyNumbers(var EditB: TEdit);
begin
  SetWindowLong(EditB.Handle, GWL_STYLE, GetWindowLong(EditB.Handle, GWL_STYLE) or ES_NUMBER);
end;

function TMobileSMS.TextWithoutSpace(Text : String) : String;
var
 q : integer;
 g : string;
 f : string;
begin
 if not (Pos(' ', text) = 0) then
   begin
      repeat
        q := Pos(' ', text);
        g := copy(text, 0, q-1);
        delete(text, 1, q);

         f := f + g + '+';

           if Pos(' ', text) = 0 then
             begin
               g := copy(text, 0, length(text));
               f := f + g;
             end;
       Until(Pos(' ', text) = 0);
   end;
    if Pos(' ', text) = 0 then
     Result := F;
end;

Function TMobileSMS.LogIn(RichEdit : TRichEdit) : Boolean;
begin
 Result := False;
 RichEdit.Clear;
 {
 Params.SIZE := 0;

 Params.WriteString('username=' + Trim(FUserName) + '&');
 Params.WriteString('password=' + Trim(FPassWord)+ '&');
 Params.WriteString('nextURL=checkStatus.jsp' + '&');
 Params.WriteString('errURL=clickError.jsp' + '&');
 Params.WriteString('submit=P%F8ihl%E1sit');

 try
  RichEdit.Text := http.Post(SMSLOG, Params);
 //   RichEdit.Text := http.Post('https://www1.t-mobile.cz/.gang/login/portal', Params);
 except on E: Exception do
  Result := False;
 end;

 if not (Pos('Zkuste se pøihlásit znovu', RichEdit.Text) = 0) then
  begin
   Result := False;
   FLoged := False;
  end;
 if not (Pos('Jste pøihlášen jako:', RichEdit.Text) = 0) then
  begin
   Result := True;
   FLoged := True;
  end;
 }
 FLoged := True;
end;

Procedure TMobileSMS.LogOut;
begin
 http.Get(SMSLOF);
 FLoged := False;
end;

Function TMobileSMS.CheckNumber(Number : Integer) : Boolean;
var
 start : String;
 i : integer;
 next, Next2 : Boolean;
begin
  next := False;
  start := Copy(IntToStr(Number), 1, 3);
   for I := Low(N_tmobile) to High(N_tmobile) do
    begin
      if N_tmobile[i] = StrToInt(start) then
        next := True;
    end;
 if Length(IntToStr(Number)) = 9 then Next2 := True
                                 else Next2 := False;
 if (Next) and (Next2) then Result := True
                       else Result := False;
end;

Function TMobileSMS.GetCounter : string;
var
 counter : string;
 str     : TstringList;
begin
 if not (Pos('counter', code.Text) = 0) then
   begin
     str := TStringList.Create;
      str.Text := copy(code.Text, Pos('counter', code.Text), length(code.Text));
      str.Text := copy(str.Text, (Pos('value="', str.Text) + 7), (length(str.Text)));
      str.Text := copy(str.Text, 1, (Pos('" />', str.Text) - 1));
      counter := Trim(Str.text);
   end;
  result := counter;
end;

function TMobileSMS.CheckSentSMS : string;
begin
if not (Pos('error.captcha', code.Text) = 0) then
 begin
   Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wrong Captcha';
 end else
 begin
  if not (Pos('notice.sms.sent.one', code.Text) = 0) then     Result := 'SmS was successfully sent to ' + IntToStr(FNumber);

  if not (Pos('error.delay.required', code.Text) = 0) then    Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wait 30 seconds before the next message can be send';
  if not (Pos('error.captcha', code.Text) = 0) then           Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wrong engrossed image';
  if not (Pos('error.no.text', code.Text) = 0) then           Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' No text in SMS message';
  if not (Pos('error.bad.recipient', code.Text) = 0) then     Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wrong phone number';
  if not (Pos('error.non.TMCZ', code.Text) = 0) then          Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Recipient is not a T-Mobile network member';
  if not (Pos('error.no.Spam', code.Text) = 0) then           Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' The recipient does not wish to receive messages send from open SMS gateway';
  if not (Pos('error.too.long', code.Text) = 0) then          Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Message is too long';
  if not (Pos('error.too.Many', code.Text) = 0) then          Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Too many recipients';
  if not (Pos('error.template.too.long', code.Text) = 0) then Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' The text is too long';
 end;
{
error.repost //  counter code

 				attachmentTooBig: 'The attachment is too big.',
				badRecipient: 'Wrong phone number!',
				nonTMCZ: 'Recipient is not a T-Mobile network member.',
				noSpam: 'The recipient does not wish to receive messages send from open SMS gateway.',
				templatetoolong: 'The text is too long!',
				toolong: 'Message is too long!',
				tooMany: 'Too many recipients!'
}
end;

procedure TMobileSMS.ButtonClicked(sender: TObject);
begin
 FImgCode := edit1.Text;
 imageform.Close;
end;

Function TMobileSMS.SendSMSUnlogged : String;
var
  Stream : TFileStream;
begin
    code.Text := http.Get(SMSNSE);

    imageform := TForm.Create(nil);
    imageform.Height := 110;
    imageform.Width := 223;
    imageform.BorderStyle := bsToolWindow;
    imageform.Color := clWhite;
    imageform.Font.Color := clWindowText;
    imageform.Font.Name := 'Sylfaen';
    imageform.Font.Style := [fsBold];
    imageform.Caption := 'Image';
    imageform.Position:=poMainFormCenter;

    edit1 := TEdit.Create(nil);
    edit1.Top := 60;
    edit1.Left := 4;
    edit1.Height := 20;
    edit1.Width := 100;
    edit1.Parent := imageform;
    OnlyNumbers(edit1);

    button1 := Tbutton.Create(nil);
    button1.Top := 60;
    button1.Left := 108;
    button1.Height := 20;
    button1.Width := 100;
    button1.Parent := imageform;
    button1.OnClick := ButtonClicked;
    button1.Caption := 'Send sms';

    image1 := TImage.Create(nil);
    image1.Height := 73;
    image1.Left := 4;
    image1.Top := 4;
    image1.Width := 209;
    image1.Parent := imageform;

 if FileExists(GetExeDir + 'cz_tmobile.jpg') then DeleteFile(GetExeDir + 'cz_tmobile.jpg');

  Stream := TFileStream.Create(GetExeDir + 'cz_tmobile.jpg', fmCreate or fmShareDenyNone);
   try
    http.Get(SMSIMG, Stream);
   except on E: Exception do
   end;
  Stream.Free;

    image1.Picture.LoadFromFile(GetExeDir + 'cz_tmobile.jpg');

     try
      imageform.ShowModal;
     finally
      imageform.Free;
     end;
    
  if FileExists(GetExeDir + 'cz_tmobile.jpg') then DeleteFile(GetExeDir + 'cz_tmobile.jpg');

    Params.SIZE := 0;

    Params.WriteString('counter=' + GetCounter + '&');
    Params.WriteString('recipient=' + IntToStr(FNumber) + '&');

       if FNormalorOnDisplaySMS = 0 then
        Params.WriteString('mtype=0' + '&');
       if FNormalorOnDisplaySMS = 1 then
        Params.WriteString('mtype=1' + '&');
       if FNormalorOnDisplaySMS > 1 then
        Params.WriteString('mtype=0' + '&');

     FText := TextWithoutSpace(FText);

     Params.WriteString('text=' + Trim(FText) + '&');
     Params.WriteString('cntr2=' + IntToStr(Length(FText)) + '&');
     Params.WriteString('cntr1=' + IntToStr(Trunc(Ctmobilemax_nolog - Length(FText))) + '&');
     Params.WriteString('captcha=' + Trim(FImgCode));

    //   sleep(7000);
      try
        code.Text := http.post(SMSNSE, Params);
      except on E: Exception do
        Result := 'SMS wasn''t sent - problem with connecting to server';
      end;

       Result := CheckSentSMS;
end;

end.






