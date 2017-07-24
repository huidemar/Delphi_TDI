unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Menus, Unit4, ImgList, Unit3, Math, Themes, StdCtrls;

type
  TCloseTabSheet = class(TTabSheet)
    protected
      FCloseButtonRect : TRect;
      FOnClose : TNotifyEvent;
      procedure DoClose; virtual;
    public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;
      property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

  TForm2 = class(TForm)
    MainMenu1: TMainMenu;
    Cadastros1: TMenuItem;
    Clientes1: TMenuItem;
    Fornecedores1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Bevel1: TBevel;
    PageControl1: TPageControl;
    PopupMenu: TPopupMenu;
    Fechar1: TMenuItem;
    IL: TImageList;
    Fecharoutrasabas1: TMenuItem;
    DesacoplarFormulrio1: TMenuItem;
    procedure Clientes1Click(Sender: TObject);
    procedure Fornecedores1Click(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
    procedure PageControl1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Fecharoutrasabas1Click(Sender: TObject);
    procedure DesacoplarFormulrio1Click(Sender: TObject);
    procedure CloseTabeProc(Sender: TObject);
    procedure PageControl1DrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure PageControl1MouseLeave(Sender: TObject);
    procedure PageControl1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PageControl1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FCloseButtonMouseDownTab : TCloseTabSheet;
    FCloseButtonShowPushed : Boolean;
    procedure AjustarMenuSistema(Formulario : TForm; IdMenu : Word);

  public
    { Public declarations }
    procedure NovaAba(FormClass : TFormClass; IndiceImagem: Integer);
    procedure AjustarCaptionAbas(ClassForm: TFormClass);
    procedure FecharAba(Aba : TTabSheet); overload;
    procedure FecharAba(Aba : TTabSheet; Outras: Boolean); overload;
    procedure AcoplarFormulario(Aba : TTabSheet);
    procedure DesacoplarFormulario(Aba : TTabSheet);
    function  PodeAbrirFormulario(ClassForm: TFormClass; var TabSheet: TCloseTabSheet): Boolean;
    function  TotalFormsAbertos(ClassForm: TFormClass): Integer;

  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

{ TForm2 }

procedure TForm2.AcoplarFormulario(Aba: TTabSheet);
begin
  with Aba.Components[0] as TForm do
    begin
      Parent := Aba;
      Align  := alClient;
      BorderStyle := bsNone;
      PageControl1.ActivePage := Aba;
    end;
end;

procedure TForm2.AjustarCaptionAbas(ClassForm: TFormClass);
var
  I, Indice, TotalForms : Integer;
begin
    TotalForms := TotalFormsAbertos(ClassForm);
   if TotalForms > 1 then
   begin
      Indice := 1;
      for I := 0 to PageControl1.PageCount - 1 do
         with PageControl1 do
            if Pages[I].Components[0].ClassType = ClassForm then
            begin
               Pages[I].Caption := (Pages[I].Components[0] as TForm).Caption+'( '+ IntToStr(Indice) + ')';
               Inc(Indice) ;
            end;
   end;
end;

procedure TForm2.AjustarMenuSistema(Formulario: TForm; IdMenu: Word);
const
  CAPTION_MENU = 'Acoplar formulário';
var
  Menu: HMENU;
  MenuItemInfo: TMenuItemInfo;
begin
  Menu := GetSystemMenu(Formulario.Handle, False);
  if Lo(GetVersion) >= 4 then
  begin
    { Add a seperator }
    FillChar(MenuItemInfo, SizeOf(MenuItemInfo), #0);
    with MenuItemInfo do
    begin
      cbSize := 44; //SizeOf(MenuItemInfo);
      fType  := MFT_SEPARATOR;
      wID    := 0;
      fMask  := MIIM_CHECKMARKS or MIIM_DATA or
        MIIM_ID or MIIM_STATE or MIIM_SUBMENU or MIIM_TYPE;
    end;
    InsertMenuItem(Menu, 0, True, MenuItemInfo);
    with MenuItemInfo do
    begin
      fType         := MFT_STRING;
      fState        := MFS_DEFAULT;
      wID           := IdMenu;
      hSubMenu      := 0;
      hbmpChecked   := 0;
      hbmpUnchecked := 0;
      dwTypeData    := CAPTION_MENU;
      fMask         := MIIM_CHECKMARKS or MIIM_DATA or MIIM_ID or MIIM_STATE
        or MIIM_SUBMENU or MIIM_TYPE;
    end;
    InsertMenuItem(Menu, 0, True, MenuItemInfo);
  end
  else
    InsertMenu(Menu, 0, MF_BYPOSITION, IdMenu, CAPTION_MENU);
end;


procedure TForm2.Clientes1Click(Sender: TObject);
begin
  NovaAba(TForm3, (Sender as TMenuItem).ImageIndex);
end;

procedure TForm2.CloseTabeProc(Sender: TObject);
begin
  ShowMessage('Closing Tab');
end;

procedure TForm2.DesacoplarFormulario(Aba: TTabSheet);
begin
  with Aba.Components[0] as TForm do
    begin
      Align := alNone;
      BorderStyle := bsSizeable;
      Parent := nil;
    end;
  Aba.TabVisible := False;
  AjustarMenuSistema(Aba.Components[0] as TForm, 255);
end;

procedure TForm2.DesacoplarFormulrio1Click(Sender: TObject);
begin
  DesacoplarFormulario(PageControl1.ActivePage);
end;

procedure TForm2.Fechar1Click(Sender: TObject);
begin
  FecharAba(PageControl1.ActivePage);
end;

procedure TForm2.FecharAba(Aba: TTabSheet; Outras: Boolean);
var
  I : Integer;
begin
  for I := PageControl1.PageCount - 1 downto 0 do
   if PageControl1.Pages[I] <> Aba then
     FecharAba(PageControl1.Pages[I]);
end;

procedure TForm2.FecharAba(Aba: TTabSheet);
var
  Form : TForm;
  AbaEsq : TTabSheet;
begin
  AbaEsq := nil;
  Form := Aba.Components[0] as TForm;
  if Form.CloseQuery then
    begin
      if (Aba.TabIndex > 0) then
        AbaEsq := PageControl1.Pages[Aba.PageIndex -1];
        Form.Close;
        Aba.Free;
        PageControl1.ActivePage := AbaEsq;
    end;
end;

procedure TForm2.Fecharoutrasabas1Click(Sender: TObject);
begin
  FecharAba(PageControl1.ActivePage, True);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
FCloseButtonMouseDownTab := nil;
end;

procedure TForm2.Fornecedores1Click(Sender: TObject);
begin
  NovaAba(TForm4, (Sender as TMenuItem).ImageIndex);
end;

procedure TForm2.NovaAba(FormClass: TFormClass; IndiceImagem: Integer);
var
  TabSheet : TCloseTabSheet;
  Form     : TForm;
begin
  if not PodeAbrirFormulario(FormClass, TabSheet) then
          begin
            PageControl1.ActivePage := TabSheet;
            Exit;
          end;
  TabSheet := TCloseTabSheet.Create(PageControl1);
  TabSheet.PageControl := PageControl1;
  TabSheet.Caption := 'Carregando...';
  TabSheet.OnClose := CloseTabeProc;
  Form := FormClass.Create(TabSheet);
    with Form do
      begin
        Align := alClient;
        BorderStyle := bsNone;
        Parent := TabSheet;
      end;
//  AjustarCaptionAbas(FormClass);
//  TabSheet.ImageIndex := IndiceImagem;
  TabSheet.Caption := Form.Caption;
  Form.Show;
  PageControl1.ActivePage := TabSheet;
end;

procedure TForm2.PageControl1DrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  CloseBtnSize: Integer;
  PageControl: TPageControl;
  TabSheet:TCloseTabSheet;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
begin
  PageControl := Control as TPageControl;
  TabCaption.Y := Rect.Top+3;

  if Active then
    begin
      CloseBtnRect.Top := Rect.Top+4;
      CloseBtnRect.Right := Rect.Right-5;
      TabCaption.X := Rect.Left+6;
    end
  else
    begin
      CloseBtnRect.Top := Rect.Top+4;
      CloseBtnRect.Right := Rect.Right-5;
      TabCaption.X := Rect.Left+6;
    end;

  if PageControl.Pages[TabIndex] is TCloseTabSheet then
    begin
      TabSheet := PageControl.Pages[TabIndex] as TCloseTabSheet;
      CloseBtnSize := 14;

      CloseBtnRect.Bottom := CloseBtnRect.Top+CloseBtnSize;
      CloseBtnRect.Left := CloseBtnRect.Right-CloseBtnSize;
      TabSheet.FCloseButtonRect := CloseBtnRect;

      PageControl.Canvas.FillRect(Rect);
      PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y, PageControl.Pages[TabIndex].Caption);

      if not ThemeServices.ThemesEnabled then
        begin
          if (FCloseButtonMouseDownTab = TabSheet) and FCloseButtonShowPushed then
            CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
          else
            CloseBtnDrawState := DFCS_CAPTIONCLOSE;

          Windows.DrawFrameControl(PageControl.Canvas.Handle,
            TabSheet.FCloseButtonRect, DFC_CAPTION, CloseBtnDrawState);
        end
      else
        begin
          Dec(TabSheet.FCloseButtonRect.Left);
          if (FCloseButtonMouseDownTab=TabSheet) and FCloseButtonShowPushed then
            CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
          else
            CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

          ThemeServices.DrawElement(PageControl.Canvas.Handle, CloseBtnDrawDetails, TabSheet.FCloseButtonRect);          
        end;               
    end
  else
    begin
      PageControl.Canvas.FillRect(Rect);
      PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y, PageControl.Pages[TabIndex].Caption);
    end;
