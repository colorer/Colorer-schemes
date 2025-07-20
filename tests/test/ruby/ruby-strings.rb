'hello'                     # hello
'a backslash \'\\\''        # a backslash '\'
%q/simple string/           # simple string
%q(nesting (really) works)  # nesting (really) works  
%q no_blanks_here ;         # no_blanks_here  

a  = 123                                                   #
"\123mile"                                                 # Smile  
"Say \"Hello\""                                            # Say "Hello"  
%Q!"I said 'nuts'," I said!                                # "I said 'nuts'," I said  
%Q{Try #{a + 1}, not #{a - 1}}                             # Try 124, not 122  
%<Try #{a + 1}, not #{a - 1}>                              # Try 124, not 122  
"Try #{a + 1}, not #{a - 1}"                               # Try 124, not 122  

print <<-'THERE'
    This is single quoted.
    The above used #{a + 1}
    THERE
sdfsdf

push_script "translate('#{text.gsub(/'/, '\\\'')}')"

1234
