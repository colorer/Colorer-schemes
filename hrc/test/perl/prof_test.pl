


$errflag = !(eval <<'END_MULTIPART');

    local ($buf, $boundary, $head, @heads, $cd, $ct, $fname, $ctype, $blen);
    local ($bpos, $lpos, $left, $amt, $fn, $ser);

END_MULTIPART


    print v9786;              # prints UTF-8 encoded SMILEY, "\x{263a}"
    print v102.111.111;       # prints "foo"
    print 102.111.111;        # same

1111x1111;


$parm =~ s/$columns[$i]/something/;
$parm =~ s/${columns[$i]}/something/;

$result .= '('.join(',',Dumper(@$call[10..$#$call])).')' if $call->[4];


print <<HEADER;
Content-Disposition: attachment; filename="${ENV{'QUERY_STRING'}}"\r\n
HEADER

Proc::Background->new("find", "/", "-name", "'*.*'"); #???

$parm =~ s/${columns[$i]}/something/;
           ${asdf[$t]}

   while ($buf =~ /\$(\d+)(\s+)(.+?)(\n)(.*?)\n(?=\$|\n\n-{60,}\n$|$)/s) {
    ${$self->{'FieldsText'}}{$1} = $5;
    ${$self->{'FieldsDesc'}}{$1} = $3;
    push @{$self->{'FieldsNumb'}}, ($1);
    $buf = $'; # Далее идет раскраска, но не та
   };
  for $name (grep {defined &{${"${class}::"}{$_}}}
       sort keys %{"${class}::"}) {


print "lala" if(!/^[^\~]+\.sql/);

    s@ foo @ \@ asdf @gi; # ??? - ok (lowpriority)

    $bar = "--ab]c--\n";

print <<aaa;
asdfasdf
sadfsadfasdf
aaa


$bar =~ s[ [ab][cd]  ][  !!  ]x;
print $bar;


m[  ];

/dsf/ig;


  s(          #
   $foo
   (sf)
  )          # great perversion - but...
#  note here could be only comments
  (

   12        # foo quux
   ($bar)

  )ix;



s/xxx/x/;
s#xxx#xxxx#g;

s/        # заменить
 \#       #  знак фунта
(\w+)     #  имя переменной
 \#
/'$' . $1 /xeeg; # значением любой переменной


s|sxx
xx
|x |gi;


  "";
  "xxxx";
  "xxx\"xxx";
  "xxx\\"+"xx";
  "xxx\\\\\"xxx";

print "xx 23 $dada xxxx\"xx
xx\\\"xx";

;;;

'xx
xx\'xx $aaa
xx';

qq{ sa  $dsf
 (safd) (asd(asfdasf)f)
 {asf}
fd};

@flds = split/ /,$Pars{"fields"};
$cmd = $Pars{"cmd"};

$Head = "xx xx
yy $sds yy
xx xx";

print "ok!" if $Head =~ /xx
yy
zz/;

$Head =~ s(xsd gf)(1sd 4 g)s;
print $Head;

<<"zz";
lalalala
zz

 if (/sxx \n sd/g){
   print "xx";
 };

/sxx \n sd/g;
 $a =! /sxx \n sd/g;
 $b =~ /sxx \n sd/g;

$x =~ /xxx/g;

s/xxx/eee/;
s/ a / a /s;

s[ sdf ] [ [  ] { } d]ix;

######################## NEW! ##################################

# some problems with perl m(a \( \) ( ( ) ) a)ix     perl bug??
print "ok $1" if ($a =~ m(x(())a)ix  );
print $xx;

s( )( );

# can't parse :(
s  {
 { } -    #really here you can't use brackets :)
}{
{  }
{  }
sdf }ix;

@ls = q[
xxx{ } \n   #
\(\( $sd    # doesn't interpolated!
[\[  \n]
{ \{  }];
];

print @ls;

@ls = qq[
xxx{ }
((
[[]]
\{ \{
];

@ls = qq!
xxx{ }
((
[[ \! # works\!
{{
!;


s (  xxx )( xxx ()  );


#мазохисты
sub unescape {
    s {
            E<
            ( [A-Za-z]+ )
            >
    } {
         do {
             exists $HTML_Escapes{$1}
             ? do { $HTML_Escapes{$1} }
                : do {
                    warn "Unknown escape: $& in $_";
                    "E<$1>";
                }
         }
    }egx;
}

print 0x1_0_00."\n";
print 1_0_00.23."\n";
print .1_0_00e3."\n\n\n";
print 2323x10;




  ("<trbgcolor=#".sprintf('%02X%02X%02X',0,40+(255-$cnt*10)/2,255-$cnt*10),"><td>$$_{name}</td><td>$$_{tm}</td><td>$$_{cl}</td></tr>");
$foo = "aa{bb}cc";
m!\r\n*!;

print qq<!!!> if $foo =~ m{{bb}} && /lal
ala/;

$foo =~ s<bb><$$foo>;

s(
sdfasdf
asdf        # dsfsdf
)(
  () ()        # aaaaa
  23
  $asdf
  $sdd{sdf};
  (safd);
);

print $foo;

print "lala" unless /lalala/;

/foobar/;

if (/bebe/){
};

$foo =~ s(
       aa
     )(
       [
       {{}}
       ]
     )gix;

print $foo;