end;

procedure TForm2.PageControl1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I : Integer;
  PageControl : TPageControl;
  TabSheet : TCloseTabSheet;
begin
  PageControl := Sender as TPageControl;

  if (Button = mbLeft) then
    begin
      for I := 0 to PageControl.PageCount - 1 do
        begin
          if not (PageControl.Pages[I] is TCloseTabSheet) then
            Continue;
          TabSheet := PageControl.Pages[I] as TCloseTabSheet;
          if PtInRect(TabSheet.FCloseButtonRect, Point(X,Y)) then
            begin
              FCloseButtonMouseDownTab := TabSheet;
              FCloseButtonShowPushed := True;
              PageControl.Repaint;
            end;
        end;
    end;  
//  if (Button = mbRight) then
//    PageControl1.TabIndex := PageControl1.IndexOfTabAt(X,Y);
end;

procedure TForm2.PageControl1MouseLeave(Sender: TObject);
var
  PageControl : TPageControl;
begin
  PageControl := Sender as TPageControl;
  FCloseButtonShowPushed := False;
  PageControl.Repaint;
end;

procedure TForm2.PageControl1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PageControl : TPageControl;
  Inside : Boolean;
begin
  PageControl := Sender as TPageControl;

  if (ssLeft in Shift) and Assigned(FCloseButtonMouseDownTab) then
    begin
      Inside := PtInRect(FCloseButtonMouseDownTab.FCloseButtonRect, Point(X, Y));

      if FCloseButtonShowPushed <> Inside then
        begin
          FCloseButtonShowPushed := Inside;
          PageControl.Repaint;
        end;     
    end;
