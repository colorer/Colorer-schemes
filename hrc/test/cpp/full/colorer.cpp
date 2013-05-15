//
//  Copyright (c) Cail Lomecb (Igor Ruskih) 1999-2001 <ruiv@uic.nnov.ru>
//  You can use, modify, distribute this code or any other part
//  of colorer library in sources or in binaries only according
//  to Colorer License (see /doc/license.txt for more information).
//

#ifdef __MSDOS__
#include<io.h>
#include<new.h>
#include<stdlib.h>
#include<conio.h>
#endif

#ifdef _WIN32
#include<io.h>
#include<windows.h>
#include<sys/timeb.h>
#include<time.h>
#include<string>
#include<list>
#include"clip.hpp"
#endif

#include<fcntl.h>
#include<sys/stat.h>
#include<stdio.h>
#include<string.h>
#include<colorer/classes.h>
#include<regexp/cregexp.h>
#include<sgml/sgml.h>

#define LEN 256
#define UNIX_CFG "/usr/share/colorer/bin/.colorer.ini"
// load variants
enum { EREGEXP, ELIST, EVIEW, EGEN };
// these structures contains file's lines
struct SLines
{
  int  len;
  char *data;
  bool newdata;
  void dup();
  SLines(){ newdata = false; };
  ~SLines(){ if (newdata) delete data; };
};

int what = -1;
char fname[LEN];
char basefname[LEN];
char frules[LEN];
char typedescr[64];
int  totallines, htmlsubst, cpdis = 0, bkcolor = 0x1F;
SLines *lines;

PAssignData ad;
PAssign adata;
PColorData cd;
PColorer cc;
PType type;
PLineHL l1, hlines;

/////////////////////////////////////////////////////////////////////////////
// check for tabs
void SLines::dup()
{
char *od = data;
int chg = 0;
int  i;
  for (i = 0; i < len; i++)
    if (data[i] == '\t') chg++;
  if (!chg) return;

  data = new char[len + chg*4 + 1];
  memset(data, 0, len + chg*4 + 1);
  strncpy(data, od, len);
  for (i = 0; data[i]; i++){
    if (data[i] == '\t'){
      for(int j = len-i; j; j--)
        data[i+j+3] = data[i+j];
      data[i] = ' ';
      data[i+1] = ' ';
      data[i+2] = ' ';
      data[i+3] = ' ';
      len+=3;
    };
  };
  newdata = true;
};

// tests regular expressions
void retest()
{
SMatches match;
PRegExp re;
bool res;
char text[255];

  re = new CRegExp();
  do{
    printf("\nregexp:");
    gets(text);
    if (!re->SetExpr(text)) continue;
    printf("exprn:");
    gets(text);
    res = re->Parse(text, &match);
    printf("%s\nmatch:  ",res?"ok":"error");
    for(int i = 0; i < match.cMatch; i++){
      printf("%d:(%d,%d), ",i,match.s[i],match.e[i]);
    };
  }while(text[0]);
  delete re;
};

// loads all found types
void list()
{
PColorData cd;
PType type;

  cd = new CColorData(basefname, "./_colorer.log");
  if (!cd->IsOk()){
    fprintf(stderr, "cannot load colorer base from %s\n", basefname);
    return;
  };
  fprintf(stderr, "\nloading file types. check _colorer.log\n");
  for(type = cd->EnumTypes(NULL); type; type = cd->EnumTypes(type)){
    printf("%s\n", type->descr);
    cd->LoadType(type);
  };
};

// function called from CColorer object
const char* GetLine(void *param, CColorer *who, int lno, int*len)
{
  if (lno > totallines) return NULL;
  if (len) *len = lines[lno].len;
  return lines[lno].data;
};
// search type with typedescr
PType seltype(PColorData cd)
{
int len;
  if (!*typedescr) return NULL;
  len = strlen(typedescr);
  for(PType tp = cd->EnumTypes(NULL); tp; tp = tp->next)
    if (tp->descr && !strnicmp(tp->descr, typedescr, len)) return tp;
  return NULL;
};
//  load lines into array
bool formatlines(char *data, int len, int no)
{
char *file;
int i, llen = 1;

  totallines = 1;
  file = data;
  while(file < data + len){
    if (*file == '\r' || *file == '\n'){
      if (file[0] == '\r' && file[1] == '\n') file++;
      else if (file[0] == '\n' && file[1] == '\r') file++;
      totallines++;
    };
    file++;
  };
  lines = new SLines[totallines+1];
  file = data;
  lines->data = file;
  i = 0;
  while(file < data + len){
    if (*file == '\r' || *file == '\n'){
      if (file[0] == '\r' && file[1] == '\n') file++;
      else if (file[0] == '\n' && file[1] == '\r') file++;
      lines[i].len = llen - 1;
      if (no) lines[i].dup();
      llen = 0;
      i++;
      lines[i].data = file + 1;
    };
    file++;
    llen++;
  };
  lines[i].len = llen - 1;
  if (no) lines[i].dup();
  return true;
};

