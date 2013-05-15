
 <HTML>
 <HEAD>
<TITLE>Browser Example</TITLE>
 </HEAD>
 <BODY>
 <H1>
Browser Example
 </H1>
 <P>
 <%
 ns_puts "Hello
 "
 set ua [ns_set get [ns_conn headers] "user-agent"]
 ns_puts "$ua
 "
 if [string match "*MSIE*" $ua] {
  ns_puts "This is MS Internet Explorer"
 } elseif [string match "*Mozilla*" $ua] {
  ns_puts "This is Netscape or a Netscapecompatible browser"
 } else {
  ns_puts "Couldn't determine the browser"
 }
 %>
 </BODY></HTML>