end;

procedure TForm2.PageControl1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PageControl : TPageControl;
begin
  PageControl := Sender as TPageControl;

  if (Button=mbLeft) and Assigned(FCloseButtonMouseDownTab) then
    begin
      if PtInRect(FCloseButtonMouseDownTab.FCloseButtonRect, Point(X, Y)) then
        begin
          FCloseButtonMouseDownTab.DoClose;
          FCloseButtonMouseDownTab := nil;
          PageControl.Repaint;
        end;
    end;  
end;

function TForm2.PodeAbrirFormulario(ClassForm: TFormClass; var TabSheet: TCloseTabSheet): Boolean;
var
  I : Integer;
begin
  Result := True;
  for I := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[I].Components[0].ClassType = ClassForm then
      begin
        TabSheet := PageControl1.Pages[I] as TCloseTabSheet;
        Result := (TabSheet.Components[0] as TForm).Tag = 0;
        Break;
      end;
end;

function TForm2.TotalFormsAbertos(ClassForm: TFormClass): Integer;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[I].Components[0].ClassType = ClassForm then Inc(Result);

end;

{ TCloseButtonTab }

constructor TCloseTabSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCloseButtonRect := Rect(0, 0, 0, 0);
end;

destructor TCloseTabSheet.Destroy;
begin
  inherited Destroy;
end;

procedure TCloseTabSheet.DoClose;
begin
  if Assigned(FOnClose) then FOnClose(Self);
  Free;
end;

end.
