unit vodafone;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ExtCtrls, XPMan, ComCtrls, idhttp, PNGImage,
  PNGZLIB, main;

 type TCZVODAFONESMS = Class(TObject)
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
      Fimgnumber : integer;
       FUserName : String;
       FPassword : String;
      FText : String;
      FLoged : Boolean;
      FImgCode : String;

      Function TextWithoutSpace(Text : String) : String;
      procedure OnlyNumbers(var EditB: TEdit);
      procedure TransPNGtoJPG(filename : String);
      procedure ButtonClicked(sender: TObject);
      function Getimgnumber : string;
      function Getppp : string;
      function GetExeDir : String;
      function CheckSentSMS : string;
    public
//      Procedure LogOut;
//      Function LogIn : Boolean;
      Function SendSMSUnlogged : String;
//      Function SendSMSlogged : String;
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
 N_vodafone : array[0..5] of integer = (608, 773, 774, 775, 776, 777);
 CVodafonemin = 152;
 CVodafonemax = 760;

 SMSNSE = 'http://www.vodafonesms.cz/';
 SMSNSN = 'http://www.vodafonesms.cz/send.php';
 SMSIMG = 'http://www.vodafonesms.cz/imgcode.php';

var
 CZVODAFONESMS : TCZVODAFONESMS;

implementation

Constructor TCZVODAFONESMS.Create(AOwner: TComponent);
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

Destructor TCZVODAFONESMS.Destroy;
begin
 Params.Free;
 Code.Free;
 http.Free;
end;

procedure TCZVODAFONESMS.OnlyNumbers(var EditB: TEdit);
begin
  SetWindowLong(EditB.Handle, GWL_STYLE, GetWindowLong(EditB.Handle, GWL_STYLE) or ES_NUMBER);
end;

function TCZVODAFONESMS.GetExeDir : String;
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

function TCZVODAFONESMS.TextWithoutSpace(Text : String) : String;
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
     Result := text;
end;

procedure TCZVODAFONESMS.TransPNGtoJPG(filename : String);
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

procedure TCZVODAFONESMS.ButtonClicked(sender: TObject);
begin
 FImgCode := edit1.Text;
 imageform.Close;
end;

function TCZVODAFONESMS.Getimgnumber;
var
 numb : string;
 str     : TstringList;
begin
 if not (Pos('imgid', code.Text) = 0) then
   begin
     str := TStringList.Create;
      str.Text := copy(code.Text, Pos('imgid', code.Text), length(code.Text));
      str.Text := copy(str.Text, (Pos('value="', str.Text) + 7), (length(str.Text)));
      str.Text := copy(str.Text, 1, (Pos('" />', str.Text) - 1));
      numb := Trim(Str.text);
   end;
  result := numb;
end;

function TCZVODAFONESMS.Getppp;
var
 ppp : string;
 str     : TstringList;
begin
 if not (Pos('ppp', code.Text) = 0) then
   begin
     str := TStringList.Create;
      str.Text := copy(code.Text, Pos('ppp', code.Text), length(code.Text));
      str.Text := copy(str.Text, (Pos('value="', str.Text) + 7), (length(str.Text)));
      str.Text := copy(str.Text, 1, (Pos('" />', str.Text) - 1));
      ppp := Trim(Str.text);
   end;
  result := ppp;
end;

function TCZVODAFONESMS.CheckSentSMS : string;
begin
  if not (Pos('Neopsali jste', code.Text) = 0) then            Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Wrong Captcha';
  if not (Pos('nemůžeme zprávu doručit', code.Text) = 0) then  Result := 'SmS wasn''t sent - ' + IntToStr(FNumber) + ' Recipient is not a Vodafone network member';
  if not (Pos('petrol">SMS zpr', code.Text) = 0) then          Result := 'SmS was successfully sent to ' + IntToStr(FNumber);
end;

Function TCZVODAFONESMS.SendSMSUnlogged : String;
var
  Stream : TFileStream;
begin
    code.Text := http.Get(SMSNSE);

    imageform := TForm.Create(nil);
    imageform.Height := 120;
    imageform.Width := 150;
    imageform.BorderStyle := bsToolWindow;
    imageform.Color := clWhite;
    imageform.Font.Color := clWindowText;
    imageform.Font.Name := 'Sylfaen';
    imageform.Font.Style := [fsBold];
    imageform.Caption := 'Image';
    imageform.Position:=poMainFormCenter;

    edit1 := TEdit.Create(nil);
    edit1.Top := 70;
    edit1.Left := 4;
    edit1.Height := 20;
    edit1.Width := 50;
    edit1.Parent := imageform;
    OnlyNumbers(edit1);

    button1 := Tbutton.Create(nil);
    button1.Top := 70;
    button1.Left := 58;
    button1.Height := 20;
    button1.Width := 80;
    button1.Parent := imageform;
    button1.OnClick := ButtonClicked;
    button1.Caption := 'Send sms';

    image1 := TImage.Create(nil);
    image1.Height := 73;
    image1.Left := 4;
    image1.Top := 4;
    image1.Width := 209;
    image1.Parent := imageform;

 if FileExists(GetExeDir + 'cz_vodafone.png') then DeleteFile(GetExeDir + 'cz_vodafone.png');

  Stream := TFileStream.Create(GetExeDir + 'cz_vodafone.png', fmCreate or fmShareDenyNone);
   try
    http.Get(SMSIMG + '?id=' + Getimgnumber, Stream);
   except on E: Exception do
   end;
  Stream.Free;

    TransPNGtoJPG(GetExeDir + 'cz_vodafone.png');
    image1.Picture.LoadFromFile(GetExeDir + 'cz_vodafone.png');

     try
      imageform.ShowModal;
     finally
      imageform.Free;
     end;

  if FileExists(GetExeDir + 'cz_vodafone.png') then DeleteFile(GetExeDir + 'cz_vodafone.png');

    FText := TextWithoutSpace(FText);

    Params.SIZE := 0;

    Params.WriteString('imgid=' + Getimgnumber + '&');
    Params.WriteString('ppp=' + Getppp + '&');
    Params.WriteString('number=' + IntToStr(FNumber) + '&');
    Params.WriteString('mynumber=' + IntToStr(FMyNumber) + '&');
//    Params.WriteString('sender=a&');
    Params.WriteString('message=' + Trim(FText) + '&');
    Params.WriteString('char_in=' + IntToStr(Length(FText)) + '&');
    Params.WriteString('char_le=' + IntToStr(CVodafonemax - Length(FText)) + '&');
    Params.WriteString('parts=' + Inttostr((Length(FText) div CVodafonemin) + 1) + '&');
    Params.WriteString('pictogram=' + Trim(FImgCode) + '&');
    Params.WriteString('send=Odeslat!');


      try
        code.Text := http.post(SMSNSN, Params);
      except on E: Exception do
        Result := 'SMS wasn''t sent - problem with connecting to server';
      end;

   Result := CheckSentSMS;
end;

end.