// check and substitutes characters in HTML
void SetLine(char *line, char *src, int len)
{
  strncpy(line, src, len);
  line[len]=0;

  for (int i=0; line[i]; i++){
    if (htmlsubst && line[i] == '<'){
      for(int j = len-i; j; j--)
        line[i+j+3] = line[i+j];
      line[i] = '&';
      line[i+1] = 'l';
      line[i+2] = 't';
      line[i+3] = ';';
      len+=3;
    };
    if (htmlsubst && line[i] == '>'){
      for(int j = len-i; j; j--)
        line[i+j+3] = line[i+j];
      line[i] = '&';
      line[i+1] = 'g';
      line[i+2] = 't';
      line[i+3] = ';';
      len+=3;
    };
    // for printf :)
    if (line[i] == '%'){
      for(int j = len-i; j; j--)
        line[i+j+1] = line[i+j];
      line[i] = '%';
      line[i+1] = '%';
      len++;
      i++;
    };
  };
};

class ScreenBuffer{
public:
  ScreenBuffer(HANDLE con,int w,int h)
  {
    buffer=NULL;
    console=con;
    resize(w,h);
  }
  void resize(int w,int h)
  {
    if(buffer)delete [] buffer;
    width=w;
    height=h;
    size=width*height;
    buffer=new CHAR_INFO[size];
  }
  void fillattr(int x,int y,WORD attr,int cnt)
  {
    if(y>=height)return;
    if(x<0){cnt+=x;x=0;}
    if(cnt<0)return;
    int n=x+cnt<width?cnt:width-x;
    CHAR_INFO *b=buffer+y*width+x;
    for(int i=0;i<n;i++)
    {
      b->Attributes=attr;
      b++;
    }
  }
  void fillchar(int x,int y,char chr,int cnt)
  {
    if(y>=height)return;
    if(x<0){cnt+=x;x=0;}
    if(cnt<0)return;
    int n=x+cnt<width?cnt:width-x;
    CHAR_INFO *b=buffer+y*width+x;
    for(int i=0;i<n;i++)
    {
      b->Char.AsciiChar=chr;
      b++;
    }
  }
  void write(int x,int y,const char* txt)
  {
    write(x,y,txt,strlen(txt));
  }
  void write(int x,int y,const char* txt,int cnt)
  {
    if(y>=height)return;
    int n=x+cnt<width?cnt:width-x;
    CHAR_INFO *b=buffer+y*width+x;
    for(int i=0;i<n;i++)
    {
      b->Char.AsciiChar=*txt;
      b++;txt++;
    }
  }
  void flush()
  {
    invalidate(0,0,width-1,height-1);
  }
  void invalidate(int x,int y,int w,int h)
  {
    COORD bufsize;
    bufsize.X=width;
    bufsize.Y=height;
    COORD to;
    to.X=x;
    to.Y=y;
    SMALL_RECT wnd;
    wnd.Left=x;
    wnd.Top=y;
    wnd.Right=x+w;
    wnd.Bottom=y+h;
    WriteConsoleOutput(console,buffer,bufsize,to,&wnd);
  }
  int W(){return width;}
  int H(){return height;}
  void hidecursor()
  {
    savecur.dwSize=0;
    savecur.bVisible=TRUE;
    if(!GetConsoleCursorInfo(console,&savecur))
    {
      HANDLE hnd=GetStdHandle(STD_OUTPUT_HANDLE);
      if(!GetConsoleCursorInfo(hnd,&savecur))
      {
        DWORD err=GetLastError();
        savecur.dwSize=10;
        savecur.bVisible=TRUE;
      };
    }
    CONSOLE_CURSOR_INFO cci;
    cci.dwSize = 100;
    cci.bVisible = FALSE;
    SetConsoleCursorInfo(console, &cci);
  }
  void showcursor()
  {
    SetConsoleCursorInfo(console, &savecur);
  }
  void setcurpos(int x,int y)
  {
    COORD c;
    c.X=x;
    c.Y=y;
    SetConsoleCursorPosition(console,c);
  }
protected:
  CHAR_INFO *buffer;
  int width;
  int height;
  int size;
  HANDLE console;
  CONSOLE_CURSOR_INFO savecur;
};

ScreenBuffer *scrbuf;

DWORD CTRL_PRESSED=LEFT_CTRL_PRESSED|RIGHT_CTRL_PRESSED;
DWORD ALT_PRESSED=LEFT_ALT_PRESSED|RIGHT_ALT_PRESSED;

DWORD CTRL_KEYS=CTRL_PRESSED|ALT_PRESSED|SHIFT_PRESSED;

int word_left(const char* str,int pos)
{
  if(pos==1)return 1;
  if(str[pos]!=' ' && str[pos-1]==' ')pos--;
  if(str[pos]==' ')
  {
    while(pos>=1 && str[pos]==' ')pos--;
  }
  if(pos==1)return 1;
  while(pos>1 && str[pos-1]!=' ')pos--;
  return pos;
}


int word_right(const char* str,int pos)
{
  if(!str[pos])return pos;
  if(str[pos]!=' ' && str[pos+1]==' ')pos++;
  if(str[pos]==' ')
  {
    while(str[pos] && str[pos]==' ')pos++;
  }
  if(!str[pos])return pos;
  while(str[pos] && str[pos+1]!=' ')pos++;
  if(str[pos])pos++;
  return pos;
}

