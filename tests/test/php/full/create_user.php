<?php

/*
 *	W-AGORA 4.0
 *	-----------
 *	Usage:		Create a new user for a site
 *	Author:		Marc Druilhe <mdruilhe@w-agora.com>
 */

require ("init_admin.inc");

# Read site administration configuration
# --------------------------------------
require ("$site_cfg_file");	
if (empty($bn_msgs) ) {
	include ("$bn_dir_default/site_msgs.$ext");
} else {
	include "$bn_dir/$bn_msgs";
}

display_header ("New user");

# gets all forums in this site for which the logged user is moderator
# -------------------------------------------------------------------
if ($auth->level >= ADMIN ) {
	// get all forums if user is administrator
	$forums = $db->listForums ($site);
} else {
	$forums = $db->listForums ($site, $auth->userid);
}

# If Creation form have been submitted
# ------------------------------------
if (isset($go)) {

	$go=0;

#	Check for required fields
#	-------------------------
	if (empty ($passwd1) || ($passwd1 != $passwd2)) {
		MsgForm ("password must be set and must be entered twice, please verify", "$WA_SELF", "back");
		exit;
	}

	include "$tmpl_dir/admin/user_fields.$ext";
	if (is_array ($bn_bind_var)) {
		while (list($field, $required) = each($bn_bind_var)) {
			if ($required && !$$field) {
				$mess = "$field : " . Msg(5);
				MsgForm ("$mess", "$WA_SELF", "back");
				exit;
			}
		}
	}

	$userid = trim($userid);	// remove spaces at beginning and end
	
#	Check if user already exists
#	-----------------------------
	$u = $db->getUser($site, $userid, "userid");
	if (is_array($u)) {
		msgForm (msg(109, "user: $userid already exists for this site"), "$WA_SELF", "back");
		echo "</body></html>";
		exit;
	}

	$u = $db->getUser($site, $useraddress, "useraddress");
	if (is_array($u)) {
		msgForm (msg(177, "The email address '$useraddress' is already used"), "$WA_SELF", "back");
		echo "</body></html>";
		exit;
	}

#	gets all input form variables and set fields in user array
#	----------------------------------------------------------

	$unixdate = time();
	
# -------------------------------------------------------------------
# Create user privileges (user->forums relation) for each forum
# -------------------------------------------------------------------

# initialize default values
# --------------------------
	$uf_fields["unixdate"]=$unixdate;
	$uf_fields["userid"]=$userid;
	$uf_fields["lastpost"]=0;
	$uf_fields["totalpost"]=0;

# For each forum in this site (if user is not an admin)
# -----------------------------------------------------
	if ( ($userpriv != "admin") && is_array ($forums)) {
		reset ($forums);
		while (list($name) = each ($forums) ) {
			$forum = $forums[$name]["bn_name"];
			if (is_array ($$forum)) {
# if user has rights on this forum => gets all privileges set on this forum for this user
# ---------------------------------------------------------------------------------------
				// initialize default values
				$uf_fields["bn_name"]=$forum;
				$uf_fields["listpriv"] = 0;
				$uf_fields["readpriv"] = 0;
				$uf_fields["writepriv"] = 0;
				$uf_fields["modpriv"] = 0;
				$uf_fields["state"] = 0;
				while ( list($priv, $val) = each($$forum) ) {
					$uf_fields[$priv] = $val;
				}
# if moderator has been selected for this forum :
# -----------------------------------------------
				if ($uf_fields["modpriv"] == 1) {
					if ($userpriv == "moder") {
						//  moderator can also read, write, list => force all privileges
						$uf_fields["listpriv"]=1;
						$uf_fields["readpriv"]=1;
						$uf_fields["writepriv"]=1;
					} else {
						// this user has not moderator privilege
						$uf_fields["modpriv"]=0;
					}
				}
			
# insert into userforum
# ---------------------
				$ret = $db->InsertPrivs ($site, $forum, $userid, $uf_fields);

				if ($ret < 0) {
					MsgForm ("could not insert user $userid in ${site}_userforum", "$WA_SELF?site=$site", "back");
					exit;
				}
# If moderator has been choosen, set forum's owner if not already set
# ------------------------------------------------------------------
				if ( ($uf_fields["modpriv"] == 1) && empty($forums[$name]["owner"]) ) {
					$forums[$name]["owner"] = $userid;
					$ret = $db->updateForum ($site, $forum, $forums[$name]);
					if ($ret < 0) {
						MsgForm ("could not update owner in $site for $forum", "$WA_SELF?site=$site", "back");
						exit;
					}
				}
			}
		}
	}

#  Now insert this user in users table
#  -----------------------------------
	
	for (reset ($bn_var); $form_field=current($bn_var); next($bn_var)) {
		$$field=stripSlashes($$form_field);
		$u_fields[$form_field]=$$field;
	}

	$u_fields["password"] = md5($passwd1);
	$u_fields["lastlogin"]=0;
	$u_fields["totallogins"]=0;

	$ret = $db->insertUser ($site, $u_fields);

	if ($ret < 0) {
		MsgForm ("could not insert user $userid in ${site}_users", "$WA_SELF?site=$site", "back");
		exit;
	}

# If new user has administrator privilege =>  insert into main database
# ---------------------------------------------------------------------
	if ( ($userpriv == "admin" || $userpriv == "root") ) {
		$agora_dbparam = getDBaccess("$cfg_dir/site_agora.$ext");
		$agora_access = $agora_dbparam["bn_access"];
		$agora_dbname = $agora_dbparam["dbname"];
		$agora_dbhost = $agora_dbparam["dbhost"];
		$agora_dbport = $agora_dbparam["dbport"];
		$agora_dbuser = $agora_dbparam["dbuser"];
		$agora_dbpassword = $agora_dbparam["dbpassword"];

		if ($site_access != $agora_access) {
			include ("$inc_dir/$agora_access.$ext");
		}
		$agora_db_class = "${agora_access}_access";
		$agora_db = new $agora_db_class;
		$ret = $agora_db->openDB($agora_dbhost, $agora_dbport, $agora_dbuser, $agora_dbpassword, $agora_dbname, "agora");
		$agora_db->insertUser ("agora", $u_fields);
	}

	echo "<br><br><center><table border width='80%'><tr><td><table width='100%'><tr><td align=center colspan=2><strong>User '$userid' has been created</strong></td></tr><tr><td align=center>";
	displayUrl("$WA_SELF?site=$site", "", "create another user", "Create another user");
	echo "</td><td align=center>";
	displayUrl("edit_user.$ext?site=$site&userid=$userid", "", "edit this user", "configure more about this user");
	print ("</td></tr></table></td></tr></table></center>");
	exit;
} // End $go

