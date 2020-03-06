<form action="edit_newspf.mc" method="post">
<table width="100%" border="0" cellpadding="4" cellspacing="0">
<tr>
	<td>
		<table>
			<tr>
				<td colspan="2"><b>изменить новость</b><hr></td>
			</tr>
			<tr>
				<td>дата</td>
				<td><input type="text" name="date" size="10" value="<% $date %>"></td>
			</tr>
			<tr>
				<td valign="top">вступление</td>
				<td><textarea rows="3" name="brief" cols="30"><% $brief %></textarea></td>
			</tr>
			<tr>
				<td valign="top">полный текст</td>
				<td><textarea rows="6" name="news" cols="30"><% $news %></textarea></td>
			</tr>
			<tr>
				<td align="right" colspan="2">
					<input type="submit" value="сброс">
					<input type="submit" name="change_news" value="сохранить">
				</td>
			</tr>
		</table>
	</td>
</tr>
</table>
<input type="hidden" name="id" value="<% $id %>">
</form>                        

<%init>
my $sth = $dbh->prepare("SELECT date, brief, news FROM tbl_news WHERE id = ?");
$sth->execute($id);
my($date, $brief, $news) = $sth->fetchrow_array;
$date = $m->comp('../include/dates.mc:frommysql_date', date => $date);
</%init>

<%args>
$id
</%args>
