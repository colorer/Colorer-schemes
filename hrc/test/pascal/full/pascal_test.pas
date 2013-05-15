//=============================================
//Pascal/Delphi/Delphi.Net Text for Test Syntax
//=============================================

// comment 1

{
   commect 2
}

(*
   comment 3
*)

unit pascal_test platform experimental;

{$B-,O-,D+}

interface

Uses MyCompany.MyDepartment.OtherUnit as aUnit; //.Net

type

  T_Delphi_Class = class (TComponent, IUnknown, ICloneable)
  private
  protected
    function GetHandle: THandle; cdecl; reintroduce; overload; virtual; platform;
    {$IFDEF MSWINDOWS}
    procedure WMCREATE(var Message: TMessage); message WM_CREATE;
    {$ENDIF IFDEF MSWINDOWS}
    class function A: Boolean; override; deprecated;
    procedure ObjAddRef; safecall;
    function IUnknown._AddRef = ObjAddRef;
    procedure Ovr; overload;
  public
    property Objects[Index: Integer]: TObject read GetObject; platform; deprecated;
  published
    property Idx: TMySet index 0 read GetIdx write SetIdx default [];
    property Prop: Byte read GetProp write SetProp default 0 stored isStoredProp; default; deprecated;
  end;

  T_DotNet_Class = class (TObject)
  private
     var
       fDW: DWord;
     class var
       fReadInt: Integer;
  strict private fInt:Integer;
  protected
    class function GetIntData: Integer;
    type TNestedClass = class
      procedure Hello;
    end;
    procedure CheckIt; override; final;
  strict protected
    procedure Finalize; override;
  public
    class function GetStream(Stream: TStream): System.IO.Stream; overload; static;
    class constructor Create; //class constructor
    class property IntData: Integer read GetIntData;
    class operator Add(const Left, Right: TBcd): TBcd;
  published
  end platform experimental;

  T_DotNet_Class_sealed = class sealed

  end;

  T_DotNet_ClassHelper1 = class helper for TObject

  end;

  T_DotNet_ClassHelper2 = class helper (TObjectHelper) for TPersistent

  end;

  T_Classic_Record = record
    d: double;
    case byte of
      0: (
           C: Char;
           B: Byte;
           D: Double;
         );
      1: (
           W:WideChar;
         );
      2: DW: DWORD;
  end;

  T_DotNet_Record = packed record
    Data: TObject;
    Arr: packed array [0..15] of Word;
    [MarshalAs(UnmanagedType.LPTStr)]
    pszText: string platform;
    Bounds: record
      case Integer of
        0: (lMinimum, lMaximum: Longint);
        1: (dwMinimum, dwMaximum: DWORD);
        2: (dwReserved0, dwReserved1, dwReserved2,
            dwReserved3, dwReserved4, dwReserved5: DWORD);
    end;
    Metrics: packed record
      case Integer of
        0: (cSteps: DWORD);
        1: (cbCustomData: DWORD);
        2: (dwReserved0, dwReserved1, dwReserved2,
            dwReserved3, dwReserved4, dwReserved5: DWORD);
    end;
  public
    function GetA:Integer;
  strict private
    class function GetB(r: TMyPackedRec):Integer; deprecated;
  end;

  I_Pascal_Interface = interface

    procedure BeginLock;
    procedure EndLock;

    function GetProp: Integer;
    procedure SetProp(Value: Integer);


    property Prop:Integer read GetProp write SetProp;

  end;


var
  varBoolean: Boolean = True;
  varByteBool: ByteBool;
  varWordBool: WordBool = Falsel;
  varLongBool: LongBool;
  varByte: Byte;
  varChar: Char = '@';
  varAnsiChar: AnsiChar = #1;
  varWord: Word = $AF;
  varLongWord: LongWord;
  varInteger: Integer = -123;
  varLongInt: LongInt;
  varSmallInt: SmallInt;
  varDWORD: DWORD = $FFFF;
  varSingle: Single;
  varLongInt: LongInt;
  varPtr: Pointer = @varBoolean;
  varUINT: UINT absolute varDWORD;
  varCurrency: Currency;
  varInt64: Int64;
  varComp: Comp absolute varInt64;
  varString: String = 'go go'#13#10'do do';
  varShortStr: ShortString = 'abcd';
  varAnsiStr: AnsiString;
  varChar: PChar = 'efgh';
  varWideStr: WideString = '123';
  varPWideChar: PWideChar = nil;
  varReal: Real;
  varReal48: Real48;
  varDouble: Double;
  varExtended: Extended;
  varVariant: Variant = null;
  varOleVariant: OleVariant;
  varText: Text;
  varTextFile: TextFile;
  varDateTime: TDateTime;

  // .Net "&" Prefix for .NET Native
  TMyType : &Type;