#  -------------------------------------------
#  Initialize default values then display FORM
#  -------------------------------------------

	$userid = (isset($userid)) ? $userid : "";
	$username = (isset($username)) ? $username : "";
	$useraddress = (isset($useraddress)) ? $useraddress : "";
	$homepage = (isset($homepage)) ? $homepage : "";
	$details = (isset($details)) ? $details : "";
	$mailok = (isset($mailok)) ? $mailok : "Y";

?>

 <SCRIPT type="text/javascript" LANGUAGE="JavaScript">
<!-- // Hide for old browsers
  function CheckForm(form) {
<?
	include "$tmpl_dir/admin/user_fields.$ext";
	/* Check for required fields */
	if (isset($bn_bind_var)) {
		while (list($field, $required) = each($bn_bind_var)) {
			if ($required) {
?>
    if (form.<?echo $field?>.value.length == 0) {
      alert ("<?DspMsg(56)?>");
      form.<?echo $field?>.focus();
      return false;
    }
<?
			}
		}
	}
?>
    return true;
  }
// End of script -->
 </SCRIPT>

<FORM NAME="form_post" METHOD="post" ACTION="<?echo $WA_SELF?>" onSubmit="return CheckForm(this);" >

<INPUT TYPE="hidden" NAME="site" VALUE="<?echo $site?>">
<INPUT TYPE="hidden" NAME="go" VALUE="1">
<INPUT TYPE="hidden" NAME="key" VALUE="<?echo $key?>">
<?php
	table_header ("Create a new user in the site: <em>$site</em>");
