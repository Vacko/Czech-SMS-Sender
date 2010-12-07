unit o2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ExtCtrls, XPMan, ComCtrls, idhttp, PNGImage,
  PNGZLIB;

 type TCZO2SMS = Class(TObject)
    private
      http : Tidhttp;
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
      FLoged : Boolean;
      FImgCode : String;

      Function TextWithoutSpace(Text : String) : String;
      procedure OnlyNumbers(var EditB: TEdit);
      procedure TransPNGtoJPG(filename : String);
      procedure ButtonClicked(sender: TObject);
      function GetId : string;
      function GetExeDir : String;
      function CheckSentSMS : string;
    public
      Procedure LogOut;
      Function LogIn : Boolean;
      Function SendSMSUnlogged : String;
      Function SendSMSlogged : String;
    published
      Property Number: integer read FNumber write FNumber;
      Property MyNumber: integer read FMyNumber write FMyNumber;
       Property UserName: String read FUserName write FUserName;
       Property Password: String read FPassword write FPassword;
      Property Loged: Boolean read FLoged write FLoged;
      Property Text: String read FText write FText;

      Constructor Create(AOwner: TComponent);
      Destructor Destroy;
 End;

const
 N_o2 : array[0..13] of integer = (601, 602, 606, 607, 720, 721, 722, 723, 724, 725, 726, 727, 728, 729);
 CO2min = 60;
 CO2max = 60;
 CO2min_log = 160;

 SMSNSE = 'http://sms.1188.cz/';
 SMSIMG = 'http://sms.1188.cz/captcha/show.png';
 SMSLOG = 'http://sms.1188.cz/public/sms/smslogin.php';
 SMSLOF = 'http://sms.1188.cz/public/sms/smslogout.php';

var
 CZO2SMS : TCZO2SMS;

implementation


Constructor TCZO2SMS.Create(AOwner: TComponent);
begin
 FNumber := 0;
 FMyNumber := 0;
 FUserName := '';;
 FPassword := '';
 FText := '';
 FImgCode := '';
 FLoged := False;

 Params := TStringStream.create('');
 code   := TStringList.Create;


 http := Tidhttp.Create(nil);
 http.AllowCookies:=true;
 http.Request.ContentType := 'application/x-www-form-urlencoded';
 http.Request.Connection:='Keep-Alive';
 http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
 http.HandleRedirects := True;
 http.RedirectMaximum := 15;
end;

Destructor TCZO2SMS.Destroy;
begin
 Params.Free;
 Code.Free;
 http.Free;
end;

Procedure TCZO2SMS.LogOut;
begin
 http.Get(SMSLOF);
 FLoged := False;
end;

procedure TCZO2SMS.OnlyNumbers(var EditB: TEdit);
begin
  SetWindowLong(EditB.Handle, GWL_STYLE, GetWindowLong(EditB.Handle, GWL_STYLE) or ES_NUMBER);
end;

function TCZO2SMS.GetExeDir : String;
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

function TCZO2SMS.TextWithoutSpace(Text : String) : String;
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

procedure TCZO2SMS.TransPNGtoJPG(filename : String);
var
   lPNG: TPNGImage;
   lExt: string;
   lStreamLoaded: boolean;
   lStream: TmemoryStream;
begin
 lExt := ExtractFileExt(filename);
   if (lExt = '.png') then
     begin
      lStreamLoaded := true;
      lStream := TMemoryStream.Create;
      try
       lStream.LoadFromFile(filename);
       lStream.Seek(0, soFromBeginning);
       lPNG := TPNGImage.Create;
       try
        lPNG.LoadFromStream(lStream);
        lStream.Free;
        lStreamLoaded := false;
        Image1.Picture.Bitmap.PixelFormat := lPNG.PixelFormat;
        Image1.Picture.Bitmap.Height := lPNG.Height;
        Image1.Picture.Bitmap.Width := lPNG.Width;
        if lPNG.PixelFormat = pf8Bit then Image1.Picture.Bitmap.Palette := lPNG.Palette;
        Image1.Canvas.Draw(0,0,lPNG);
        Image1.Picture.Bitmap.PaletteModified := true;
       finally
        lPNG.Free;
       end;
      finally
       if lStreamLoaded then lStream.Free;
      end;
     end;
// DeleteFile(filename);
end;

procedure TCZO2SMS.ButtonClicked(sender: TObject);
begin
 FImgCode := edit1.Text;
 imageform.Close;
end;

function TCZO2SMS.GetId : string;
var
 id : string;
 str     : TstringList;
