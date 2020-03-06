 <%@ ... %>
 <%! ... %>
 <%= ... %>
 <jsp:forward>     </jsp:forward>
 <jsp:getProperty> </jsp:getProperty>
 <jsp:include>     </jsp:include>
 <jsp:setProperty> </jsp:setProperty>
 <jsp:useBean>     </jsp:useBean>
           или
 <jsp:forward id="1" и другие параметры ..... />
 <jsp:getProperty id="1" и другие параметры ..... />
 <jsp:include id="1" и другие параметры ..... />
 <jsp:setProperty id="1" и другие параметры ..... />
 <jsp:useBean id="1" и другие параметры ..... />

 <jsp:    /> и  - это тоже самое, что и <% %>

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>

<jsp:include page="scripts/login.jsp">
        <jsp:param name="username" value="jsmith" />
</jsp:include>

<%!
public String likeFilter(String searchStr, String colName)
{
}
%>
<html>
<head>
<title> Registration </title>
</head>
<body>

<!-------------------- begin top ----------------------------->
<jsp:include page="include/top.jsp" flush="true"/>
<!--------------------- end top ------------------------------>
<% i=0 %>
<center>Example</center>
<%
  CSDBManager DBManager = new CSDBManager();
  out.println ("<h2>Error in connection - 1</h2>\n");
%>

<!---- Begin main code ---------------------------------->
<%= variable %>
<!---- End main code ---------------------------------->
</body>
</html>
