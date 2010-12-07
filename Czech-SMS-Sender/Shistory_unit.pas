unit Shistory_unit;

interface

uses Classes;

type
  PHistory = ^THistory;
  THistory = record
   Jmeno     : String[30];
   Primeni   : String[30];
   Cislo     : String[20];
   operator1 : String[20];
   country   : String[20];
   datum     : String[20];
   Text      : String[255];
end;

var
  History_List : TList;
  History : PHistory;

 procedure history_createlist;
 procedure history_destroylist;
 procedure history_savelist;
 procedure history_loadlist;
 
 function GetExeDir : String;

implementation

uses
 Dialogs,SysUtils, main, ComCtrls, Shistory;

procedure history_createlist;
begin
 try
  History_List := TList.Create;
 except
  on exception do
    MessageDlg('Error creating list',mtError,[mbOK],0);
 end;
end;

procedure history_destroylist;
begin
 try
  While History_List.Count>0 do
    Begin
     History := History_List.Items[0];
     Dispose(History);
     History_List.Delete(0);
   end;
  History_List.Free;
 except
  on exception do
    MessageDlg('Error in canceling the list',mtError,[mbOK],0);
 end;
end;

procedure history_savelist;
var
 F:TFileStream;
 Otevren:Boolean;
 I:Byte;
begin
 If History_List.Count>0 then
   Begin
    Otevren:=False;
      try try
       F:=TFileStream.Create(GetExeDir+'history.smv',fmCreate);
       Otevren:=True;
         For I:=0 to History_List.Count-1 do
          Begin
           History := History_List.Items[I];
           F.WriteBuffer(History^,SizeOf(History^));
          end;
       except
        on exception do
          MessageDlg('Error creating file',mtError,[mbOK],0);
       end;
       finally
        If Otevren=True then F.Free;
       end;
   end else
    MessageDlg('The list is empty',mtError,[mbOK],0);
end;

procedure history_loadlist;
var
 F:TFileStream;
 Otevren:Boolean;
 NextItem: TlistItem;
begin

 While History_List.Count>0 do
   Begin
    History := History_List.Items[0];
    Dispose(History);
    History_List.Delete(0);
   end;

    Shistory.form1.historylistof_m.clear;
    Otevren:=False;
    try try
     F:=TFileStream.Create(GetExeDir+'history.smv',fmOpenRead);
     Otevren:=True;
     try
      While F.Position<F.Size do
        Begin
         New(History);
         F.ReadBuffer(History^,SizeOf(History^));
         NextItem := Shistory.form1.historylistof_m.Items.Add;
         NextItem.Caption:= History^.datum;
         
           if History^.country = 'Czech Republic' then
             NextItem.SubItems.Add('+420' + History^.Cislo);

         NextItem.SubItems.Add(History^.Text);
         History_List.Add(History);
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
     If Otevren=True then F.Free;
    end;
end;

function GetExeDir : String;
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

end.