void extend_selection(int& s,int& e,int op,int p)
{
  if(s==-1)
  {
    if(op<p)
    {
      s=op;
      e=p;
    }else
    {
      s=p;
      e=op;
    }
    return;
  }
  if(s==op)s=p;
  if(e==op)e=p;
  if(s==e)s=-1;
}

struct ed_undo_struct{
  std::string str;
  int leftpos;
  int curpos;
  int selstart;
  int selend;
};
class edundolist:public std::list<ed_undo_struct>{
public:
  void push_back(const std::string& s,int lp,int cp,int ss,int se)
  {
    ed_undo_struct st;
    insert(end(),st);
    back().str=s;
    back().leftpos=lp;
    back().curpos=cp;
    back().selstart=ss;
    back().selend=se;
  }
  bool changed(const std::string& s,int lp,int cp,int ss,int se)
  {
    return back().leftpos!=lp || back().curpos!=cp ||
           back().selstart!=ss || back().selend!=se ||
           back().str!=s;
  }
};


bool search_input(HANDLE conin,std::string& findstring)
{
  std::string s=findstring;
  scrbuf->fillattr(0,scrbuf->H()-1,7,scrbuf->W());
  scrbuf->fillchar(0,scrbuf->H()-1,' ',scrbuf->W());
  INPUT_RECORD ir;
  int leftpos=0,curpos=1;
  DWORD tmp;
  bool quit=false;
  bool retval=true;
  bool redraw=true;
  int selstart=1,selend=findstring.length();

  scrbuf->showcursor();

  edundolist undo;
  undo.push_back(s,leftpos,curpos,selstart,selend);
  const int maxundo=256;

  bool skipundo=false;

  while(!quit)
  {
    if(redraw)
    {
      if(!skipundo && undo.changed(s,leftpos,curpos,selstart,selend))
      {
        undo.push_back(s,leftpos,curpos,selstart,selend);
        //while(undo.size()>=maxundo)undo.pop_front();
      }
      skipundo=false;
      scrbuf->fillchar(0,scrbuf->H()-1,' ',scrbuf->W());
      scrbuf->fillattr(0,scrbuf->H()-1,7,scrbuf->W());
      if(selstart!=-1)
      {
        scrbuf->fillattr(selstart-leftpos,scrbuf->H()-1,0x70,selend-selstart);
      }
      scrbuf->write(0,scrbuf->H()-1,s.c_str()+leftpos,s.length()-leftpos);
      scrbuf->invalidate(0,scrbuf->H()-1,scrbuf->W(),0);
      scrbuf->setcurpos(curpos,scrbuf->H()-1);
    }
    redraw=true;
    ReadConsoleInput(conin, &ir, 1, &tmp);
    if(ir.EventType == KEY_EVENT && ir.Event.KeyEvent.bKeyDown)
    {
      DWORD state=ir.Event.KeyEvent.dwControlKeyState&CTRL_KEYS;
      if(state&CTRL_PRESSED)state|=CTRL_PRESSED;
      if(state&ALT_PRESSED)state|=ALT_PRESSED;
      int shift=state&SHIFT_PRESSED;
      state&=~SHIFT_PRESSED;
      int pos=leftpos+curpos;
      switch(ir.Event.KeyEvent.wVirtualKeyCode)
      {
        case VK_LEFT:
          if(state==CTRL_PRESSED)
          {
            int wl=word_left(s.c_str(),leftpos+curpos);
            if(wl==1)
            {
              leftpos=0;
              curpos=1;
            }else
            {
              if(wl<leftpos)
              {
                leftpos=wl-1;
                curpos=1;
              }else
              {
                curpos=wl-leftpos;
              }
            }
          }else
          {
            if(curpos==1)
            {
              if(leftpos>0)leftpos--;
            }else
            {
              curpos--;
            }
          }
          break;
        case VK_RIGHT:
          if(state==CTRL_PRESSED)
          {
            int wr=word_right(s.c_str(),leftpos+curpos);
            if(wr>leftpos+scrbuf->W())
            {
              leftpos=wr-scrbuf->W();
              curpos=scrbuf->W();
            }else
            {
              curpos=wr-leftpos;
            }
          }else
          {
            if(leftpos+curpos>=s.length())break;
            if(curpos==scrbuf->W())leftpos++;
            else curpos++;
          }
          break;
        case VK_HOME:
          leftpos=0;
          curpos=1;
          break;
        case VK_END:
          curpos=s.length();
          if(curpos>=scrbuf->W())
          {
            leftpos=curpos-scrbuf->W()+1;
            curpos=scrbuf->W()-1;
          }
          break;
        case 'Z':if(state!=CTRL_PRESSED)break;
          state=ALT_PRESSED;
        case VK_BACK:{
          if(state==ALT_PRESSED && undo.size()>0)
          {
            undo.pop_back();
            s=undo.back().str;
            leftpos=undo.back().leftpos;
            curpos=undo.back().curpos;
            selstart=undo.back().selstart;
            selend=undo.back().selend;
            skipundo=true;
            break;
          }
          if(state!=CTRL_PRESSED)
          {
            int p=leftpos+curpos;
            if(p==1)break;
            s.erase(p-1,1);
            curpos--;
            if(curpos<0)
            {
              if(leftpos)
              {
                leftpos--;
                curpos=0;
              }
              else
                curpos=0;
            }
          }else
          {
            int wl=word_left(s.c_str(),leftpos+curpos);
            if(leftpos+curpos!=wl)
            {
              s.erase(wl,leftpos+curpos-wl);
              if(wl==1)
              {
                leftpos=0;
                curpos=1;
              }else
              if(wl<leftpos)
              {
                leftpos=wl;
                curpos=0;
              }else
              {
                curpos=wl-leftpos;
              }
            }
          }
          }break;
        case VK_INSERT:{
            if(state==0 && shift)
            {
              if(selstart!=-1)
              {
                s.erase(selstart,selend-selstart);
                if(pos==selend)
                {
                  if(selstart==1)
                  {
                    leftpos=0;
                    curpos=1;
                  }else
                  if(selstart<leftpos)
                  {
                    leftpos=selstart;
                    curpos=0;
                  }else
                  {
                    curpos=selstart-leftpos;
                  }
                }
                selstart=-1;
              }


              char *text=PasteText();
              if(text)
              {
                s.insert(leftpos+curpos,text);
                curpos+=strlen(text);
                if(leftpos+curpos>=scrbuf->W())
                {
                  leftpos=leftpos+curpos-scrbuf->W()+1;
                  curpos=scrbuf->W()-1;
                }
                delete text;
              }
            }else
            if(state==CTRL_PRESSED && selstart!=-1)
            {
              std::string c;
              c.insert(0,s.c_str()+selstart,selend-selstart);
              CopyText(c.c_str(),c.length());
            }
          }break;
        case VK_DELETE:{
          if(selstart!=-1)
          {
            if(state==0 && shift)
            {
              std::string c;
              c.insert(0,s.c_str()+selstart,selend-selstart);
              CopyText(c.c_str(),c.length());
            }
            s.erase(selstart,selend-selstart-1);
            if(pos==selend)
            {
              if(selstart==1)
              {
                leftpos=0;
                curpos=1;
              }else
              if(selstart<leftpos)
              {
                leftpos=selstart;
                curpos=0;
              }else
              {
                curpos=selstart-leftpos;
              }
            }
            pos=leftpos+curpos;
            selstart=-1;
          }
          if(state!=CTRL_PRESSED)
          {
            int p=leftpos+curpos;
            if(p>=s.length())break;
            s.erase(p,1);
          }else
          {
            int n=leftpos+curpos;
            int wr=word_right(s.c_str(),n);
            if(wr!=n)
            {
              s.erase(n,wr-n);
            }
          }
          }break;
        case VK_ESCAPE:
          retval=false;
          quit=true;
          break;
        case VK_RETURN:;
          retval=true;
          quit=true;
          break;
        default:
          redraw=false;
          break;
      }
      if(ir.Event.KeyEvent.uChar.AsciiChar>=32 && redraw==false)
      {
        if(selstart!=-1)
        {
          s.erase(selstart,selend-selstart);
          if(pos==selend)
          {
            if(selstart==1)
            {
              leftpos=0;
              curpos=1;
            }else
            if(selstart<leftpos)
            {
              leftpos=selstart;
              curpos=0;
            }else
            {
              curpos=selstart-leftpos;
            }
          }
          selstart=-1;
        }

        char str[2]={ir.Event.KeyEvent.uChar.AsciiChar,0};
        s.insert(leftpos+curpos,str);
        if(curpos!=scrbuf->W()-1)
        {
          curpos++;
        }else
        {
          leftpos++;
        }
        redraw=true;
      }else
      {
        int newpos=leftpos+curpos;
        if(newpos!=pos && (state==0 || state==CTRL_PRESSED) && shift)
        {
          extend_selection(selstart,selend,pos,newpos);
        }else
        if(newpos!=pos)
        {
          selstart=-1;
        }
      }
    }
  };
  scrbuf->hidecursor();
  if(retval)
  {
    findstring=s;
  }
  return retval;
}

