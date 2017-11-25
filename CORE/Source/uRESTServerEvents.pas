unit uRESTServerEvents;

interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData;

Type
 TDWReplyEvent = Procedure(Var Params         : TDWParams;
                           Var Result         : String) Of Object;

Type
 TDWReplyEventData = Class(TComponent)
 Private
  vReplyEvent : TDWReplyEvent;
 Public
  Property    OnReplyEvent : TDWReplyEvent Read vReplyEvent    Write vReplyEvent;
End;

Type
 PDWParamMethod = ^TDWParamMethod;
 TDWParamMethod = Class(TCollectionItem)
 Private
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vDefaultValue,
  vParamName       : String;
  vEncoded         : Boolean;
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
 Published
  Property TypeObject      : TTypeObject      Read vTypeObject      Write vTypeObject;
  Property ObjectDirection : TObjectDirection Read vObjectDirection Write vObjectDirection;
  Property ObjectValue     : TObjectValue     Read vObjectValue     Write vObjectValue;
  Property ParamName       : String           Read GetDisplayName   Write SetDisplayName;
  Property Encoded         : Boolean          Read vEncoded         Write vEncoded;
  Property DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
End;

Type
 TDWParamsMethods = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index     : Integer) : TDWParamMethod;  Overload;
  Procedure   PutRec    (Index     : Integer;
                         Item      : TDWParamMethod);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index    : Integer);                   Overload;
  Property    Items      [Index    : Integer]   : TDWParamMethod Read GetRec Write PutRec; Default;
End;

Type
 PDWEvent = ^TDWEvent;
 TDWEvent = Class(TCollectionItem)
 Protected
 Private
  FName       : String;
  vDWParams   : TDWParamsMethods;
  vOwnerCollection : TCollection;
  DWReplyEventData : TDWReplyEventData;
  Function  GetReplyEvent : TDWReplyEvent;
  Procedure SetReplyEvent(Value : TDWReplyEvent);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    DWParams     : TDWParamsMethods Read vDWParams      Write vDWParams;
  Property    Name         : String           Read GetDisplayName Write SetDisplayName;
  Property    OnReplyEvent : TDWReplyEvent    Read GetReplyEvent  Write SetReplyEvent;
End;

Type
 TDWEventList = Class(TOwnedCollection)
 Protected
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index      : Integer) : TDWEvent;  Overload;
  Procedure   PutRec    (Index      : Integer;
                         Item       : TDWEvent);            Overload;
  Procedure   ClearList;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index     : Integer);             Overload;
  Property    Items      [Index     : Integer]  : TDWEvent  Read GetRec Write PutRec; Default;
End;

Type
 TDWServerEvents = Class(TComponent)
 Protected
 Private
  vEventList      : TDWEventList;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
 Published
  Property Events : TDWEventList Read vEventList Write vEventList;
End;

implementation

{ TDWEvent }

Function TDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWEvent.Create(aCollection: TCollection);
begin
  inherited;
  vDWParams        := TDWParamsMethods.Create(aCollection, TDWParamMethod);
  DWReplyEventData := TDWReplyEventData.Create(Nil);
  vOwnerCollection := aCollection;
  FName            := 'dwevent' + IntToStr(aCollection.Count);
  DWReplyEventData.Name := FName;
end;

destructor TDWEvent.Destroy;
begin
  vDWParams.Free;
  DWReplyEventData.Free;
  inherited;
end;

Function TDWEvent.GetDisplayName: String;
Begin
 Result := DWReplyEventData.Name;
End;

Procedure TDWEvent.Assign(Source: TPersistent);
begin
 If Source is TDWEvent then
  Begin
   FName       := TDWEvent(Source).Name;
   vDWParams   := TDWEvent(Source).DWParams;
   DWReplyEventData.OnReplyEvent := TDWEvent(Source).OnReplyEvent;
  End
 Else
  Inherited;
End;

Function TDWEvent.GetReplyEvent: TDWReplyEvent;
Begin
 Result := DWReplyEventData.OnReplyEvent;
End;

Procedure TDWEvent.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Event Name')
 Else
  Begin
   FName := Value;
   DWReplyEventData.Name := FName;
   Inherited;
  End;
End;

procedure TDWEvent.SetReplyEvent(Value: TDWReplyEvent);
begin
 DWReplyEventData.OnReplyEvent := Value;
end;

procedure TDWEventList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

Constructor TDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := TDWEvent(inherited GetItem(Index));
end;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

{ TDWServerEvents }

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited Create(AOwner);
 vEventList := TDWEventList.Create(Self, TDWEvent);
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
End;

procedure TDWParamsMethods.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(I);
 Self.Clear;
End;

constructor TDWParamsMethods.Create(AOwner     : TPersistent;
                                    aItemClass : TCollectionItemClass);
begin
 Inherited Create(AOwner, TDWParamMethod);
 Self.fOwner := AOwner;
end;

procedure TDWParamsMethods.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWParamsMethods.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TDWParamsMethods.GetRec(Index: Integer): TDWParamMethod;
Begin
 Result := TDWParamMethod(inherited GetItem(Index));
End;

procedure TDWParamsMethods.PutRec(Index: Integer; Item: TDWParamMethod);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

Constructor TDWParamMethod.Create(aCollection: TCollection);
Begin
 Inherited;
 vTypeObject      := toParam;
 vObjectDirection := odINOUT;
 vObjectValue     := ovString;
 vParamName       :=  'dwparam' + IntToStr(aCollection.Count);
 vEncoded         := True;
 vDefaultValue    := '';
End;

function TDWParamMethod.GetDisplayName: String;
begin
 Result := vParamName;
end;

procedure TDWParamMethod.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Param Name')
 Else
  Begin
   vParamName := Trim(Value);
   Inherited;
  End;
end;

end.
