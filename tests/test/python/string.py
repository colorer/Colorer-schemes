"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"
"""Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"""
r"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\U\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"
b"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"
rb"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\U\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"
f"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"
fr"Άνναحنّة亚当	}}{{\0\1\2\3\4\5\6\7\8\9\
\a\b\c\d\e\f\g\h\i\j\k\l\m\n\o\p\q\r\s\t\u\v\w\x\y\z\
\A\B\C\D\E\F\G\H\I\J\K\L\M\N\O\P\Q\R\S\T\U\V\W\X\Y\Z\
\ \!\"\#\$\%\&\\\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\|\{\}\~"

"\01234\678\789\3"
"\x0123\xffff\u012345\u123"
"\uafAFFF\U0123456789\UabCDEF0123\U123"
"\N{Euro-Currency Sign}123\N{asd"
"unclosed string literal, sadly no way to highlight the end of line as having the error
r""r"\\"r"\\\\"r"\\\" # odd number of backslashes also lead to unclosed string literal
"""multi-line
string literal"""

r""R""f""F""rf""Rf""rF""RF""fr""Fr""fR""FR""
b""B""br""Br""bR""BR""rb""Rb""rB""RB""
r''R''f''F''rf''Rf''rF''RF''fr''Fr''fR''FR''
b''B''br''Br''bR''BR''rb''Rb''rB''RB''
r""""""R""""""f""""""F""""""rf""""""Rf""""""rF""""""RF""""""fr""""""Fr""""""fR""""""FR""""""
b""""""B""""""br""""""Br""""""bR""""""BR""""""rb""""""Rb""""""rB""""""RB""""""
r''''''R''''''f''''''F''''''rf''''''Rf''''''rF''''''RF''''''fr''''''Fr''''''fR''''''FR''''''
b''''''B''''''br''''''Br''''''bR''''''BR''''''rb''''''Rb''''''rB''''''RB''''''

f"He said his name is {name!r}."
f"He said his name is {repr(name)}."  # repr() is equivalent to !r
f"result: {value:{width}.{precision}}"  # nested fields
f"abc {a["x"]} def"  # error: outer string literal ended prematurely
f"abc {a['x']} def"  # workaround: use different quoting
f"newline: {ord('\n')}"  # raises SyntaxError
f"{today=:%B %d, %Y}" # using date format specifier and debugging
f"{number:#0x}"  # using integer format specifier
f"{ foo = }"  # preserves whitespace
f"{ foo	=	bar	}"  # only whitespaces are allowed after the equal sign
f"{r'{}''''yep''''legal'!s:s}"  # yep, legal
f"{foo:r!r:r}"  # "r!r:r" will be passed to __format__
f"{0+0.*.0-0e0}-{0j+0.j+.0j}"
