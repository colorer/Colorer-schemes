<cfsilent>
<cfparam name="url.mode" default="sql">
<cfdirectory  action="LIST"
							 directory="#request.labsqlpath#"
							  filter="*.sql"
							  name="qsql">
							  
<cfif isdefined("url.dsn") and url.dsn is not "">
	<cftry>
		<cfmodule template="sqlserver_getinfo.cfm"
			 datasource="#url.dsn#" 
			 qsp="getsps" 
			 qschema="getschema">
	<cfcatch type="Database">
		<cfset nosps="1">
		<cfset getsps = querynew("name")>
	</cfcatch>	
	</cftry>
</cfif>
</cfsilent>
<!doctype html public "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Display a pick-list tree of files and stored procedures</title>
	<style>
		.normaltext {
			font-family: arial;
			font-size: 8pt;
		}
		
		.smalltext {
			font-family: Arial;
			font-size: 8pt;
		}
		
		.fselected {
			font-family: sans-serif;
			font-size: 10pt;
			font-weight: bold;
		}
		
		.rollover {
				font-family: sans-serif;
				font-size: 10pt;
				text-decoration: underline;	
				cursor : hand;
		}
		
	.mainbody {
		font-family : Arial;
		font-size : 8 pt;
		font-weight : bold;
		
		
	}
	
	.dcolumn {
		font-family: Arial;
		font-size: 8pt;
	}
	
	.dtable {
		font-family: Arial;
		font-size: 8pt;
	}
	
	
	</style>
	
	<script src="dsntree.js" language="JavaScript"></script>
	<script language="JavaScript" type="text/javascript">
    <!--
		<CFOUTPUT>
		function fnloadsp(fname,obj) {
			
			var doload = false;
			
		 	parent.parent.titleframe.document.all.btnExecute.style.display='';
			if (!top.datachanged) {
				parent.parent.editor.location.href='editor.cfm?sp=' + escape(fname) + '&dsn=#urlencodedformat(url.dsn)#';
				top.datachanged=false;
				doload=true;
			} else {
				if (confirm("Abandon Changes?")) {
					parent.parent.editor.location.href='editor.cfm?sp=' + escape(fname) + '&dsn=#urlencodedformat(url.dsn)#';
					top.datachanged=false;
					doload=true;
				}
			}
			
			if (doload) {
				var arows=stable.rows;
				for (var i=0; i<arows.length; i++) {
					arows[i].className='normaltext';
				}
				obj.className='fselected';
			}
		}

	   function spwizard(itype) {
			fnNewSP();
			window.showModelessDialog("spwizard.cfm?dsn=#urlencodedformat(url.dsn)#&type=" + itype, window,  "resizable:no; status:no;dialogWidth:500px; dialogHeight:308px;" );				
		}		
		
		function fnCodeGen(itype) {
			window.showModelessDialog("codegen/cfwizard.cfm?dsn=#urlencodedformat(url.dsn)#&type=" + itype, window,  "resizable:no; status:no;dialogWidth:515px; dialogHeight:308px;" );				
		}
		</CFOUTPUT>		
		
    //-->
    </script>
</head>

<body leftmargin="1" 
			topmargin="2" 
			class="mainbody"
			ondragstart="fOnDragStart()"
			 onDragEnter="fOnDragOver()"
	    	 onDragOver="fOnDragOver()"
	    	 onDrop="fOnDrop()"
			 onKeyDown="fKeyDown()"
			 onKeyUp="fKeyUp()"
			 background="images/sql_bkg_stripe.gif"
			
>