threadvar
  i: Integer;

const
  cMaxLen = 4096 platform;

resourcestring
 rsError = 'Error: %s';

implementation

function BASMTEST(const s: PChar): PChar; stdcall; assembler;
asm
              push    ebp
              mov     ebp, esp
              add     esp, -cSetScrollInfo_VarsAndResultSize
              add     ebp, -cSetScrollInfo_VarsAndResultSize
              push    edx

              push    ebx
              push    ebp
              @@code_start1:
              call    @@delta1
              @@delta1:
              pop     ebx
              mov     eax, offset @@delta1
              sub     eax, offset @@code_start1
              sub     ebx, eax
              mov     eax, offset LB_CODE_DATA
              sub     eax, offset @@code_start1
              lea     ebx, [ebx+eax]
              pop     ebp

              lea     eax, [ebp].TSetScrollInfo_Vars.C
              push    eax
              push    ELSB_GETCONTROLLER
              push    [ebx].TCodeData.WM_ELSCROLLBAR
              push    [ebp].TSetScrollInfo_Params.hWnd
              call    dword ptr [ebx].TCodeData.SendMessage

              mov     eax, [ebx].TCodeData.SetScrollInfo
              lea     edx, [ebx].TCodeData.jiSetScrollInfo
              call    @@RestoreSavedCode // eax = MSrc = @SetScrollInfo, edx = PJumpInstruction

@@BeginLock:
              cmp     [ebx].TCodeData.IsWin9X, 1
              je      @@CLI
              lea     eax, [ebx].TCodeData.LockID
              push    eax
              push    1
              push    0
              call    dword ptr [ebx].TCodeData.CreateMutex
              mov     [ebp].TCommon_Vars.hLock, eax
              test    eax, eax
              jz      @@BLR
              push    INFINITE
              push    eax
              call    dword ptr [ebx].TCodeData.WaitForSingleObject
              jmp     @@BLR
  @@CLI:      cli
  @@BLR:      ret     $00

@@EndLock:
              cmp     [ebx].TCodeData.IsWin9X, 1
              je      @@STI
              mov     eax, [ebp].TCommon_Vars.hLock
              test    eax, eax
              jz      @@ELR
              push    eax
              call    dword ptr [ebx].TCodeData.CloseHandle
              jmp     @@ELR
  @@STI:      sti
  @@ELR:      ret     $00

LB_CODE_DATA:

@@SendMessage:
              dw      0,0

@@LockID:
              db      'HookApi:{7DDF4ADB-4A01-4F4B-83AA-8D91C21E99D2}:123456789012345:Lock',$0 //= 'HookApi:'+ID_WM_ELSCROLLBAR+':'+DWordToStr(GetCurrentProcessID()):Lock
end;

function SearchPath; external kernel32 name 'SearchPathA';

exports
  BASMTEST index 0 name '@BASMTEST';

forward procedure pb(var i1: integer; var b2 :boolean);

procedure a(a: dword; b:boolean; Ptr: Pointer); cdecl; register;
var
  i: Integer;
label
  lbA;
begin
  if b = TObject(Ptr).WordBool then
    exit;
  pb( a,  b);
  for i:=100 downto 0 do
    if b then
      break
    else
    begin
       if (...) then
         continue;
       b := ...;
       ...
       if b then
         exit;
       ...
       if (...) then
         goto MY_LABEL;
       ...
    end;
  // end for i
  ...
  with Self.RA^ do ...;
  d:=^A;
  while a>0 do
    ...;
  ...
  repeat ...
   ...
  until false;
  ...
  try
  except
    on e: Exception do
    begin
      ...
      raise;
    end;
  end;
  ...
  try
    ...
  finally
    ...
  end;
  ...
  goto lbA;
  ...
lbA:
  ...
  Abort;
  ...
end;

type
  TByteArray = array[0..10000]of Byte;
  PByteArray = ^TByteArray;


initialization
finalization
end.
