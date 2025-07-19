<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
    <!--
    	function fnFindProduct(rowid,xval) {
				parent.hiddenframe.location.href='lookup.cfm?row=' + rowid + '&productid=' + xval;
		}
    //-->
    </SCRIPT>
</head>

<body>
 
 <CFFORM ACTION="foo.cfm" onSubmit="return fnValidate()">
 
 <table>
 <tr>
 	<th>Product<BR>ID</th>
	<th>Product Name</th>
	<th>Qty</th>
	<th>Price</th>
 </tr>
 <CFLOOP FROM="1" TO="5" index="i">
<tr>
	<td>
		<cfinput type="text" name="productid#i#" size="3" validate="integer" onChange="fnFindProduct(#i#,this.value)"> 
	</td>
	<td>
		<CFOUTPUT>
		<input type="text" name="productname#i#" disabled>
		</CFOUTPUT>
	</td>
	<td>
		<cfinput type="text" name="qty#i#" validate="integer" size="3">
	</td>
	<td>
		<CFOUTPUT>
		<input type="text" name="price#i#"  validate="float" size="5" disabled>
		</CFOUTPUT>
	</td>
</tr>	
</CFLOOP>
</table>
<input type="submit" value="Save Order"> 	
 
 </CFFORM>


</body>
</html>