?>
 <TABLE BORDER="0" WIDTH="100%">
  <CAPTION><B>user informations</B></CAPTION>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>login (user id)</strong>: </TD>
   <TD><?textField ("userid", $userid, 30, 32);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>user's name</strong>: </TD>
   <TD><?textField ("username", $username, 30, 64);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>E-mail Address</strong>: </TD>
   <TD><?textField ("useraddress", $useraddress, 30, 255);?></td>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>Home page URL</strong>: </TD>
   <TD><?textField ("homepage", $homepage, 30, 255);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="TOP"><strong>description</strong>: </TD>
   <TD><?textArea ("details", $details, 2, 30);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>Give a password for this user</strong>: </TD>
   <TD><?passwordField ("passwd1", $passwd1, 30, 32);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>Please reenter the password</strong>: </TD>
   <TD><?passwordField ("passwd2", $passwd2, 30, 32);?></TD>
  </TR>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>Add this user to the mailing list?</strong></td>
   <TD><? radioButton ("mailok", "Y", $mailok, "Yes");  
         radioButton ("mailok", "N", $mailok, "No"); ?></TD>
  </TR>
 </TABLE>
<?
## </td></tr>
# Initialize user privileges choices
# ----------------------------------
	$granted_privs["user"] = $user_privs["user"];

# super user/administrator can grant moderator privilege
	if (($auth->type=="root") || ($auth->type=="admin") ) {
		$granted_privs["moder"] = $user_privs["moder"];
	}

# super user can grant administrator privilege
	if ($auth->type=="root") {
		$granted_privs["admin"] = $user_privs["admin"];
	}

# Only 'admin' can grant sysadmin privilege
	if ($auth->userid=="admin") {
		$granted_privs["root"] = $user_privs["root"];
	}

# Now displays a combo with granteable privileges if we are admin or root
	if (count($granted_privs) > 1) {
## <TR><TD>
?>
 <TABLE BORDER=0 WIDTH="100%">
  <CAPTION><B>User privileges</B></CAPTION>
  <TR>
   <TD WIDTH="40%" ALIGN="RIGHT" VALIGN="MIDDLE"><strong>Choose privilege for this user</strong>: </TD>
   <TD><?listBox ("userpriv", $granted_privs, "user");?></TD>
  </TR>
 </TABLE>
<?
## </TD></TR>
	} else {
		hiddenField ("userpriv", "user"); 
	}
	
# Now, if the logged user is a moderator: we display all the forums he is responsible for
# ---------------------------------------------------------------------------------------
	if ( ($auth->level >= MODER) && is_array ($forums) ) {
		reset ($forums);
		echo "<TABLE border=1 WIDTH='100%'>";
		caption ("<b>set privileges over availables forums for this user</b><br>
  	       As a ". $user_privs[$auth->type] . " select the access privileges you want to grant to this user", "");
		echo "<tr><th>Forum</th><th>Title</th><th>can list</th><th>can read</th><th>can write</th>";
		if ($auth->level > MODER) {
			echo "<th>moderator</th>";
		}
		echo "<th>active</th></tr>";
		while (list($name) = each ($forums) ) {
			$bn_title = $forums[$name]["bn_title"];
			$forum = $forums[$name]["bn_name"];
			printf ("<tr><td><b>%s</b></td><td>%s</TD><td>", $name, $bn_title);
			checkBox ($forum."[listpriv]", "1", "1");
			print ("</td><td>");
			checkBox ($forum."[readpriv]", "1", "1");
			print ("</td><td>");
			checkBox ($forum."[writepriv]", "1", "1");
			print ("</td><td>");
			if ($auth->level > MODER) {
				checkBox ($forum."[modpriv]", "1", "0");
				print ("</td><td>");
			}
			checkBox ($forum."[state]", "1", "1");
			print ("</td></tr>");
		}
		echo " </TABLE>";
	}
?>
<br>
<center>
 <INPUT TYPE="submit" VALUE="Create user">
 <INPUT TYPE="reset"  VALUE="Reset">
</CENTER>
<?php table_footer() ?>
</FORM>
</BODY>
</HTML>
