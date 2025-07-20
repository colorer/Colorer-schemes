// UltraEdit words file to hrc
//
var fso = new ActiveXObject( "Scripting.FileSystemObject" );

var srcFile=fso.getFile(WScript.arguments(0));
var langNo=WScript.arguments(1);
var langPattern="/L"+langNo+"\""
var src=srcFile.openAsTextStream();

while(!src.AtEndOfStream){
  s=src.readLine();
  if(s.indexOf(langPattern)==0){
    lastInd=s.indexOf("\"", langPattern.length);
    name=s.substr(langPattern.length, lastInd-langPattern.length);
    processLanguage(src, name);
  };
};
src.close();

function processLanguage(src, name){
  printHeader(name);
  isEnd=src.AtEndOfStream;
  inKind=false;
  while(!isEnd){
    s=src.readLine();
    isEnd=s.indexOf("/L")==0
    if(!isEnd){
      isKind=s.indexOf("/C")==0;
      if(isKind){
        if(inKind) printKindFooter();
        printKindHeader(getKindName(s));
      }else
        if(inKind) printKindWords(s);
      inKind=inKind||isKind;
    };
    isEnd=src.AtEndOfStream;
  };
  printFooter();
};

function printHeader(name){
  WScript.echo("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
  WScript.echo("<!DOCTYPE hrc SYSTEM \"../hrc.dtd\">");
  WScript.echo("<?xml-stylesheet type=\"text/xsl\" href=\"../hrc.xsl\"?>");
  WScript.echo("<hrc version=\"take5\">");
  WScript.echo("<!--"+name+"-->");
  WScript.echo("<type name=\"Test\">");
  WScript.echo("  <scheme name=\"Test\">");
};
function printFooter(){
WScript.echo("  </scheme>");
WScript.echo("</type>");
WScript.echo("</hrc>");

};
function printKindFooter(){
  WScript.echo("    </keywords>")
};
function printKindHeader(name){
  WScript.echo("    <!-- "+name+" -->");
  WScript.echo("    <keywords ignorecase=\"yes\" region=\"dVar\">");
};
function getKindName(s){
  f=s.indexOf("\"");
  l=s.indexOf("\"",f+1);
  return(s.substr(f+1,l-f-1));
};
function printKindWords(s){
  var words = s.split(" ")
  for(i=0;i<words.length;i++){
    if(words[i]!="")
      printWord(words[i]);
  };
};
function printWord(word){
  WScript.echo("      <word name=\""+word+"\"/>");
};