// viewing file with coloring
// note that it has different variants for different systems
void view()
{
int topline, leftpos, i, clr;
  cd = new CColorData(basefname, NULL);
  if (!cd->IsOk()){
    fprintf(stderr, "cannot load colorer base from %s\n", basefname);
    return;
  };
  adata = new CAssign();
  if (!adata->load(frules)){
    fprintf(stderr, "cannot load region rules from %s\n", frules);
    return;
  };

  if (*typedescr) type = seltype(cd);
  if (!*typedescr || !type) type = cd->SelType(fname, GetLine(0, 0, 0, 0), 0);
  if (!type) return;
  ad = adata->getcdata(2);
  bkcolor = ad->fore + (ad->back<<4);

  hlines = clrCreateRegions(totallines);
  cd->LoadType(type);
  cc = new CColorer();
  cc->SetServices(GetLine, 0, clrAddRegion, 0, 0, hlines);
  cc->SetColoringSrc(type);
  clrSetFirstLine(hlines, 0);
  cc->QuickParse(0, totallines);
//  cc->FullParse(0, 0 ,totallines, totallines);
//  return;

  clrAssignRegions(hlines, adata, ad);
  leftpos = topline = 0;

// WIN32 - draws through consoles
#ifdef _WIN32
CONSOLE_SCREEN_BUFFER_INFO csbi;
HANDLE hCon, hConI;
INPUT_RECORD ir;
COORD coor;
DWORD tmp;

  hCon = GetStdHandle(STD_OUTPUT_HANDLE);
  hConI= GetStdHandle(STD_INPUT_HANDLE);
  GetConsoleScreenBufferInfo(hCon, &csbi);

#ifndef __DPMI32__
  hCon = CreateConsoleScreenBuffer(GENERIC_WRITE, 0, 0, CONSOLE_TEXTMODE_BUFFER, 0);
  SetConsoleActiveScreenBuffer(hCon);
#endif
  SetConsoleMode(hConI,ENABLE_WINDOW_INPUT|ENABLE_MOUSE_INPUT);
  std::string findstring="/";
  scrbuf=new ScreenBuffer(hCon,csbi.dwSize.X,csbi.dwSize.Y);

  scrbuf->hidecursor();

  bool quit=false;

  int selstartline=-1;
  int selstartpos,selendline,selendpos;

  int fndline=0,fndpos=0;

  int mselecting=0;

  do{
    for(i=0;i<scrbuf->H();i++)
    {
      scrbuf->fillattr(0,i,bkcolor,scrbuf->W());
      scrbuf->fillchar(0,i,0x20,scrbuf->W());
    }
    for(i = topline; i < topline + csbi.dwSize.Y; i++, coor.Y = i-topline){
      coor.X = 0;
      coor.Y = i-topline; // my gcc has bug here :(

      if (i >= totallines) continue;
      if (lines[i].len <= leftpos) continue;

      for(l1 = hlines[i+1].next; l1; l1 = l1->next){
        if (l1->ad.type > 0xFF) continue;
        if (l1->end == -1) l1->end = lines[i].len;
        coor.X = l1->start - leftpos;
        int len = l1->end - l1->start;
        if (coor.X < 0){
          len += coor.X;
          coor.X = 0;
        };
        if (len < 0) continue;
        clr = l1->ad.fore + (l1->ad.back<<4);

        scrbuf->fillattr(coor.X,coor.Y,clr,len);
      };
      coor.X = 0;
      int n=csbi.dwSize.X < lines[i].len-leftpos ? csbi.dwSize.X : lines[i].len-leftpos;
      scrbuf->write(0,coor.Y,lines[i].data+leftpos,n);
    };
    if(selstartline!=-1)
    {
      for(i=selstartline;i<=selendline;i++)
      {
        if(i<topline || i>topline+scrbuf->H())continue;
        int s,e;
        if(i==selstartline && i==selendline)
        {
          s=selstartpos;
          e=selendpos;
        }else
        if(i==selstartline)
        {
          s=selstartpos;
          e=s+leftpos+scrbuf->W();
        }else
        if(i==selendline)
        {
          s=0;
          e=selendpos;
        }else
        {
          s=0;
          e=leftpos+scrbuf->W();
        }
        scrbuf->fillattr(s-leftpos,i-topline,0x30,e-s);
      }
    }
    // flush buffer
    scrbuf->flush();

    // managing the keyboard
    do{
      ReadConsoleInput(hConI, &ir, 1, &tmp);

      if(ir.EventType == MOUSE_EVENT)
      {
        if(ir.Event.MouseEvent.dwEventFlags & MOUSE_WHEELED)
        {
          ir.EventType=KEY_EVENT;
          ir.Event.KeyEvent.bKeyDown=true;
          ir.Event.KeyEvent.wVirtualKeyCode=
            ir.Event.MouseEvent.dwButtonState&0xff000000L?VK_DOWN:VK_UP;
        }
        if(ir.Event.MouseEvent.dwButtonState==FROM_LEFT_1ST_BUTTON_PRESSED && !mselecting)
        {
          mselecting=1;
          int x=ir.Event.MouseEvent.dwMousePosition.X;
          int y=ir.Event.MouseEvent.dwMousePosition.Y;
          selstartline=selendline=topline+y;
          selstartpos=selendpos=leftpos+x;
          break;
        }
        if(!(ir.Event.MouseEvent.dwButtonState&FROM_LEFT_1ST_BUTTON_PRESSED) && mselecting)
        {
          mselecting=0;
        }
        if((ir.Event.MouseEvent.dwEventFlags & MOUSE_MOVED) && (mselecting))
        {
          int x=leftpos+ir.Event.MouseEvent.dwMousePosition.X;
          int y=topline+ir.Event.MouseEvent.dwMousePosition.Y;
          selendline=y;
          selendpos=x;
          if(selendline<selstartline || (selendline==selstartline && selendpos<selstartpos))
          {
            y=selstartline;
            x=selstartpos;
            selstartline=selendline;
            selstartpos=selendpos;
            selendline=y;
            selendpos=x;
          }
          break;
        }
      }
      if (ir.EventType == KEY_EVENT && ir.Event.KeyEvent.bKeyDown)
      {
        // moving view position
        bool redraw=true;
        int oldtol=topline;
        switch(ir.Event.KeyEvent.wVirtualKeyCode){
          case VK_UP:
            if (topline) topline--;
            break;
          case VK_DOWN:
            if (topline+csbi.dwSize.Y < totallines) topline++;
            break;
          case VK_LEFT:
            if (leftpos) leftpos--;
            break;
          case VK_RIGHT:
            leftpos++;
            break;
          case VK_PRIOR:
            topline-=csbi.dwSize.Y;
            if (topline < 0) topline = 0;
            break;
          case VK_NEXT:
            topline += csbi.dwSize.Y;
            if (topline > totallines-csbi.dwSize.Y) topline = totallines-csbi.dwSize.Y;
            if (topline < 0) topline = 0;
            break;
          case VK_HOME:
            leftpos = topline = 0;
            break;
          case VK_END:
            topline = totallines-csbi.dwSize.Y;
            if (topline < 0) topline = 0;
            leftpos = 0;
            break;
          case VK_ESCAPE:
            quit=true;
            break;
          case VK_INSERT:
            if(selstartline!=-1)
            {
              std::string s;
              if(selstartline==selendline)
              {
                s.insert(0,lines[selstartline].data+selstartpos,selendpos-selstartpos);
              }else
              for(i=selstartline;i<=selendline;i++)
              {
                if(i==selstartline)
                {
                  if(selstartpos<lines[i].len)
                  {
                    s.insert(0,lines[i].data,lines[i].len-selstartpos);
                    s+="\r\n";
                  }
                }else
                if(i==selendline)
                {
                  int n=selendpos;
                  if(lines[i].len<n)n=lines[i].len;
                  s.append(lines[i].data,n);
                  if(selendpos>lines[i].len)s+="\r\n";
                }else
                {
                  s.append(lines[i].data,lines[i].len);
                  s+="\r\n";
                }
              }
              CopyText(s.c_str(),s.length());
            }
          default:
            redraw=false;
            break;
        };
        if(oldtol!=topline)
        {
          fndline=topline;
          fndpos=0;
        }
        if(ir.Event.KeyEvent.uChar.AsciiChar=='/' || ir.Event.KeyEvent.uChar.AsciiChar=='n')
        {
          if(ir.Event.KeyEvent.uChar.AsciiChar=='n' || search_input(hConI,findstring))
          {
            int i;
            for(i=1;i<findstring.length();i++)
            {
              if(findstring[i]=='/')break;
              if(findstring[i]=='\\')i++;
            }
            bool global=false;
            if(i>=findstring.length())findstring+="/";
            else
            {
              for(int j=i;j<findstring.length();j++)
              {
                if(findstring[j]=='g')
                {
                  global=true;
                }
              }
            }
            CRegExp re;
            re.SetExpr(const_cast<char*>(findstring.c_str()));
            if(!re.IsOk())
            {
              scrbuf->fillattr(0,scrbuf->H()-1,0xce,scrbuf->W());
              scrbuf->fillchar(0,scrbuf->H()-1,' ',scrbuf->W());
              scrbuf->write(0,scrbuf->H()-1,("Invalid rexexp:"+findstring).c_str());
              scrbuf->flush();
              redraw=false;
              continue;
            }
            SMatches m;
            bool found=false;
            if(global)
            {
              if(re.Parse(lines[fndline].data+fndpos,lines[fndline].data,
                          lines[totallines-1].data+lines[totallines-1].len,&m))
              {
                for(i=fndline;i<totallines;i++)
                {
                  if(lines[fndline].data+m.s[0]>=lines[i].data &&
                     lines[fndline].data+m.s[0]<=lines[i].data+lines[i].len)
                  {
                    selstartline=i;
                    selstartpos=lines[fndline].data+m.s[0]-lines[i].data;
                  }
                  if(lines[fndline].data+m.e[0]>=lines[i].data &&
                     lines[fndline].data+m.e[0]<=lines[i].data+lines[i].len)
                  {
                    selendline=i;
                    selendpos=lines[fndline].data+m.e[0]-lines[i].data;
                    break;
                  }
                }
                fndline=selstartline;
                fndpos=selstartpos+1;
                found=true;
              }
            }else
            {
              for(i=fndline;i<totallines;i++)
              {
                if(re.Parse(lines[i].data+fndpos,lines[i].data,lines[i].data+lines[i].len,&m))
                {
                  selstartline=i;
                  fndline=i;
                  fndpos=m.s[0]+1;
                  selstartpos=m.s[0];
                  selendline=i;
                  selendpos=m.e[0];
                  found=true;
                  break;
                }
                fndpos=0;
              }
            }
            if(!found)
            {
              scrbuf->fillattr(0,scrbuf->H()-1,0xce,scrbuf->W());
              scrbuf->fillchar(0,scrbuf->H()-1,' ',scrbuf->W());
              scrbuf->write(0,scrbuf->H()-1,"Not found");
              scrbuf->flush();
              redraw=false;
              fndline=0;
              fndpos=0;
              continue;
            }else
            {
              if(selstartline>=topline+scrbuf->H() || selstartline<topline)
              {
                topline=selstartline-4;
                if(topline<0)topline=0;
              }
            }
          }
          redraw=true;
        }
        if(redraw)break;
      };
    }while(true);
  }while(!quit);
#ifndef __DPMI32__
  SetConsoleActiveScreenBuffer(GetStdHandle(STD_OUTPUT_HANDLE));
#endif
  CloseHandle(hCon);
  delete scrbuf;

// ms dos uses video buffer
#elif defined __MSDOS__

int j, ch;
char *vm = (char*)0xb8000000;
#ifdef _DPMI_
unsigned int vmsel=0xb800;
#endif

// DataCompBoy: get selector for videobuffer
#ifdef _DPMI_
  asm{
    mov ax, 0002h
    mov bx, vmsel
    int 31h
    mov vmsel, ax
  }
  vm=(char*)(vmsel*0x10000);
#endif
// DataCompBoy: end

  topline = 0;
  do{
    for(i = topline; i < topline + 25; i++){
      if (i >= totallines) continue;
      l1 = hlines[i+1].next;
      for(j = 0; j < 80;j++){
        vm[((i-topline)*80 + j)*2] = 0x20;
        vm[((i-topline)*80 + j)*2 + 1] = bkcolor;
        if (lines[i].len-leftpos > j)
          vm[((i-topline)*80 + j)*2] = lines[i].data[j+leftpos];
      };
      for(; l1; l1 = l1->next){
        if (lines[i].len-leftpos <= 0) continue;
        if (l1->ad.type > 0xFF) continue;
        if (l1->end == -1) l1->end = lines[i].len;
        clr = l1->ad.fore + (l1->ad.back<<4);
        for(j = l1->start; j < l1->end; j++){
          if (j-leftpos < 0) continue;
          vm[((i-topline)*80 + j-leftpos)*2 + 1] = clr;
        };
      };
    };
    while(ch && ch!=27)
      ch = getch();
    if (!ch) ch = getch();
    switch(ch){
      case 'H':
        if (topline) topline--;
        break;
      case 'P':
        if (topline + 25 < totallines) topline++;
        break;
      case 'K':
        if (leftpos) leftpos--;
        break;
      case 'M':
        leftpos++;
        break;
      case 'I':
        topline -= 25;
        if (topline < 0) topline = 0;
        break;
      case 'Q':
        topline += 25;
        if (topline > totallines - 25) topline = totallines - 25;
        if (topline < 0) topline = 0;
        break;
      case 'G':
        topline = 0;
        leftpos = 0;
        break;
      case 'O':
        leftpos = 0;
        topline = totallines - 25;
        if (topline < 0) topline = 0;
        break;
    };
  }while(ch != 27);

//  UNIX systems - hmm...
#else

int ll;
char *line, t[1024];
  for(i = 0; i < totallines; i++){
    line = GetLine(0, 0, i, &ll);
    strncpy(t, line, ll);
    t[ll] = 0;
    printf("%s\n",t);
  };

#endif

  clrDestroyRegions(hlines);
  delete adata;
  delete cc;
  delete cd;
};

