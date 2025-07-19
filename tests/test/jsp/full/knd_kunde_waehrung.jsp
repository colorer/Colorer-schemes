<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><!-- #BeginTemplate "/Templates/Kunde_template.dwt" -->
<%@ page import="de.nordlbit.credit.common.object.IKundeStructure" %>
<%@ page import="de.nordlbit.credit.common.object.IKontoStructure" %>
<%@ page import="de.nordlbit.credit.common.object.IBObjectData" %>


<%@ page language="java" contentType="text/html" %>
<%@ taglib uri="/taglib" prefix="views" %>
<%@ taglib uri="/bobject" prefix="bobject" %><head>
<!-- #BeginEditable "import" --> 

<!-- #EndEditable --> 

<!-- #BeginEditable "doctitle" --> 
<title>Kunde</title>
<!-- #EndEditable --> 
<% String ctx=request.getContextPath(); %>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="COPYRIGHT" content="NORD/IT">
<!-- #BeginEditable "css" --> 
<script language="JavaScript" src="<%=ctx+"/nordlbit/js/tibase.js"%>" type="text/javascript"></script>
<link rel="stylesheet" href="<%=ctx+"/nordlbit/css/nordit.css"%>" type="text/css">
<!-- #EndEditable --> 
<script language="JavaScript">
</script>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<br>
<form method="POST" action="<%=ctx+"/Portal"%>">
  <!-- #BeginEditable "names" --> 
  <%
   java.lang.String currTab= (String)session.getAttribute("CURRENT_PAGE"); 
  %>
  <input type="hidden" name="W2J_PREVIOUS_PAGE" value="sonstiges">
  <input type="hidden" name="W2J_NEXT_PAGE" value="adressen">
  <!-- #EndEditable --> 
  <table width=100% border=1 bordercolor="#C8D2E4" cellspacing=0 cellpadding=0>
    <tr> 
      <td> 
        <table width=100% border=0 cellspacing=0 cellpadding=0>
          <tr> 
            <td style="background-color: #E8ECF3"> 
                <views:tabpane> 
                   <views:tab width="100" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=name\"%>" title="Name" selected="<%=(currTab.equals(\"name\") ? \"true\" : \"false\") %>" ></views:tab>
                           <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=Adressen\"%>" title="Adressen" selected="<%=(currTab.equals(\"adressen\") ? \"true\" : \"false\") %>" ></views:tab>
                           <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=systematik\"%>" title="Systematik" selected="<%=(currTab.equals(\"systematik\") ? \"true\" : \"false\") %>" ></views:tab>
                           <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=legitimation\"%>" title="Legitimation" selected="<%=(currTab.equals(\"legitimation\") ? \"true\" : \"false\") %>" ></views:tab>
                           <views:tab width="110" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=gesellsch\"%>" title="Gesellschaft" selected="<%=(currTab.equals(\"gesellschaft\") ? \"true\" : \"false\") %>" ></views:tab>
                        </views:tabpane>
               </td>
        </tr>
            <tr>
           <td style="background-color: #E8ECF3">
                <views:tabpane>
                  <views:tab width="100" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=kommunikat\"%>" title="Kommunikation" selected = "<%=(currTab.equals(\"kommunikation\") ? \"true\" : \"false\") %>" ></views:tab>
                          <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=bank\"%>" title="Bank" selected = "<%=(currTab.equals(\"bank\") ? \"true\" : \"false\") %>" ></views:tab>
                  <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=waehrung\"%>" title="W&auml;hrung" selected = "<%=(currTab.equals(\"waehrung\") ? \"true\" : \"false\") %>" ></views:tab>
                  <views:tab width="120" href="<%=ctx+\"/Portal?OPEN=de.nordlbit.credit.frontend.KundeFormController&GOTO_PAGE=sonstiges\"%>" title="Sonstiges" selected = "<%=(currTab.equals(\"sonstiges\") ? \"true\" : \"false\") %>" ></views:tab>
                        </views:tabpane>
           </tr><!-- #BeginEditable "secondnav" -->     
<!-- <tr> 
      <td>
        <table width=100% border=0 cellspacing=0 cellpadding=0>
          <tr> 
            <td style="background-color: #E8ECF3"> 
              <script language="JavaScript">
                        drawmenu(10,5,items1,links1);
               </script>
          </tr>
        </table> 
          </td>
    </tr> -->
    <!-- #EndEditable --> 
        </table>
      </td>
    </tr>
    <tr> 
      <td height=100% style="background-color: white; vertical-align: top"> <!-- #BeginEditable "mainform" --> 
        <table width=100%>
          <!-- Start Inhalt Notizbuch -->
          <tr> 
            <th colspan="2" align="left">W&auml;hrung</th>
          </tr>
          <tr> 
            <td><label for="Waehrungseinheit">W&auml;hrungseinheit</label></td>
            <td> 
              <table>
                <tr> 
                  <td> 
                   <bobject:attribute type="select" name="<%=IKundeStructure.ATTR_WAEHRUNG%>"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr> 
            <td><label for="KURS">Kurs</label></td>
            <td> 
              <table>
                <tr> 
                  <td> 
                    <bobject:attribute type="text" name="<%=IKundeStructure.ATTR_KURS%>"/>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
        <!-- #EndEditable --> </td>
    </tr>
  </table>
</form>
</body>
<!-- #EndTemplate --></html>

