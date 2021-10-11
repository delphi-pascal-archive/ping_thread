unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, ComCtrls;

type TThreadScan = class(TThread)
     msg : string;
     msg2 : string;
 private
     BeginAddr: integer;
     EndAddr: integer;
     Timeout: DWORD;
     procedure UpdateMemo;
     procedure UpdateStatusBar;
     procedure UpdateScanned;
 protected
     procedure Execute; override;
 public
     constructor Create(a,b:integer);
 end;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SaveDialog1: TSaveDialog;
    CheckBox1: TCheckBox;
    XPManifest1: TXPManifest;
    Button1: TButton;
    Edit5: TEdit;
    Label5: TLabel;
    StatusBar: TStatusBar;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
     Thread: array of TThreadScan;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  FoundedHosts: integer;
  TotalScanned: integer;
implementation

{$R *.dfm}

uses WinSock;

type
    ip_option_information = packed record  // ���������� ��������� IP (���������� 
				    // ���� ��������� � ������ ����� ������ � RFC791.
        Ttl : byte;			// ����� ����� (������������ traceroute-��)	
        Tos : byte;			// ��� ������������, ������ 0
        Flags : byte;		// ����� ��������� IP, ������ 0
        OptionsSize : byte;		// ������ ������ � ���������, ������ 0, �������� 40
        OptionsData : Pointer;	// ��������� �� ������ 
    end;

   icmp_echo_reply = packed record
        Address : u_long; 	    	 // ����� �����������
        Status : u_long;	    	 // IP_STATUS (��. ����)
        RTTime : u_long;	    	 // ����� ����� ���-�������� � ���-������� 
				         // � �������������
        DataSize : u_short; 	    	 // ������ ������������ ������
        Reserved : u_short; 	    	 // ���������������
        Data : Pointer; 		 // ��������� �� ������������ ������
        Options : ip_option_information; // ���������� �� ��������� IP
    end;

    PIPINFO = ^ip_option_information;
    PVOID = Pointer;

        function IcmpCreateFile() : THandle; stdcall; external 'ICMP.DLL' name 'IcmpCreateFile';
        function IcmpCloseHandle(IcmpHandle : THandle) : BOOL; stdcall; external 'ICMP.DLL'  name 'IcmpCloseHandle';
        function IcmpSendEcho(
                          IcmpHandle : THandle;    // handle, ������������ IcmpCreateFile()
                          DestAddress : u_long;    // ����� ���������� (� ������� �������)
                          RequestData : PVOID;     // ��������� �� ���������� ������
                          RequestSize : Word;      // ������ ���������� ������
                          RequestOptns : PIPINFO;  // ��������� �� ���������� ��������� 
                       		                   // ip_option_information (����� ���� nil)
                          ReplyBuffer : PVOID;     // ��������� �� �����, ���������� ������.
                          ReplySize : DWORD;       // ������ ������ ������� 
                          Timeout : DWORD          // ����� �������� ������ � �������������
                         ) : DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';

function Conv(x:integer):integer;

begin
 Conv:= MakeWPARAM(MakeWORD(HiByte(HiWord(x)) , LoByte(HiWord(x))),
   MakeWORD(HiByte(LoWord(x)) , LoByte(LoWord(x))));
end;

constructor TThreadScan.Create(a,b:integer);
begin
  BeginAddr := a;
  EndAddr := b;
  inherited Create(True);
end;

procedure TThreadScan.Execute;
var
    hIP : THandle;
    pingBuffer : array [0..31] of Char;
    pIpe : ^icmp_echo_reply;
    wVersionRequested : WORD;
    lwsaData : WSAData;
    error : DWORD;
    destAddress : In_Addr;
    i: integer;
    IPReply: string;
begin
    // ������� handle
    hIP := IcmpCreateFile(); 

    GetMem( pIpe,
            sizeof(icmp_echo_reply) + sizeof(pingBuffer));
    pIpe.Data := @pingBuffer;
    pIpe.DataSize := sizeof(pingBuffer);

    wVersionRequested := MakeWord(1,1);
    error := WSAStartup(wVersionRequested,lwsaData);
    if (error <> 0) then
    begin
        { Form1.Memo1.SetTextBuf('Error in call to '+
                          'WSAStartup().'); }
         //Form1.Memo1.Lines.Add('Error code: '+IntToStr(error));
        // msg := 'Error code: '+IntToStr(error);
       //  Synchronize(ShowResult);
         Exit;
    end;

    for i:=BeginAddr to EndAddr do
    begin
      destAddress.S_addr := Conv(i);

    Inc(TotalScanned);
    msg2 :='�����������: ' + IntToStr(TotalScanned);
    Synchronize(UpdateScanned);

    IcmpSendEcho(hIP,
                 destAddress.S_addr,
                 @pingBuffer,
                 sizeof(pingBuffer),
                 Nil,
                 pIpe,
                 sizeof(icmp_echo_reply) + sizeof(pingBuffer),
                 Timeout);

     
    error := GetLastError();
    if (error <> 0) then
    begin
         msg := inet_ntoa(destAddress) + ' - N/A';
         Synchronize(UpdateMemo);
         continue;
    end;

     // ������� ��������� �� ����������� ������

    IPReply := IntToStr(LoByte(LoWord(pIpe^.Address)))+'.'+
               IntToStr(HiByte(LoWord(pIpe^.Address)))+'.'+
               IntToStr(LoByte(HiWord(pIpe^.Address)))+'.'+
               IntToStr(HiByte(HiWord(pIpe^.Address)));


   msg :=IPReply + ' - ' + IntToStr(pIpe.RTTime)+' ms';
   Synchronize(UpdateMemo);

   Inc(FoundedHosts);
   msg := '������� ������: ' + IntToStr(FoundedHosts);
   Synchronize(UpdateStatusBar);

   end;//for

 IcmpCloseHandle(hIP);
 WSACleanup();
 FreeMem(pIpe);