// prints to stdout formatted and colored text with selected rules (-i<fname>)
void htmlout()
{
PAssignData ad;
char tmpline[512];
int i, pos;

  cd = new CColorData(basefname, NULL);
  if (!cd->IsOk()){
    fprintf(stderr, "cannot load colorer base from %s\n", basefname);
    return;
  };
  adata = new CAssign();
  if (!adata->load(frules)){
    fprintf(stderr, "cannot load region rules from %s\n", frules);
    return;
  };
  if (*typedescr) type = seltype(cd);
  if (!*typedescr || !type) type = cd->SelType(fname, GetLine(0,0,0,0), 0);
  if (!type) return;

  hlines = clrCreateRegions(totallines);
  cd->LoadType(type);
  cc = new CColorer();
  cc->SetServices(GetLine, 0, clrAddRegion, 0, 0, hlines);
  cc->SetColoringSrc(type);
  cc->QuickParse(0, totallines);
//  cc->FullParse(0, 0 ,totallines, totallines);

  // in this order only!
  clrAssignRegions(hlines, adata, adata->getcdata(2));
  clrCompactRegions(hlines);

  ad = adata->getcdata(0);
  if (!ad->stext){
    fprintf(stderr, "bad rules file\n");
    return;
  };
  printf(ad->stext);
  if (!cpdis) printf("\ncreated with colorer library version 4ever. type '%s'", type->descr);
  printf("\n\n");
  for(i = 0; i < totallines; i++){
    pos = 0;
    for(l1 = hlines[i+1].next; l1; l1 = l1->next){
      if (l1->end == -1) l1->end = lines[i].len;
      if (l1->ad.type > 0xFF) continue;
      if (l1->start > pos){
        SetLine(tmpline, lines[i].data + pos, l1->start - pos);
        pos = l1->start;
        printf(tmpline);
      };
      SetLine(tmpline, lines[i].data + pos, l1->end - l1->start);
      pos += l1->end - l1->start;

      if (l1->ad.bsback) printf(l1->ad.sback);
      if (l1->ad.bstext) printf(l1->ad.stext);
      printf(tmpline);
      if (l1->ad.betext) printf(l1->ad.etext);
      if (l1->ad.beback) printf(l1->ad.eback);
    };
    if (pos < lines[i].len){
      SetLine(tmpline, lines[i].data + pos, lines[i].len - pos);
      printf(tmpline);
    };
    printf("\n");
  };
  ad = adata->getcdata(0);
  printf(ad->etext);

  clrDestroyRegions(hlines);
  delete adata;
  delete cc;
  delete cd;
};

