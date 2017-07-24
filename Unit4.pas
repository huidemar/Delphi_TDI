unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm4 = class(TForm)
    Label1: TLabel;
  private
    { Private declarations }
    procedure HandleWndProc(var Msg : TMessage); message WM_SYSCOMMAND;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses Unit2;

{$R *.dfm}

{ TForm4 }

procedure TForm4.HandleWndProc(var Msg: TMessage);
begin
  if Word(Msg.wParam)=255 then
    Form2.AcoplarFormulario(Owner as TTabSheet)
  else
    inherited;
end;

end.