end;

procedure TThreadScan.UpdateScanned;
begin
  Form1.StatusBar.Panels[0].Text := msg2;
end;

procedure TThreadScan.UpdateStatusBar;
begin
 Form1.StatusBar.Panels[3].Text := msg;
end;

procedure TThreadScan.UpdateMemo;

begin
 Form1.Memo1.Lines.Add(msg);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  a,b: integer;
  count:Longint;
  NumbThreads: Longint;
  h: integer;
  start,finish:array of integer;
  i: integer;
  addr:in_addr;
  str :string;
  F:TextFile;
  hThread:array of array of Cardinal;
  bs:integer;
  time_out: Cardinal;
  d:integer;
  len: array of integer;
  NumbArr: integer;
  m:integer;
  mwo: integer;
begin
 Memo1.Clear;

 a := Conv(inet_addr(PChar(Edit1.Text)));
 b := Conv(inet_addr(PChar(Edit2.Text)));
 time_out := StrToInt(Edit3.Text);
 NumbThreads := StrToInt(Edit5.Text);
 mwo :=  MAXIMUM_WAIT_OBJECTS;

 SetLength(start,NumbThreads);
 SetLength(finish,NumbThreads);
 SetLength(len,NumbThreads);

 count := b - a + 1;
 FoundedHosts := 0;
 TotalScanned := 0;

 StatusBar.Panels[0].Text := '�����������: 0';
 StatusBar.Panels[1].Text := '�����������...';
 StatusBar.Panels[2].Text := '����������� ������: '+IntToStr(count);
 StatusBar.Panels[3].Text := '������� ������: 0';
 h := count div NumbThreads;
 d := count mod NumbThreads;

 NumbArr := NumbThreads div mwo;
 m := NumbThreads mod mwo;

 if m <> 0
 then Inc(NumbArr);

 {***���������� ���������***}
 for i:=0 to NumbThreads - 1 do
   len[i] := h;

 for i:=0 to d-1 do
   Inc(len[i]);

 start[0] := a ;
 finish[0] := a + len[0] - 1;

 for i:=1 to NumbThreads - 1 do
 begin
    start[i] := finish[i-1] + 1;
    finish[i] := start[i] + len[i] - 1;
 end;

 {**************}

 for i:=0 to NumbThreads-1 do
 begin
  Application.Processmessages;
  addr.S_addr := Conv(start[i]);
  str := inet_ntoa(addr);
  addr.S_addr := Conv(finish[i]);
  str := str + ' - ' + inet_ntoa(addr);
  Memo1.Lines.Add(str);
 end;

 SetLength(Thread, NumbThreads);

 SetLength(hThread, NumbArr, mwo);
 { ������������� ������� }
 for i:=0 to NumbThreads - 1 do
 begin
  Application.Processmessages;
  Thread[i] := TThreadScan.Create(start[i],finish[i]);
  Thread[i].Timeout := time_out;
  hThread[i div mwo][i mod mwo] := Thread[i].Handle;
 end;
{  ������ �������} 
 for i:=0 to NumbThreads - 1 do
 begin
   Application.Processmessages;
   Thread[i].Resume;
 end;
 
{ �������� ���������� ������ ������� }
 for i:=0 to NumbArr-1 do
 begin
   if (m>0)and (i=NumbArr - 1)
   then mwo := m;
   while WaitForMultipleObjects(mwo, @hThread[i][0], True, 50) = WAIT_TIMEOUT do
   Application.ProcessMessages;
 end;

 { ���������� � ���� }
 if Form1.CheckBox1.Checked
 then
    begin
      AssignFile(F,'report.txt');
      if FileExists('report.txt')
      then Append(F)
      else Rewrite(F);
    
        for i:=0 to Memo1.Lines.Count - 1 do
        begin
          str := Memo1.Lines.Strings[i];
          if Pos('ms',str)<>0 then
          begin
            bs := Pos(' ',str);
            str := Copy(str,1, bs-1);
            Writeln(F,str);
          end;
        end;

      CloseFile(F);
    end;

 StatusBar.Panels[1].Text := '���������';
end;

end.