<table id="stable" cellpadding="0" cellspacing="0" style="table-layout:fixed" border="0">
	<col width="16"><col width="16"><col width="16">
	<tr onClick="fnToggleSql()">
		<td><img src="images/tree/plus_RB.gif" width="16" height="16" alt="" border="0" id="sqimage"></td>
		<td class="normaltext" colspan=3>SQL Queries</td>	
	</tr>
	<tbody id="squeries" style="display:none">
		<tr  onClick="fnNewFILE('newfile',this)" onMouseout="fnRollout(this)" onMouseover="fnRollover(this)" class="normaltext">
				<td><cfif qsql.recordcount gt 0><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"><cfelse><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"></cfif></td>
				<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>
				<td colspan=2>Create New Query</td>
		</tr>
		<cfoutput query="qsql">
			<tr  onClick="fnloadfile('#name#',this)" onMouseout="fnRollout(this)" onMouseover="fnRollover(this)" <cfif isdefined("url.filespec") and name is url.filespec>class="fselected"<cfelse>CLASS="normaltext"</cfif>>
				<td><cfif qsql.currentrow is qsql.recordcount><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"><cfelse><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"></cfif></td>
				<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>
				<td colspan=2>#name#</td>
			</tr>
		</cfoutput>
	</tbody>
	
	
	<cfif not isdefined("nosps")>
	<tr onClick="fnToggleSp()">
		<td><img src="images/tree/plus_tRB.gif" width="16" height="16" alt="" border="0" id="spimage"></td>
		<td class="normaltext" colspan=3>Stored Procedures</td>	
	</tr>

	<tbody id="spqueries" style="display:none">
		<tr  onClick="fnNewSP('newsp',this)" onMouseout="fnRollout(this)" onMouseover="fnRollover(this)" class="normaltext">
				<td><cfif qsql.recordcount gt 0><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"><cfelse><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"></cfif></td>
				<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>
				<td colspan=2>Create New SP</td>
		</tr>
		<cfoutput query="getsps">
			<tr  onClick="fnloadsp('#name#',this)" onMouseout="fnRollout(this)" onMouseover="fnRollover(this)" <cfif isdefined("url.filespec") and name is url.filespec>class="fselected"<cfelse>CLASS="normaltext"</cfif>>
				<td><cfif getsps.currentrow is getsps.recordcount><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"><cfelse><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"></cfif></td>
				<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>
				<td colspan=2>#name#</td>
			</tr>
		</cfoutput>
	</tbody>
	

	<tr onClick="fnToggleSchema()">
		<td><img src="images/tree/plus_TRB.gif" width="16" height="16" alt="" border="0" id="smimage"></td>
		<td class="normaltext" colspan=3>Tables</td>	
	</tr>

	<tbody id="stables" style="display:none">
		<cfoutput query="getschema" group="tablename">
			<tr class="normaltext" valign="top" >
				<td><cfif getschema.currentrow is getschema.recordcount><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0" hspace="0" vspace="0"><cfelse><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0" hspace="0" vspace="0"></cfif></td>

				<td><img src="images/tree/plus_l.gif" hspace="0" vspace="0"  class="dtable" align="middle"  alt="" id="#tablename#" border="0"  onClick="fnShowHide('#tablename#',this)"></td>
				<td colspan=2><a onDblClick="fnTableEdit('#tablename#')" onClick="tClipCopy('#tablename#')" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">#tablename#</a></td>
			</tr>
	
						<cfoutput>
								<tr id="tableinfo_#tablename#_#currentrow#" style="display:none">
									<td width="16"><img src="images/tree/line_TB.gif" width="16" height="16" alt="" border="0"></td>
									<td><cfif getschema.currentrow is not getschema.recordcount and getschema.tablename is getschema.tablename[currentrow + 1]><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"><cfelse><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"></cfif></td>
									<td><a title="Click to insert column name in sql 
 [Alt] + Click to insert sp parameter declaration
 [Ctrl] + Click to insert @columnname" border="0" class="dcolumn" id="#colname#" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'" onClick="fClipCopy('#colname#_#typename#_#length#');"><img src="datacolumn.gif" width="16" height="16"></a></td>
									<td class="smalltext"><nobr>#colname# (#typename# #length#)</a><nobr></td>
								</tr>
						</cfoutput>
			
				
		</cfoutput>
	</tbody>
	
	<tr onClick="fnToggleWizards()">
		<td><img src="images/tree/plus_TR.gif" width="16" height="16" alt="Various SP & Code Wizards" border="0" id="smimage2"></td>
		<td colspan=3 class="normaltext">Wizards</td>	
	</tr>

	<tbody id="wizards" style="display:none">
		<tr onClick="spwizard(1)" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">
			<td><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"></td>
			<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>	
			<td class="smalltext" colspan=2>Select SP</td>
		</tr>
		<tr  onClick="spwizard(2)" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">
			<td><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"></td>
			<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>	
			<td class="smalltext" colspan=2>Insert SP</td>
		</tr>
		<tr onClick="spwizard(3)" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">
			<td><img src="images/tree/line_TRB.gif" width="16" height="16" alt="" border="0"></td>
			<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>	
			<td class="smalltext" colspan=2>Update SP</td>
		</tr>
		<tr onClick="spwizard(4)" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">
			<td><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"></td>
			<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>	
			<td class="smalltext" colspan=2>Delete SP</td>
		</tr>

	</tbody>

	
	<tr onClick="fnToggleCodeGen()">
		<td><img src="images/tree/plus_TR.gif" width="16" height="16" alt="Code Generators" border="0" id="smimage3"></td>
		<td colspan=3 class="normaltext">Code Generators</td>	
	</tr>

	<tbody id="cgen" style="display:none">
		<tr onClick="fnCodeGen(1)" onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='auto'">
			<td><img src="images/tree/line_TR.gif" width="16" height="16" alt="" border="0"></td>
			<td><img src="images/tree/end_L.gif" width="16" height="16" alt="" border="0"></td>	
			<td class="smalltext" colspan=2>CFML-based Editor</td>
		</tr>
	</tbody>
	
	
	
	</cfif>
</table>
 

<cfif isdefined("url.filespec")>
	<script language="JavaScript" type="text/javascript">
    <!--
		<CFIF url.mode is "sql">
    		document.all.sqimage.click();
		<CFELSE>
			document.all.spimage.click();
		</CFIF>
    //-->
    </script>
</cfif>



</body>
</html>