// opens file and reads it
void parse(int no)
{
char *data;
struct stat fst;
  int file = open(fname, 0);
  if (file == -1){
    fprintf(stderr, "cannot open file %s", fname);
    return;
  };
  fstat(file, &fst);
  int len = fst.st_size;
  data = new char[len];
  memset(data, 0, len);
  len = read(file, data, len);
  close(file);

  formatlines(data, len, no);

  no?view():htmlout();

  delete[] lines;
  delete data;
};

// parameters
void printerr()
{
fprintf(stderr, "use: colorer -(l|r|h|v) [-i<name>] [-c] [-d] [-t<type>] <fname>\n"
       "  -l        test and load full database\n"
       "  -r        regexp tests\n"
       "  -h        generates plain coloring from file <fname> (uses rulesgen param)\n"
       "  -v        view file <fname> (uses rulesview param)\n"
       "  -i<name>  load coloring rules with name 'rules<name>'\n"
       "  -t<type>  try to use type <type> instead of type autodetection\n"
       "  -d        disable html symbols substitutions\n"
       "  -c        disable information header\n"
       "colorer uses colorer.ini file, placed in its directory(win/dos)\n"
       "or .colorer.ini in /usr/share/colorer/bin/ in unix systems\n"
       "this file contain base file paths.\n\n"
       );
};