begin
 if not (Pos('document.getElementById', code.Text) = 0) then
   begin
     str := TStringList.Create;
      str.Text := copy(code.Text, Pos('document.getElementById', code.Text) +(length('document.getElementById')), length(code.Text));
      str.Text := copy(str.Text, 3, (length(str.Text)));
      str.Text := copy(str.Text, 1, (Pos(''');', str.Text) - 1));
      id := Trim(Str.text);
   end;
  result := id;
end;


function TCZO2SMS.CheckSentSMS : string;
begin
  if not (Pos('(tzv. captcha)', code.Text) = 0) then    Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wrong Captcha';
  if not (Pos('do fronty a bude', code.Text) = 0) then  Result := 'SmS was successfully sent to ' + IntToStr(FNumber);
end;


Function TCZO2SMS.SendSMSUnlogged : String;
var
  Stream : TFileStream;
begin
    code.Text := http.Get(SMSNSE);

    imageform := TForm.Create(nil);
    imageform.Height := 130;
    imageform.Width := 166;
    imageform.BorderStyle := bsToolWindow;
    imageform.Color := clWhite;
    imageform.Font.Color := clWindowText;
    imageform.Font.Name := 'Sylfaen';
    imageform.Font.Style := [fsBold];
    imageform.Caption := 'Image';
    imageform.Position:=poMainFormCenter;

    edit1 := TEdit.Create(nil);
    edit1.Top := 80;
    edit1.Left := 4;
    edit1.Height := 20;
    edit1.Width := 60;
    edit1.Parent := imageform;

    button1 := Tbutton.Create(nil);
    button1.Top := 80;
    button1.Left := 68;
    button1.Height := 20;
    button1.Width := 88;
    button1.Parent := imageform;
    button1.OnClick := ButtonClicked;
    button1.Caption := 'Send sms';

    image1 := TImage.Create(nil);
    image1.Height := 73;
    image1.Left := 4;
    image1.Top := 4;
    image1.Width := 209;
    image1.Parent := imageform;

 if FileExists(GetExeDir + 'cz_o2.png') then DeleteFile(GetExeDir + 'cz_o2.png');

  Stream := TFileStream.Create(GetExeDir + 'cz_o2.png', fmCreate or fmShareDenyNone);
   try
    http.Get(SMSIMG, Stream);
   except on E: Exception do
   end;
  Stream.Free;

    TransPNGtoJPG(GetExeDir + 'cz_o2.png');
    image1.Picture.LoadFromFile(GetExeDir + 'cz_o2.png');

     try
      imageform.ShowModal;
     finally
      imageform.Free;
     end;
    
  if FileExists(GetExeDir + 'cz_o2.png') then DeleteFile(GetExeDir + 'cz_o2.png');

    FText := TextWithoutSpace(FText);

    Params.SIZE := 0;
    Params.WriteString(GetId + '=1' + '&');
    Params.WriteString('adress=' + IntToStr(FNumber) + '&');
    Params.WriteString('text=' + Trim(FText) + '&');
    Params.WriteString('code=' + Trim(FImgCode) + '&');
    Params.WriteString('send=Odeslat+SMS');

      try
        code.Text := http.post(SMSNSE, Params);
      except on E: Exception do
        Result := 'SMS wasn''t sent - problem with connecting to server';
      end;
      
   Result := CheckSentSMS;
end;


Function TCZO2SMS.LogIn : Boolean;
begin
 Result := False;
 code.Clear;

 Params.SIZE := 0;
 
 Params.WriteString('login=' + Trim(FUserName) + '&');
 Params.WriteString('password=' + Trim(FPassWord));

 try
  code.Text := http.Post(SMSLOG, Params);  
 except on E: Exception do
  Result := False;
 end;

// main.Form5.RichEdit1.Text := code.text;

 if not (Pos('DoĹˇlo k chybÄ›', code.Text) = 0) then
  begin
   Result := False;
   FLoged := False;
  end;
 if not (Pos('uĹľivatel:', code.Text) = 0) then
  begin
   Result := True;
   FLoged := True;
  end;
end;


Function TCZO2SMS.SendSMSlogged : String;
var
  Stream : TFileStream;
begin
    FText := TextWithoutSpace(FText);
    
    Params.SIZE := 0;
    Params.WriteString('adress=' + IntToStr(FNumber) + '&');
    Params.WriteString('text=' + Trim(FText) + '&');
    Params.WriteString('send=Odeslat+SMS');

      try
        code.Text := http.post(SMSNSE, Params);
      except on E: Exception do
        Result := 'SMS wasn''t sent - problem with connecting to server';
      end;

   Result := CheckSentSMS;
end;

end.

