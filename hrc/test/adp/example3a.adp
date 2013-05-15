 <HTML>
 <HEAD>
<TITLE>DB Example</TITLE>
 </HEAD>
 <BODY>
 <H1>
DB Example
 </H1>
 <P>
 Select a db table from the default db pool:
 <FORM METHOD=POST ACTION=db2.adp>
<SELECT NAME=Table>
 <%
 set db [ns_db gethandle]
 set sql "select * from tables"
 set row [ns_db select $db $sql]
 while {[ns_db getrow $db $row]} {
set table [ns_set get $row name]
ns_puts "<OPTION VALUE=\"$table\">$table"
 }
 %>
</SELECT>
<INPUT type=submit value="Show Data">
 </FORM>
 </BODY></HTML>