void getparams(int argc, char *argv[])
{
  // checking parameters
  *frules = 0;
  htmlsubst = 1;
  for(int i = 1; i < argc; i++){
    if (argv[i][0] !='-' && argv[i][0] != '/'){
      strcpy(fname, argv[i]);
      continue;
    };
    if (argv[i][1] == 'r') what = EREGEXP;
    if (argv[i][1] == 'l') what = ELIST;
    if (argv[i][1] == 'v') what = EVIEW;
    if (argv[i][1] == 'h') what = EGEN;
    if (argv[i][1] == 'd') htmlsubst = 0;
    if (argv[i][1] == 'c') cpdis = 1;
    if (argv[i][1] == 't' && (i+1 < argc || argv[i][2])){
      if (argv[i][2]) strcpy(typedescr, argv[i]+2);
      else{
        strcpy(typedescr, argv[i+1]);
        i++;
      };
    };
    if (argv[i][1] == 'i' && (i+1 < argc || argv[i][2])){
      if (argv[i][2]) strcpy(frules, argv[i]+2);
      else{
        strcpy(frules, argv[i+1]);
        i++;
      };
    };
  };
  if (!*frules && what == EVIEW) strcpy(frules, "view");
  if (!*frules && what == EGEN) strcpy(frules, "gen");
};

