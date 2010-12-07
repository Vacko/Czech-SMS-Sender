unit Scontact_list;

interface
uses Classes;
               
type
  PContacts = ^TContacts;
  TContacts = record
   Jmeno     : String[30];
   Primeni   : String[30];
   Cislo     : String[20];
   country   : String[20];
   operator1 : String[20];
   kolikrat  : Integer;
end;

var
  Contact_List : TList;
  Contacts : PContacts;

 procedure contacts_create;
 procedure contacts_destroy;
 procedure contacts_SaveList;
 procedure contacts_LoadList;

 function GetExeDir : String;

implementation
 uses
  Dialogs,SysUtils, main, ComCtrls;

procedure contacts_create;
begin
 try
  contact_List := TList.Create;
 except
  on exception do
    MessageDlg('Error creating list',mtError,[mbOK],0);
 end;
end;

procedure contacts_destroy;
begin
 try
  While contact_List.Count > 0 do
    Begin
     contacts := contact_List.Items[0];
     Dispose(contacts);
     contact_List.Delete(0);
   end;
  contact_List.Free;
 except
  on exception do
    MessageDlg('Error in canceling the List',mtError,[mbOK],0);
 end;
end;

procedure contacts_SaveList;
var
 F:TFileStream;
 Otevren:Boolean;
 I:Byte;
begin
 If contact_List.Count > 0 then
   Begin
    Otevren := False;
      try try
       F := TFileStream.Create(GetExeDir+'contacts.smv',fmCreate);
       Otevren := True;
         For I := 0 to contact_List.Count-1 do
          Begin
           contacts := contact_List.Items[I];
           F.WriteBuffer(contacts^,SizeOf(contacts^));
          end;
       except
        on exception do
          MessageDlg('Error creating file',mtError,[mbOK],0);
       end;
       finally
        If Otevren = True then F.Free;
       end;
   end else
    MessageDlg('The list is empty',mtError,[mbOK],0);
end;

procedure contacts_LoadList;
var
 F:TFileStream;
 Otevren:Boolean;
 NextItem: TlistItem;
begin

 While contact_List.Count>0 do
   Begin
    contacts := contact_List.Items[0];
    Dispose(contacts);
    contact_List.Delete(0);
   end;

    main.form5.number_list.Clear;
    Otevren := False;
    try try
     F := TFileStream.Create(GetExeDir+'contacts.smv',fmOpenRead);
     Otevren := True;
     try
      While F.Position < F.Size do
        Begin
         New(contacts);
         F.ReadBuffer(contacts^,SizeOf(contacts^));
         NextItem := main.form5.number_list.Items.Add;
         NextItem.Caption:= contacts^.Jmeno+' '+contacts^.Primeni+'('+IntToStr(contacts^.kolikrat)+'x)';

          if contacts^.country = 'Czech Republic' then
           NextItem.SubItems.Add('+420' +contacts^.Cislo);

         contact_List.Add(contacts);
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
 