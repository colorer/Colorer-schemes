 <HTML>
 <HEAD>
 <TITLE>This is a test of ADP</TITLE>
 </HEAD>
 <BODY>
 <H1>This is a test of ADP</H1>
 <%

 ## Proxies should cache this page for a maximum of 1 hour:
 ns_setexpires $conn 3600
 set host [ns_set iget [ns_conn headers $conn] host]

 ## How many times has this page been accessed
 ## since the server was started?
 ns_share -init {set count 0} count
 incr count
 %>

 Number of accesses since server start: <%=$count%><br>
 tcl_version: <%=$tcl_version%><br>
 tcl_library: <%=$tcl_library%><br>
 Host: <%= $host %><br>

 <!-- Include the contents of a file: -->
 <%
 ns_adp_include standard-header
 %>

 <script language=tcl runat=server>
 ## You can do recursive ADP processing as well:
 ns_adp_include time.adp
 </script>

 <P>Here's an example of streaming:
 <script stream=on runat="server">
 ns_puts "<br>1...<br>"
 ns_sleep 2
 ns_puts "2...<br>"
 ns_sleep 2
 ns_puts "3!<br>"
 </script>
 <p><b>End</b>
 </BODY>
 </HTML>