void getfparams(char* param0/*DCB*/)
{
char cname[256], tmpname[64];
int len;
bool setrules = false;
FILE *file;

#ifdef _WIN32
  len = GetModuleFileName(GetModuleHandle(0), cname, 256)-1;
  while(cname[len] && cname[len] != '\\') len--;
  strcpy(cname+len+1, "colorer.ini");
#elif defined __MSDOS__
//DataCompBoy: begin
  strcpy(cname, param0);
  len = strlen(cname)-1;
  while(cname[len] && cname[len] != '\\') len--;
  strcpy(cname+len+1, "colorer.ini");
//DataCompBoy: end
#else
  strcpy(cname, UNIX_CFG);
#endif


  file = fopen(cname, "r");
  if (!file) return;

  while(fgets(cname, 256, file)){
    len = strlen(cname)-1;
    while(cname[len] == '\r' || cname[len] == '\n')
      cname[len--] = 0;
    if (!strncmp(cname, "base=", 5)){
       strcpy(basefname, cname+5);
    };
    if (!setrules){
      len = sprintf(tmpname, "rules.%s=", frules);
      if (!strncmp(cname, tmpname, len)){
        strcpy(frules, cname+len);
        setrules = true;
      };
    };
  };
  fclose(file);
};

// hm...
int main(int argc, char *argv[])
{
  fprintf(stderr, "\ncolorer library ``forever''\n");
  fprintf(stderr, "copyright (c) 1999-2001 cail lomecb/igor ruskih\n\n");

  getparams(argc, argv);
  getfparams(argv[0]/*DCB*/);

  if (what == -1){
    printerr();
    return 0;
  };
  switch(what){
    case EREGEXP:
      retest();
      break;
    case ELIST:
      list();
      break;
    case EVIEW:
      parse(1);
      break;
    case EGEN:
      parse(0);
      break;
    default:
      printerr();
      break;
  };
  return 0;
};
