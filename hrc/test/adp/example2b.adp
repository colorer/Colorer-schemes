 <HTML>
 <HEAD>
<TITLE>The ABC's of Fruit Cookbook</TITLE>
 </HEAD>
 <BODY BGCOLOR="#ffffff">
 <%
 # Get form data and assign to variables
 set r [ns_conn form $conn]
 set question [ns_set get $r question]
 # Display cookbook in appropriate format
 if {$question == "yes"} {ns_adp_include cookset.html} \
 else {ns_adp_include cook.html}
 %>
 </BODY></HTML>
