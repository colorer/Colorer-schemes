 <HTML>
 <HEAD>
<TITLE>Subscription Processed Successfully</TITLE>
 </HEAD>
 <BODY BGCOLOR="#ffffff">
 <H2>
Online Newsletter Subscription
 </H2>
 <P>
 Thank You for subscribing to our newsletter!
 <%
 # Get form data and assign to variables
 set r [ns_conn form $conn]
 set name [ns_set get $r name]
 set title [ns_set get $r title]
 set notify [ns_set get $r notify]
 set sendemail [ns_set get $r sendemail]
 set emailaddr [ns_set get $r emailaddr]

 # Set subscription options explicity to 0 if not checked
 if {$notify != 1} {set notify 0}
 if {$sendemail != 1} {set sendemail 0}

 # Update database with new subscription
 set db [ns_db gethandle]
 ns_db dml $db \
 "insert into test values ([ns_dbquotevalue $name],
[ns_dbquotevalue $title], $notify, $sendemail,
[ns_dbquotevalue $emailaddr])"

 # Send email message to subscription administrator
 set body "A new newsletter subscription was added for "
 append body $name
 append body ". The database has been updated."
 ns_sendmail "subscript@thecompany.com" "dbadmin@thecompany.com"
\
 "New Subscription" $body

 # Send email message to user
 set body "Your online newsletter subscription has been successfully
processed."
 ns_sendmail $emailaddr "dbadmin@thecompany.com" \
 "Your Online Subscription" $body

 # Show type of subscription to user
 if {$notify == 1} {
ns_puts "You will be notified via email when the online newsletter
changes."
 }
 if {$sendemail == 1} {
ns_puts "Future issues of the newsletter will be sent to you
via email."
 }
 %>
 </BODY></HTML>
