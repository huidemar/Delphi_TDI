unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure HandleWndProc(var Msg : TMessage); message WM_SYSCOMMAND;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Unit2;

{$R *.dfm}

{ TForm3 }

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Parent.Free;
end;

procedure TForm3.HandleWndProc(var Msg: TMessage);
begin
  if Word(Msg.wParam)=255 then
    Form2.AcoplarFormulario(Owner as TTabSheet)
  else
    inherited;
end;

end.
