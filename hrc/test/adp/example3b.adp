 <HTML>
 <HEAD>
 <TITLE>DB Example page 2</TITLE>
 </HEAD>
 <BODY>
 <H1>DB Example page 2</H1>
 <%
 set table [ns_set get [ns_conn form $conn] Table]
 set db [ns_db gethandle]
 %>
 Contents of <%=$table%>:
 <Table border=1>
 <%
  set row [ns_db select $db "select * from $table"]
  set size [ns_set size $row]
  while {[ns_db getrow $db $row]} {
 ns_puts "<tr>"
 for {set i 0} {$i < $size} {incr i} {
 ns_puts "<td>[ns_set value $row $i]</td>"
 }
 ns_puts "</tr>"
  }
 %>
 </table>
 </BODY>
 </HTML>
