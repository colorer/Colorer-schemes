# Copyright (C) 2000 Mark Stosberg <mark@stosberg.com>
# Licensed under the the GNU GPL, available here: http://www.gnu.org/copyleft/gpl.html

# Originally by Mark Stosberg mark@summersault.com for the skatepark.org website
# inspired by sumsearch by Chris Hardie <chris@summersault.com>

=pod

=head1 NAME

Cascade - Content Management System for a database driven web based dir

=head1 SYNOPSIS

Cascade is expected to be used by an instance script, 
which provides loads a configuration file and runs
the web application. See C<html_path/cgi-bin/cascade.cgi>
included in the distribution for a working example. You
may be able use this directly, only changing 
the configuration file to make it work for you. An
example configuration file is provided in the distribution
at C<config/config.pl>.

=head1 DESCRIPTION 

Cascade is a content management application for a database-driven
web-based directory. Since it's primarily intended to be used as an
application rather than directly as Perl modules, most of the
documention here of how the module works won't be interesting to most
users. Instead, read the INSTALL file in the distribution to get your
site up and running. The remaining documentation in the Cascade
modules for is provided for hackers who might want to tinker with the
code, and for myself, so I can remember why I did the things I did. 

For a detailed description of Cascade, see:
http://summersault.com/software/cascade 

=head1 AUTHOR

Copyright (C) 2000-2001 Mark Stosberg <mark@stosberg.com>

This library is free software; you can redistribute it and/or modify

 
Address bug reports and comments to: mark@stosberg.com.  When sending
bug reports, please provide the version of Cascade, the version of
Perl, the name and version of your Web server, the name and version of
the operating system you are using, and the name and version of the
database you are using.  If the problem is even remotely browser
dependent, please provide information about the affected browers as
well.

=head1 SEE ALSO

perl(1).

=head2 Steps for adding a new run mode

=over 4

=item * Add entry in run_modes() hash in &Cascade::setup

=item * If run mode is non-public, create an appropriate entry in the
        RM_AUTH hash in config/config.pl

=item * Add run mode to appropriate module. Right now this
     Cascade::Admin for editor and admin run modes, and Cascade.pm
     for most everything else. 

=back

See the documentation for CGI::Application for further information on
run modes.

=cut

package Cascade;
# CGI::Application will "use CGI" for us, but it doesn't check the version, 
# so we do that here. In earlier versions, "Vars" may not work as we'd like or expect. -mls
use CGI 2.75;
use base 'CGI::Application';

use DBI 1.20; # we depened on some features added in this version 
use CGI::Carp;

# Global variables
# %TMPL is a global hash to for template handle recycling
#   the keys are filenames and the values are handles for those files
use vars qw (
	$DBH
	$DEBUG
	$VERSION  
	%CFG
	%FORM
	%SES
	%TMPL  
	$q
);

require Exporter;
push @ISA, qw(Exporter);

@EXPORT_OK = qw(
  $DBH
  $VERSION
  %CFG
  %FORM
  %SES
  %TMPL
  &_html_error
  &cat_already_exists
  &check_cat_url
  &conflicts_with_existing_cat
  &err
  &footer_html_tmpl
  &front_page
  &gettext
  &html_item_new
  &illegal_chars
  &is_role
  &validate_image
  $q
  &htmlicize
  &insert_hash
);

@EXPORT = @EXPORT_OK;
use strict;

use Cascade::Auth;
require Cascade::Category;
require Cascade::Item;

# XXX How can I avoid loading the admin module for every page? 
require Cascade::Admin;
$VERSION = '2.1.2'; 

# Internationalization stuff
if ( $CFG{LAN} ne '' and $CFG{LAN} ne 'en' ) { 
    # XXX very broken for now, because gettext is sparsely used. -mls
    # We require rather than 'use' POSIX here so it only get's loaded inside of this "if" block
    require POSIX;
    import POSIX;
    eval "use Locale::gettext";
    $ENV{LC_MESSAGES} = $CFG{LAN} ;
    bindtextdomain($CFG{DATABASE},$CFG{CATDIR} ) ;
    textdomain($CFG{DATABASE}); 
    POSIX::setlocale(&POSIX::LC_MESSAGES, '');
}
else {
  # In case that we dont want to use gettext, this is  the shortcut
  *gettext= sub { return shift };
}

sub setup {
	my $self = shift;
	$DBH ||= connect_db() or die "Could not connect to database. Check connection parameters";

	# Put param variables into a global hash
	$q = $self->query; 
	%FORM = (%FORM, $q->Vars);

# set $FORM{rm} (run mode)
	$FORM{rm} ||= 'front_page';
	$self->get_mode_param;

	%SES = validate_session();
#  It would be nice to distinquish failures that occur when people are
#  logged in, just not at a high enough level (ie, they are logged in
#  as editor, but the run mode requires them to be an admin). This isn't the way to
#  do it.
#  $SES{valid_idle} or print
#  CGI::header().err(title=>'Insufficient Authorization', msg=>'The
#  user you logged in as does not have permission to view this page.')
#  and exit;
	my $start_mode = $SES{valid_idle} ? $FORM{rm} : 'login'; 
	$self->start_mode($start_mode);

	$self->run_modes(
			'front_page' => 'front_page',
# "cat" is just a short alias for "category_page"
			'cat'	      => 'category_page',
			'category_page' => 'category_page',
			'item_add_form' => 'item_add_form',
			'item_suggest_add' => 'item_suggest_add', 
			'item_approve_add' => 'item_approve_add',
			item_approve_insert => 'item_approve_insert',
			item_approve_update => 'item_approve_update',
			'item_edit_form' => 'item_edit_form',
			'item_delete_checklist' => 'item_delete_checklist',
			'item_list_delete_urls' => 'item_list_delete_urls',
# we make this alias so we can force editors to login when they visit urls via email to edit suggestions -mls
			item_edit_suggestion_form => 'item_edit_form',
			'item_new'	=> 'html_item_new',
			'write_static_pages' => 'write_static_pages',
			'item_suggest_update' => 'item_suggest_update',
			'cat_add_form' => 'cat_add_form',
			'cat_add_process' => 'cat_add_process',
			'link_form' => 'link_form',
			'link_add'  => 'link_add',
			'link_edit' => 'link_edit',
			'link_delete' => 'link_delete',
			'cat_relate_form' => 'cat_relate_form',
			'cat_relate_update' => 'cat_relate_update',
			'cat_edit_form' => 'cat_edit_form',
			'cat_update'	=> 'cat_update',
			'cat_delete'	=> 'cat_delete',
			'item_delete' => 'item_delete',
			'needs_approval_summary' => 'needs_approval_summary',
			'unverified_urls_report' => 'unverified_urls_report',
			search_zip	=> 'search_zip',
			item_edit => 'item_edit',
			item_suggest_update_form => 'item_suggest_update_form',
			item_suggest_update_thanks => 'item_suggest_update_thanks',
			login	=> 'login_form',
			login_process => 'login_process',
			logout	=> 'logout',
			register_form => 'register_form',
			register_process => 'register_process',
			password_forgot_form => 'password_forgot_form',
			password_mail_forgotten => 'password_mail_forgotten',
			password_mail_success => 'password_mail_success',
			item_view_comments => 'item_view_comments',
			item_comment_post  => 'item_comment_post',
			item_comments_delete => 'item_comments_delete',
			item_include_comments => 'item_include_comments',
			pvt_basic_info_update_form => sub { require Cascade::User; &pvt_basic_info_update_form }, 
			pvt_home => sub { require Cascade::User; &pvt_home }, 
			shared_home => sub { require Cascade::User; &shared_home }, 
			pvt_basic_info_process => sub { require Cascade::User; &pvt_basic_info_process }, 
			current_contributors => sub { require Cascade::User; &current_contributors }, 
			historical_month_index => 'historical_month_index', 
			historical_all_index => 'historical_all_index', 
			AUTOLOAD		   => 
				sub { return err(title=>'Page not found',msg=>"(the run mode tried was: $FORM{rm})") }
			);

# This happens here so that we can declare $VERSION in Cascade.pm to make CPAN happy
# but also have a copy in %CFG to make template management easier. -mls
			$CFG{VERSION} = $VERSION;
}

# use the first piece of PATH_INFO, or just look in $FORM{rm};
sub get_mode_param {
   # The run mode is the first chunk, the rest goes back into PATH_INFO
   # We ignore any leading slashes
   my $pi;
   ($pi, $ENV{PATH_INFO}) = $ENV{PATH_INFO} =~ m@^/*([^/]*)/*(.*)$@;

  $FORM{rm} = (length $pi) ? $pi : $FORM{rm}; 
}

=pod 

=head2 A note about template namespaces

A few prefixes in the template namespace are reserved for use by Cascade. These include:

=over 4

=item * cfg_ -- variables from the CFG hash

=item * ses_ -- session variables

=item * err_ -- error variables

=item * role_ -- role variables 

=back

=cut

sub load_tmpl {
        my $self = shift;
        my ($tmpl_file, @extra_params) = @_;
 
        my $fq_tmpl_file = $self->tmpl_path() . $tmpl_file;
 
        require HTML::Template;
	# set up the templates with some defaults
        my $t = HTML::Template->new_file($fq_tmpl_file, @extra_params, %{ $CFG{HTML_TMPL_DEFAULTS} });

	$t->param(
		# supply global config variables to the templates. Rather than pollute the name space
		# let's prefix them with cfg_, dawg. 
	   (map {
	      my $k = $_;
	      'CFG_'.$k =>  $CFG{$k};
	   } keys %CFG),
	   # supply global session variables to the template
	   (map {
	      my $k = $_;
	      'SES_'.$k =>  $SES{$k};
	   } keys %SES),
	  );
        return $t;
}


sub connect_db {

    my $dsn;
    if ($CFG{DRIVER} eq 'mysql') {
    	$dsn = "DBI:$CFG{DRIVER}:database=$CFG{DATABASE};host=$CFG{DBSERVER};port=$CFG{DBPORT}";
    # Default to Postgres' style dsn for now
    } else {
    	$dsn = "dbi:$CFG{DRIVER}:dbname=$CFG{DATABASE};".
    		($CFG{DBSERVER} and "host=$CFG{DBSERVER};").
    		($CFG{DBOPTIONS} and "options=$CFG{DBOPTIONS};").
    		($CFG{DBPORT} and "port=$CFG{DBPORT};");
    }		
    
    my $rv = $DBH =  DBI->connect($dsn,
			   $CFG{DBUSER},$CFG{DBPASS},
			   {
			       PrintError => 1,
			       RaiseError => 0,
			   } );
	return $rv; 			   
}





# Establish some defaults and provide a template to call CGI::Err with.
sub err {

	my %args = (
		debug	=> $DEBUG,
		@_
	);
	
	require HTML::Template;

	# We treat the header and footer differently since they rely on other values in the incoming hash. 
	my $tmpl = new HTML::Template(
		die_on_bad_params=>0,
		path=>$CFG{HTML_TEMPLATE_ROOT},
		filename=>'error.tmpl'
	);
	
	if ($args{debug}) {
	    my ($package, $file, $line, $sub) = (caller(2))[0,1,2,3];
	    my $q = new CGI;
	    $args{debugging_text} = "Package: $package<BR> File: $file <BR>Line: $line <BR> Subroutine: $sub<P>" .$q->Dump;
	}

	$args{page_title} = $args{title};
	$tmpl->param(%args,contact_email=>$CFG{CONTACT_EMAIL});

	return $tmpl->output;
  
}


# Currently not used
# sub get_user_item_rating {
#   
#   my ($user_id, $item_id, $category_id) = @_;
#   
#   my $rating = $DBH->selectrow_array("select rating from rating 
#       where (user_id = $user_id
#       and item_id = $item_id
#       and category_id = $category_id)");
#   
#   return $rating;
# 
# }




# Used to to check to see whether the Input URL is a valid category, returns the category_id if true,
# or undef if false
sub check_cat_url {
   my $self = shift;
   my $url = shift;
   my @cat_ids;
	
   # Be forgiving about leading and trailing whitespace (delete it)
   $url =~ s/^\s+|\s+$//g;

   # If it's a static page, we want to get rid of HTML_ROOT_URL first
   $url =~ s/^$CFG{HTML_ROOT_URL}//;
   
   # Undo encoding

   # underscores back to spaces
   $url =~ s/_/ /g;

   # x's, which represent characters that don't make good urls, get turned into %
   # for SQL LIKE pattern matching. -mls
   $url =~ s/x/%/g;
	
   # Split into directory names
   my @cats = split "/", $url;

   # The first element of the array is probably a null troublemaker. -mls
   my $discard = shift @cats unless $cats[0];
	
   @cats = reverse @cats;
	
   # Create a SQL statement to see if this directory really exists. 
   my (@from_bits, @where_bits);
   for (my $i = 0; $i <= $#cats; $i++) {
      my $i1 = $i+1;
      push @from_bits, "cas_category c$i";
      push @where_bits, "c$i1.category_id = c$i.parent_id" unless $i == $#cats;
      push @where_bits, "c$i.name LIKE ".$DBH->quote($cats[$i]); 
   }
	
   my $sql = "SELECT c0.category_id FROM ".(join ', ', @from_bits)." WHERE ".join "\nand ", @where_bits;
   $sql .= " AND c$#cats.parent_id = 0";
	
   my $cat_id = $DBH->selectrow_array($sql);

   #If we made it this far, all's good. Return the $target_id
   return $cat_id;
}

# Before we compare a submitted URL to one in the database, let's reduce the chance that 2 equivalent URLS will appear different.
# We can lowercase the URL, and chop off standard directory prefixes. 
sub base_url {
	my $url = shift;
	$url =~ s%(.*)(default|welcome|index)\.(cgi|s?html?|tcl|adp|asp|pl)$%$1%i;
	return (lc $url);
}

# returns the html page for "what's new" page
# deprecated. May go away in favor of historical_* run modes
sub html_item_new {
   my $self = shift;
   my $tbl = Cascade::Item::most_recent($CFG{BUILD_NEW_CUTOFF}); 
   my %cats;
   while (my $row = shift @$tbl) {
      push @{ $cats{ $row->[1] } }, $row->[0]
   }

   my (@tmpl_cats,$cut_off);
   foreach my $cat_id (keys %cats) {
      my $cat = Cascade::Category->new(id=>$cat_id);
      my %cat = (multi_link=> $cat->name('multi_link'));
      foreach my $item_id (@{ $cats{$cat_id} }) {
	 $cut_off++;
	 my $item = Cascade::Item->new(id=>$item_id,category_id=>$cat_id);
	 $cat{items} .= "<LI>".$item->output_html(date_added=>1);	
      }	
      push @tmpl_cats, \%cat;
   }
	
   my $tmpl = $self->load_tmpl('whats-new.tmpl' );
  
   $tmpl->param(
		whats_new			=> \@tmpl_cats,
		cutoff				=> $cut_off,
		page_title			=> gettext('What\'s New'),
		&footer_html_tmpl
	       );
  
   return $tmpl->output;
}

sub historical_month_index {
   my $self = shift;
   # default to the current month 
   my $month = shift || $FORM{historical_month}; 
   # If nothing was passed in directly or in the form, this is the default view. 
   my $default;
   unless ($month) {
      $default = 1;
      $month = $DBH->selectrow_array("SELECT date_trunc('month',CURRENT_DATE)");
   }
   $month = $DBH->quote($month);

   my $t = $self->load_tmpl('historical-month-index.tmpl');

   # get all the item_ids for a month
   my $items = $DBH->selectcol_arrayref("select 
	item_id 
	from cas_item_approved
        WHERE date_trunc('month',COALESCE(historical_date,approved_date,insert_date)) =
            date_trunc('month',CAST($month AS DATE))
        ORDER BY COALESCE(historical_date,approved_date,insert_date) DESC ");

   my $prev_month = $DBH->selectrow_array("
        SELECT  date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date
	as previous_month
	FROM cas_item_approved
	WHERE date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date 
	    < date_trunc('month',CAST($month AS DATE))
	ORDER BY date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date DESC
	LIMIT 1");

   # If there are no items in the default month,
   # and there are in the previous month, return that instead. 
   if ((not scalar @$items) and $prev_month and $default) {
      return $self->historical_month_index($prev_month);
   }

   my @entries;
   for (@$items) {
      # We use static mode here because currently the edit link won't work because
      # we are requiring a category_id at the moment. -mls
       my $item = Cascade::Item->new(id=>$_,mode=>'static');
	push @entries, { 'item_html' => $item->output_html(date_added=>1) };
   }
   $t->param( prev_month   => $prev_month);
   $t->param(
      next_month   =>$DBH->selectrow_array("
        SELECT  date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date
	as next_month
	FROM cas_item_approved
	WHERE date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date 
	    > date_trunc('month',CAST($month AS DATE))
	ORDER BY date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date ASC
	LIMIT 1 "));
	 
	  my $mode = 'static' unless $CFG{DYNAMIC_ONLY_P};
     $t->param(
      month_as_text=>$DBH->selectrow_array("
        SELECT to_char(CAST($month AS DATE), 'FMMonth, YYYY') "),
       entries=>\@entries,
      footer_html_tmpl($mode),
     );	
   return $t->output;
}

# display historical index of all data. Pass in a year
# directly or through the FORM to view just one year. -mls 
sub historical_all_index {
   my $self = shift;
   my %in = (
      year => $FORM{year},
      @_,
     );
   my $t = $self->load_tmpl('historical-all-index.tmpl');

   my $LoH = $DBH->selectall_arrayref("select 
	extract(year from COALESCE(historical_date,approved_date,insert_date)::date) as year,
	to_char( COALESCE(historical_date,approved_date,insert_date)::date, 'FMMonth, YYYY') as month_as_text,
	 date_trunc('month',COALESCE(historical_date,approved_date,insert_date))::date as month_as_date,
	count(item_id) as items_in_month
	from cas_item_approved ".
        ($in{year} && 
	   "WHERE extract(year from COALESCE(historical_date,approved_date,insert_date)::date) = ".$DBH->quote($in{year}))."
      GROUP BY year,month_as_text, month_as_date
      ORDER BY  month_as_date ASC", { Slice => {} });

   my %years;
   for (@$LoH) {
      my $y = $_->{year};
      $years{$y}->{year} = $y;
      $_->{one_entry} = 1 if ($_->{items_in_month} == 1);
      # add the global we need inside this loop
      $_->{cfg_cascade_cgi} = $CFG{CASCADE_CGI};
      push @{ $years{$y}->{months} }, $_;
   };

   # If we are not in "dynamic only" mode, we want to show static links in the footer here.
   my $mode = 'static' unless $CFG{DYNAMIC_ONLY_P};
   $t->param(
      page_title=>"Historical View of $CFG{SYSTEM_NAME}",
      footer_html_tmpl($mode),
    );
   $t->param(years=>[sort { $b->{year} <=> $a->{year} } values %years ]);
   return $t->output;
}

sub search_zip {
  my $self = shift;

  # default to 50 miles. -mls
  # XXX another candidate for moving to the config file
  my $radius = $FORM{'distance'} || 50; 

  # Convert kilometers to miles if needed
  if ($FORM{units} eq 'kilometers') {
    $radius *= .62140;
  }

  if (($FORM{'zipcode'} =~ m/^\d\d\d\d\d$/ ) ||
	( ($FORM{'city'} =~ /\w/) && ($FORM{'st'} =~ /\w/) ) ) {
     # We trim off the first 28 characters of the city because
     # that's all that's in my zipcode database -mls
     # Find all the zipcodes that have a close enough latitude or
     # longitude
     # it's important to join on the item table-- this speeds thing up
     # A LOT In a less sophicated database (like MySQL), you could
     # accomplish the same thing with 3 seperate selects
     # If you are here to think about making this work for another
     # database, note that I'm doing a number of functions in the
     # database (substr,trim,upper), which are probably better done in
     # Perl to be more portable.
    $DBH->{RaiseError} = 1;
   my $items;
    eval {
       my $matching_point = $DBH->selectrow_array("
        SELECT lon_lat 
	  FROM cas_zipcodes zipcodes
          WHERE zipcode = trim(".$DBH->quote($FORM{zipcode}).")
	    OR (city = substring(upper(trim(".$DBH->quote($FORM{city}).")) from 1 for 28) 
            AND state_code = upper(".$DBH->quote( $FORM{st} )."))");
       $matching_point or return undef;
    $items = $DBH->selectall_arrayref("
SELECT item.*,category_id 
 FROM cas_item item, cas_category_item_map category_item_map
 WHERE item.item_id = category_item_map.item_id 
   AND postal_code IN (
 SELECT distinct zipcode FROM cas_zipcodes zipcodes
   WHERE item.postal_code = zipcodes.zipcode
     AND (?::point <@> lon_lat ) < ? ) ",
	{  Slice=>{} },
		$matching_point, $radius
       )
      or return err(title=>'No Results',msg=>'Your search returned no results');
    };
    if ($@) {
       err(title=>'Database Error',
	   msg=>'There was a database error when searching. This error has been logged.')
    }
    else {
       return $self->search_results(undef,$items);
    }
  } else {
    return err(TITLE => 'Missing Fields', MSG => q{You Must specify a city and state or a zipcode to search. That's the breaks. });
  }
}


sub search_results  {
  my $self = shift;
  my ($cat_ref, $item_ref) = @_;

 return err(title=>'No matches found',msg=>'No results were found matching your query') 
   unless ($item_ref or $cat_ref);
	
  my @cats;
  foreach my $row (@$cat_ref) {
    my ($id, $name, $desc, $items_below) = @$row;
    my  $cat = Cascade::Category->new(id=>$id,populate=>0);
    push @cats, { 
      name 		=> $cat->relative($name),
      items_below => $items_below,
      description	=> $desc
     };	
  }                 
	                  
  my @items;
  # Note: I changed how this worked around 1.3.8
  # instead of passing in an array of item ids, we are now passing in
  # an array of hash references with item data
  foreach my $item_ref (@$item_ref) {
    my $item = Cascade::Item->new(id=>$item_ref->{id},data=>$item_ref);
    push @items, $item->output_html();
  }
	
    my $tmpl = $self->load_tmpl('search-results.tmpl');
	  	
    $tmpl->param(
      cats				=> \@cats,
      items				=> CGI::li([@items]),
      &footer_html_tmpl
     );

    return $tmpl->output;
}	

sub illegal_chars {
    if ($FORM{'name'} =~ m/([_])/) {
	my $msg = gettext("Your Name contained the illegal character").
	    " <B>$1</B>. ".gettext("Go back and try again.");
	return err(title => gettext("Illegal Character"), msg => $msg);
     }

}

# check to  see if a category already exists
sub cat_already_exists {
	# If they pass in a $cat_id, we assume this check is for an edit,
	# otherwise we assume it's for an addition. If we have it's
	# $cat_id, we can make sure it doesn't show up falsely as a
	# duplicate of itself. -mls
	my ($name,$parent_id,$cat_id) = @_;
	(length $name && length $parent_id) or die "no category name and parent_id found"; 

	my @bind = (lc $name, $parent_id);
	my $sql = "select category_id from cas_category
      where lower(name) =  ?
      and   parent_id = ? ";
  	if (length $cat_id) {
		push @bind, $cat_id;
		$sql .= " category_id <> ? ";
	}

	if (defined $cat_id) {
		 my $cat = Cascade::Category->new(id=>$cat_id, mode=>'dynamic');
		 my $msg =  gettext("The Category you have submitted ").
		     gettext("is already in our database"). ':<P>'.$cat->name('plain').'<P>'.
			     gettext("Try another!");	
		 return err(title => gettext("Category Exists"), msg => $msg);
	}                              
}

# This tests for the case in which the category maps to directory name which is the same as an existing category
sub conflicts_with_existing_cat {
	my $name = $FORM{name};

	require Cascade::Category;
	my $enc_name = Cascade::Category::encode_name($name);

	length $FORM{category_id} and length $FORM{parent_id} or return undef;
	my $tbl = $DBH->selectall_arrayref("
		SELECT category_id, name
			FROM cas_category
			WHERE parent_id = ?
				AND category_id != ?
	",{},$FORM{parent_id},$FORM{category_id});
	
	if ($tbl) {
		foreach my $row (@$tbl) {
			my ($cat_id, $name) = @$row;
			$name = Cascade::Category::encode_name($name);
			if ((lc $name) eq (lc $enc_name)) {
				my $msg = gettext("The Category you have submitted ").
					gettext("conflicts with a pre-existing one named <B>$name</B>").
					'<P>'.gettext("Try another!");
				return 	err(title => gettext("Category Conflict"), msg => $msg);	
			} 
		}
	}
}

# is the user logged in as one of the passed in roles?
# takes array of roles as input
sub is_role {
   (my @roles = @_) || return undef;
	
   my $user_id = $DBH->selectrow_array("
		SELECT user_id 
		FROM cas_users
		WHERE role in  (".(join ',',map { $DBH->quote($_) } @roles).")
			AND user_id = ?
	",{},$SES{user_id});	
   return $user_id;
}

sub item_id_from_title {
   my ($title,$cat_id) = @_;
   $title and $cat_id or return undef;
   # strip leading and trailing new lines and spaces to make the form more copy/paste friendly
   $title =~ s/^\s+|[\n\r\s]+$//;

   return $DBH->selectrow_array("
		SELECT item.item_id 
			FROM cas_item item, cas_category_item_map category_item_map
			WHERE lower(title) = ?
				AND item.item_id = category_item_map.item_id
				AND category_item_map.category_id = ? ",{},
			lc $title, $cat_id
		);	 
}



# prepare the content used in the html footer
sub footer_html_tmpl {
   my $mode = shift;
	 my %footer = (
	 	footer_cats         		=> Cascade::Category->footer_cats($mode),
		version				=> $CFG{VERSION}
	 );
	 return %footer;
}

sub front_page {
  my $self = shift;
  my $cat = Cascade::Category->new(id=>0);

  # If we are in static mode, we just redirect and we're done
  my $user_id;
  # I don't remember why I set max_includes to be 5. -mls 
  my $tmpl = $self->load_tmpl('front-page.tmpl', max_includes=>5);


  my ($total_states, $total_countries, $total_resources);
    ($total_states) = $DBH->selectrow_array("
        SELECT count(distinct state) FROM cas_item WHERE state is not null and approval_state = 'approved' ");

    ($total_countries) = $DBH->selectrow_array("
        SELECT count(distinct country) FROM cas_item WHERE country is not null and approval_state = 'approved' ");

    ($total_resources) = $DBH->selectrow_array("
        SELECT count(*) FROM cas_item where approval_state = 'approved' ");

 my ($suggested_inserts,$suggested_updates);
  if ($SES{role_admin}) {
	if ($CFG{DISPLAY_SUGGESTION_LINKS_P}) {
      ($suggested_inserts) = $DBH->selectrow_array("
         SELECT count(item.item_id)
            FROM cas_item item, cas_category_item_map category_item_map
            WHERE item.item_id = category_item_map.item_id AND item.approval_state = 'needs_approval'");
      ($suggested_updates) = $DBH->selectrow_array("
         SELECT count(item_update_id) FROM cas_item_suggested_updates");
	}
	$tmpl->param( any_links_verified => 
		$DBH->selectrow_array("
		        SELECT item_id FROM cas_item WHERE url_verified_date is not null LIMIT 1"));
	$tmpl->param( num_links_appear_stale => 
		$DBH->selectrow_array("
		SELECT count(item_id) FROM cas_item
	        WHERE url like 'http%' 
        	AND
        	 ( url_verified_date is null )
       		OR
        	 ( url_verified_date < (CURRENT_DATE - '30 days'::interval)::date
           		AND url_verified_date is not null )"));
   }
    # XXX editors will need their own select statement here
  
  my $subcats = $cat->sub_cats; 
  for (my $i = 0; $i < @$subcats; $i++) {
     # create a new category object
     my $cat = new Cascade::Category (id=> $subcats->[$i]->{cat_id});		
     # get the subsubcats for this subcat, if any
     $subcats->[$i]->{subcats} = $cat->sub_cats(include_items_below=>0);
  }
 
  # handle the "new items"
  my ($new_cutoff,@new_items);
  if (my $tbl = Cascade::Item::most_recent($CFG{FRONT_PAGE_NEW_CUTOFF})) {
  # You may wonder why we bother computing the cutoff here when we have it already in a config variable
  # If the config variable says 10, and there are are only 9 items, this will correctly display "9"
  # Instead of announcing there are 10 items when there aren't. -mls
     $new_cutoff = (@$tbl < $CFG{FRONT_PAGE_NEW_CUTOFF} ) 
       ? scalar @$tbl
	 : $CFG{FRONT_PAGE_NEW_CUTOFF} ;
     foreach my $row (@$tbl) {
	my ($item_id,$cat_id) = @$row;
	my $item = Cascade::Item->new(id=>$item_id,category_id=>$cat_id);
	push @new_items, { item_html => $item->output_html(style=>'short') };
     }	
  }
     $tmpl->param(
       new_items		=> \@new_items,
       new_cutoff		=> $new_cutoff,
       suggested_inserts	=> $suggested_inserts,
       suggested_updates	=> $suggested_updates,
       any_suggestions		=> $suggested_updates+$suggested_inserts,
       sub_cats			=> $subcats,
       role_admin		 => $SES{role_admin},
     	total_resources		=> $total_resources,
     	total_states		=> $total_states,
     	total_countries		=> $total_countries,
     	page_title				=> $CFG{SYSTEM_NAME},
     	states_plural		=> 'state'.(($total_states != 1) && 's'),
     	countries_plural	=> 'countr'.($total_countries == 1 ? 'y' : 'ies'),
     	items				=> $cat->get_item_html,
        whats_new_link		=> "$CFG{CASCADE_CGI}/historical_month_index",
	#  ($FORM{mode} eq 'static') ? $CFG{WHATS_NEW_URL} : "$CFG{CASCADE_CGI}/historical_month_index",
		&footer_html_tmpl	
     );
  $tmpl->param('display_admin_links'=>1) if (($FORM{mode} eq 'dynamic') and $SES{role_admin});		
  $self->header_props(-expires=>'-3m',-type=>'text/html');
  return $tmpl->output;
}

sub category_page {
   my $self = shift;
   my $cat_id = shift;
   $cat_id = (length $cat_id) 
     ? $cat_id  
       : (length $FORM{category_id}) 
	 ? $FORM{category_id} 
	   : $self->check_cat_url($ENV{PATH_INFO});

   my $cat = Cascade::Category->new(id=>$cat_id);

   # If the category didn't work out, it could be because it was for category that
   # has a static page, but doesn't have an entry in the database. 
   # For that rare case, we return people to the front page by using category_id zero instead. -mls
   unless ($cat) {
      if ($FORM{mode} eq 'static') {
	 $self->header_type('redirect');
	 $self->header_props(-url=>$CFG{HTML_ROOT_URL}); 
	 return;
      }
      else {
	 return $self->front_page; 
       }
   }

   #if they want a static category, we redirect them
   # redirecting the dynamic page would create a loop. -mls
   if ($FORM{mode} eq 'static') {
       $self->header_type('redirect');
       $self->header_props(-url=>$cat->name('full_url')); 
   }
   else {
       # make an exception for the top category
       return $self->front_page if $cat_id == 0;

       my $t = $self->load_tmpl('category.tmpl');
       $t->param($cat->html_page(user_id=>$SES{user_id}));
       return $t->output;
   }
}

sub item_add_form {
   my $self = shift;
   my $errs = shift;

   # If we aren't passed a type_id, we use the default for this category. 
   my $type_id = $FORM{type_id};
   if ((not length $type_id) and (length $FORM{category_id})) {
      my $cat = Cascade::Category->new(id=>$FORM{category_id});
      $type_id = $cat->default_type_id;  
   }
   my $item = Cascade::Item->new(category_id=>$FORM{category_id},type_id=>$type_id);
   $self->header_props(-expires=>'-3m',-type=>'text/html');

   my $t = $self->load_tmpl('items/'.$item->type_tech_name.'-form.tmpl');
   $t->param(
      $item->html_form,
      %$errs
     );

   return $t->output; 
}

sub item_edit_form {
   my $self = shift;
   my $errs = shift;
   (defined $FORM{'item_id'} or $FORM{title} or $FORM{item_update_id}) or 
	return err(title => gettext("Insufficient Information"), 
		   msg =>
		     gettext("There must be an item_id or title or item_update_id ").
		       gettext("present to edit the item"));
   my ($ItemId,$Table,$orig_item_html);
   my $change_cat = 1;
   if ($FORM{item_update_id}) {
     $ItemId = $FORM{item_update_id};
     $Table = 'cas_item_suggested_updates';
     
   }

   # XXX For now we assume that if people are using a title to update the item
   # They are a user
   elsif (not $FORM{item_id} and $FORM{title}) {
     $ItemId = item_id_from_title($FORM{title},$FORM{category_id}) or
       return err(title=>'No Matches Found',
	   msg=>'There were no items found with that title in this category. 				Try returning to the category and copying and pasting the item title precisely.
				It\'s also possible that the item no longer exists in the database, although 
				it still appears on the website. 		
				');
     $Table = 'cas_item';
     $change_cat = 0;
   }
   else {	 
     $ItemId = $FORM{item_id};
     $Table = 'cas_item';
   }	
   my $item = Cascade::Item->new(
     category_id=>$FORM{category_id},
	id=>$ItemId,
	table=>$Table);  
   $item || return err(title=>'No Item Found', msg=>'No Item found with that item_id');
   my $t = $self->load_tmpl('items/'.$item->type_tech_name.'-form.tmpl');

    # Get the HTML for the original item to display as a comparison (if that applies)
   if ($Table eq 'cas_item_suggested_updates') {
      my $orig_item = Cascade::Item->new(id=>$item->field('item_id'));
      $t->param(orig_item_html=>$orig_item->output_html);
   }
      
   $self->header_props(-expires=>'-3m',-type=>'text/html');
   $t->param(
      $item->html_form(change_category=>$change_cat),
      %$errs,
 );
   return $t->output; 
}

sub item_suggest_add {
   my $self = shift; 
   
   my $item = Cascade::Item->new(category_id=>$FORM{category_id});
   
   $item->validate_form;

   # if there are errors, return the errors
   if ($item->missing or $item->invalid) {
      require HTML::FillInForm;
      my $fif = new HTML::FillInForm;
      return $fif->fill(
	 scalarref => \$self->item_add_form(
	    error_marks( [ $item->missing ], [ $item->invalid ], $item->validation_msgs )	
	   ),
	 fobject => $self->query),
   }

   my %params = $item->already_exists;
   if ($params{self_html}) {
      my $t = $self->load_tmpl('item-duplicate.tmpl');
      $t->param(%params);
      return $t->output;
   }

   # are we suggesting an update are actually making one? 
   my ($send_alerts_p);
   unless ($SES{role_admin} or $SES{role_editor}) {
      $send_alerts_p = 1;
   }
   
   # add the item to the database
   my $item_id;
   eval { $item_id = $item->insert };
   if ($@) {
      return err(title=>'Insert Failed',msg=>"The item could not be inserted due to the following error:<BR>$@");
   }	

   # send email alerts 
   $item = Cascade::Item->new(id=>$item_id,category_id=>$FORM{category_id});
   if (my $msg = $item->send_alerts) {
     my $t = $self->load_tmpl('emails/item-alert-new.txt');
     $t->param( $msg );
     open(MAIL, "|$CFG{MAILPROG}	-t") or return 
       err(title=>'Error Opening Mail Program', msg=>'There was an error opening the mail program');
     print MAIL $t->output;
     close(MAIL);
   }


   if ($SES{role_editor}) {
      # Return to the category_id we came from. 
      return $self->category_page($FORM{orig_category_id});
   }
   else {
      # XXX We should probably eventually great a page to thank people specifically for suggesting
      # an addition, but the current message is generic enough for now. -mls 
      return $self->item_suggest_update_thanks;
   }
}

sub item_suggest_update_form {
  my $self = shift;
  defined $FORM{category_id} or 
    return err(title => gettext("No Category ID specified"), 
	 msg => gettext("There must be a category_id ").gettext("present for this script to work"));
	 
  my $cat = Cascade::Category->new(id=>$FORM{category_id});

  my $tmpl = $self->load_tmpl('item-suggest-update.tmpl');
  $tmpl->param(
    plain	  => $cat->name('plain'),
    category_id => $FORM{category_id},
    mode	=> $FORM{mode},
    &footer_html_tmpl
   );
  return $tmpl->output;
}

sub item_edit {
  my $self = shift;

   (length $FORM{'item_id'} or $FORM{item_update_id}) or 
	return err(title => gettext("Insufficient Information"), 
		   msg => gettext("There must be an item_id or item_update_id ").
		       gettext("present to edit the item"));
  my ($ItemId,$Table,$return_mode);
   if ($FORM{item_update_id}) {
     $ItemId = $FORM{item_update_id};
     $Table = 'cas_item_suggested_updates';
     $return_mode = 'needs_approval_summary'
   }
   else {	 
     $ItemId = $FORM{item_id};
     $Table = 'cas_item';
   }

  my $item = Cascade::Item->new(
	#category_id=>$FORM{category_id},
	id=>$ItemId,
	table=>$Table );
  $return_mode ||= ($item->field('approval_state') eq 'needs_approval') ? 'needs_approval_summary' : 'category_page';
  

  $item->validate_form;

   # if there are errors, return the errors
   if ($item->missing or $item->invalid) {
      require HTML::FillInForm;
      my $fif = new HTML::FillInForm;
      return $fif->fill(
	 scalarref => \$self->item_edit_form( 
	    error_marks( [ $item->missing ], [ $item->invalid ], $item->validation_msgs)
	   ),
	 fobject => $self->query
	);
   }

   my %params = $item->already_exists;
   if ($params{self_html}) {
      my $t = $self->load_tmpl('item-duplicate.tmpl');
      $t->param(%params);
      return $t->output;
   }

    foreach my $field ('state','country') {
    	$self->query->Delete($field) if ((length  $self->query->param($field) ) != 2);
    }

  # Users just suggest edits, editors and admins actually make them
  if ($SES{role_admin} or $SES{role_editor}) {
    require Cascade::Admin;
    if ($item->update) {
       # update this form variable to return the category we came from. 
       $FORM{category_id} = $FORM{orig_category_id};
       # XXX It's only safe for admins to use this internal redirection
       # because it by-passes the auth checking for run modes in setup(). -mls
       # If $FORM{return_rm} is present, it supercedes the default return_mode. 
       $return_mode = $FORM{return_rm} || $return_mode;
       my $out = eval('$self->'.$return_mode); 
       $@ ? die "error run mode $return_mode was $@": return $out;
    }
    else {
       err(title=>'Item Not Updated',
		msg=>'The item was not updated. The database returned the error: '.$DBI::errstr);
    }
  }
  else {
     my $update_id;
      eval {$update_id = $item->suggest_update};
      $@ and return err(title=>'Insert Failed',
	msg=>"Inserting that suggested update failed with an unexpected error.
                   The error was: $@");
      if (my $msg = $item->send_alerts($update_id)) {
	 my $t = $self->load_tmpl('emails/item-alert-update.txt');
	 $t->param($msg);
	 open(MAIL, "|$CFG{MAILPROG} -t") or return 
	   err(title=>'Error Opening Mail Program', msg=>'There was an error opening the mail program');
	 print MAIL $t->output;
	 close(MAIL);
       }
     return $self->item_suggest_update_thanks
  }
}

sub item_suggest_update_thanks {
  my $self = shift;
  my $t = $self->load_tmpl('item_suggest_update_thanks.html');
  $t->param(footer_html_tmpl());
  return $t->output;
}

sub login_form {
   my $self = shift;

   my $return_rm;
   # If we have been passed an explicit return_rm, we use that first. 
   {
      if (length $FORM{return_rm}) { $return_rm = $FORM{return_rm}; last }
      
      # If we are being call from another run mode, we return there.
      # Otherwise, we return to their homepage 
      $return_rm = ($FORM{rm} =~ m/^login/) ? 'pvt_home' : $FORM{rm};
   }

   # If we are not in "dynamic only" mode, we want to show static links in the footer here.
   $FORM{mode} = 'static' unless $CFG{DYNAMIC_ONLY_P};

   my $t = $self->load_tmpl('register-index.tmpl');

   $t->param( 
      referred	=> (($FORM{rm} ne 'login') and 1),
      return_rm   => $return_rm,
      query_string => $self->query->escapeHTML($self->query->query_string),
     footer_html_tmpl());

   # Expire the existing cookie, just for good measure. 
   $self->header_props(-cookie=>create_cookie($SES{session_id},'-3M'));
   return $t->output;
}

sub login_process {
   my $self = shift;
   my ($user_id, $user_state,$role) = $DBH->selectrow_array("
     SELECT user_id,user_state,role
      FROM cas_users
      WHERE lower(email) = ?",{},lc $FORM{email});
   # If we recognize your email address
   if ($user_id) {
      if ($user_state eq 'authorized') {
	 my $recognize_both = $DBH->selectrow_array("
			SELECT user_id 
				FROM cas_users users
				WHERE users.user_id = $user_id 
					AND password = ?",{},$FORM{password});

	 # If we recognize your password, authorize and redirect you
	 if ($recognize_both) {
	    #my %session = validate_session();
	    add_userid_to_session(\%SES,$user_id);

		# if return_rm starts with 'http' we assume it's a 
		# full URL and use that. Otherwise, return_rm should be a run mode
		my $url;
		if ($FORM{return_rm} =~ m/^http/) {
			$url = $FORM{return_rm};
		}
		else {
			$url ="$CFG{CASCADE_CGI}/$FORM{return_rm}?$FORM{query_string}"; 
		}

	    $self->header_props(
	       -cookie=>create_cookie($SES{session_id}),
	       -url=>$url,
		 );

	    $self->header_type('redirect');
	    return;
	 } else {
	    return err(title=>'Bad Password',msg=>qq!The password is not correct.
                   If you've forgotten it, 
              <a href="$CFG{CASCADE_CGI}/password_mail_forgotten?user_id=$user_id">we can mail it to you.</A>!);
	 }
      } 
      else {
	 return err(title=>'Inactive account',msg=>'Your account is no longer active');
      }
   }
   else {
      return err(title=>'User not found',
		 msg=>'No user was not with that email address');
   }
}

# XXX maybe this run mode should really be Auth.pm. -mls
sub logout {
   my $self = shift;
   # We don't want to validate the session, since that would redirect them to register
   # if they are already logged out. Instead, we just grab the cookie directly. 
   my %session = ( session_id => $self->query->cookie($CFG{SESSION_COOKIE_NAME}) );
   require Cascade::Auth;
   remove_userid_from_session(\%session);
   $self->header_props( -cookie=>create_cookie($session{session_id},'-3M') );
   my $t = $self->load_tmpl('register-logout.tmpl');
   $t->param(
      top_url	=> !$CFG{DYNAMIC_ONLY_P} ? $CFG{HTML_ROOT_URL} : $CFG{CASCADE_CGI},
      return_rm => ($FORM{return_rm} || $ENV{HTTP_REFERER}) );
   return $t->output;
}
     
sub register_form {
   my $self = shift;
   my $errs = shift;

   # We don't want to pass through the run mode and confuse the
   # system. -mls
   delete $FORM{rm};
   my $t = $self->load_tmpl('register-form.tmpl');
   $t->param(  
      return_rm=>$FORM{return_rm},
      query_string => $self->query->escapeHTML($FORM{query_string}), 
      %$errs,
     );
   return $t->output;
}

sub register_process {
   my $self = shift;
   # validate form
   require Data::FormValidator;
   my %email_validation = (email => 'email') if $CFG{VERIFY_EMAILS_P};
   my $validator = new Data::FormValidator({
      form => {
	required => [qw/first_names last_name email password password_confirmation/],
	filters => 'trim',
	constraints => {
	   %email_validation,
	   },
	}
     });
     my ( $valid, $missing, $invalid ) = $validator->validate(  \%FORM, "form" );

   my $msgs;
   if ($FORM{password} ne $FORM{password_confirmation}) {
      $msgs->{password} = 'Password and Confirmation do not match.';
      push @$invalid, ('password', 'password_confirmation');
   }

   if (grep /^email$/, @$invalid) {
      $msgs->{email} = 'Invalid Email format';
   }

   # Are they already registered with this email address?
   # If the user_id return is greater than zero, they are. 
   if ( my $uid = 
   		$DBH->selectrow_array("SELECT user_id FROM cas_users WHERE lower(email) = ?",{},lc $FORM{email}) > 0 ) {
      push @$invalid, 'email';
      $msgs->{email} = qq!Already in system. 
       ( <a href="$CFG{CASCADE_CGI}/password_mail_forgotten?user_id=$uid">Send password to this address</a>&nbsp;)!;
   }

   # if there are errors, return the errors
   if (@$missing or @$invalid) {
      require HTML::FillInForm;
      my $fif = new HTML::FillInForm;
      return $fif->fill(
	 scalarref => \$self->register_form(
	    error_marks( $missing, $invalid,$msgs)
	   ),
	 fobject => $self->query),
   }
   # otherwise, return login_process with the info we've got
   else {
      # check for duplicate email address
      # insert into the database
      require DBIx::Abstract;
      my $db = DBIx::Abstract->connect($DBH);
      delete $valid->{password_confirmation};
      # XXX There's a good chance we should be verifying email addresses when people sign up. -mls
      $valid->{user_state} = 'authorized';
      $valid->{registration_ip} = $ENV{REMOTE_ADDR};
      $db->insert('cas_users',$valid);
      return $self->login_process;
   }
   
}
# create a hash from Data::FormValidator data for HTML::Template Input
# is a reference to a list of fields with errors and a hash of field
# names and custom error message messages
# output is hash reference for HTML::Template;
sub error_marks {
   my ($missing, $invalid, $msgs) = @_;
   
   # set one field just to say "we have some errors"
   my $err_h = { 'err__' => 1 };

   foreach my $err (@$missing) {
      $msgs->{$err} ||= 'Missing';
      $err_h->{'err_'.$err} =
	$CFG{ERROR_MARK}.'<B><font size="-1">'.$msgs->{$err}.'</font></B>';
   }
   foreach my $err (@$invalid) {
      $msgs->{$err} ||= 'Invalid';
      $err_h->{'err_'.$err} =
	$CFG{ERROR_MARK}.'<B><font size="-1">'.$msgs->{$err}.'</font></B>';
   }
   return $err_h;
}

# a general purpose image validation routine
# input
#    1. form field name
#    2. hashref of maxes (width, height, bytes)	     
# output: 
#   1. attribute hash (width, height, mime_type, extension)
#   2. error msg (if any)
sub validate_image {
   require Image::Size;
   import Image::Size qw/imgsize/;
   require HTTP::Headers::UserAgent;
   import HTTP::Headers::UserAgent;
   require File::Basename;
   import File::Basename;  

   my %os_convert = (
      Win95           => 'MSWin32',
      Win98           => 'MSWin32',
      WinNT           => 'MSWin32',
      Mac             => 'MacOS',
      Linux           => '', # the default for File::Basename
      UNIX            => ''
   );

   my %valid_mime_types = (
      'image/jpeg'    => 1,
      'image/gif'     => 1,
      'image/png'     => 1,
     );

   my $field = shift;
   my $maxs = shift;
   my $img = $q->upload($field);
   carp $q->cgi_error if (!$img && $q->cgi_error);

   my $tmp_file = $q->tmpFileName($q->param($field));
   my $file_size = (stat ($img))[7];
   my $mime_type = $q->uploadInfo($img)->{'Content-Type'} if $img;

   if($file_size > $maxs->{bytes}) {
      return (undef,"File size exceeds maximum allowed");
   }
   
   if (! $valid_mime_types{$mime_type} ) {
      return (undef, "Does not appear to be an allowed image format. (GIF, JPG, or PNG)");
   } 

   my ($width,$height) = imgsize($tmp_file);
   my $err;
   if (($width > $maxs->{width}) or
	($height > $maxs->{height})) {
     $err = "Image dimensions ($width x $height) exceeds maximum allowed
           ($maxs->{width} x $maxs->{height})";
   }

   my $Platform = HTTP::Headers::UserAgent::GetPlatform ($ENV{HTTP_USER_AGENT});
   fileparse_set_fstype($os_convert{$Platform});
   my $orig_file_name = basename($img);
   (my $ext) = $orig_file_name =~ m/(\.\w*)?$/;

   my %attr = (
     width  => $width,
     height => $height,
     extension => $ext, 
     mime_type => $mime_type,
    );
   return (\%attr,$err);
}


# XXX maybe I should rename this item_comments_view to be more consistent. -mls
sub item_view_comments {
   my $self = shift;
   length $FORM{item_id} or return err(title=>"No item_id",
				       msg=>'Insufficient information was found to build this page');

   my $item = Cascade::Item->new(id=>$FORM{item_id}) 
	or return err(title=>"No item",msg=>'Failed to create an Item');;
   my $t = $self->load_tmpl('item-view-comments.tmpl');
   $t->param($item->comments_html);
   return $t->output;
}

sub item_include_comments {
   my $self = shift; 
   my ($item_id, $where); 
   
   my @bind;
   # first we try an explicit item_id
   if ($FORM{item_id}) {
      $where = ' item_id = ? ';
	  push @bind, $FORM{item_id};
   }
   # next we try matching the documents URI
   else {
      $where = 'url = ?';
	  push @bind, $ENV{DOCUMENT_URI};
   }

   $item_id = $DBH->selectrow_array(
	   "SELECT item_id FROM cas_item_approved WHERE $where",
   		{},
		@bind);
   if ($item_id > 0) {
      my $item = Cascade::Item->new(id=>$item_id);
      my $t = $self->load_tmpl('includes/item-include-comments.tmpl');
      $t->param($item->comments_html);
      return $t->output;
   }

}


sub item_comment_post {
   my $self = shift;
   # validate the form;
   length $FORM{item_id} or return err(title=>'Technical Failure',
				       msg=>'No item_id was found. This is probably not your fault');

   length $SES{user_id} or return err(title=>'Not logged in',
				      msg=>'You need to logged in for this function to work. 
         Try going back and reloading the page');

   require Data::FormValidator;
   my $validator = Data::FormValidator->new({
      form => {
	   optional => [qw/rating comment/],
	   filters => 'trim',
	}
     });
   my ($valid) = $validator->validate(\%FORM,'form');

   # throw an error if they don't give a rating or a comment
   ($valid->{rating} or $valid->{comment}) or
     return err(title=>'Insufficient Information',
		msg=>'You must supply a rating and/or a comment.');

   $valid->{item_id} = $FORM{item_id};
   $valid->{user_id} = $SES{user_id};

   require DBIx::Abstract;
   my $db = DBIx::Abstract->connect($DBH);
   # If they've already posted
   if ($DBH->selectrow_array("
          SELECT 1 FROM cas_user_item_map
              WHERE user_id = ? AND item_id = ?"
			  ,{},$SES{user_id},$FORM{item_id})) {

      $db->update('cas_user_item_map',$valid,
	  	{ user_id => $SES{user_id}, item_id => $FORM{item_id} })
   } else {
      $db->insert('cas_user_item_map',$valid);
   }
  
   DBI->trace(1);
   # write affected static pages if we need to. 
   unless ($CFG{DYNAMIC_ONLY_P}) {
	   # write static pages for all affected categories
	   my $cat_ids = $DBH->selectcol_arrayref("
	   SELECT category_id 
	   FROM cas_category cat
	   LEFT JOIN cas_category_item_map map USING (category_id)
	   WHERE map.item_id = ?",
	   {},$FORM{item_id});

	   foreach my $id (@$cat_ids) {
		   my $cat = new Cascade::Category(id=>$id,mode=>'static');
		   my $rv = $self->write_static_cat($cat,verbose=>0);
	   }
   }
   DBI->trace(0);

   # Send comments to those who care 
   # XXX For now, just admins. Later, maybe editors, too 
   my $cat = new Cascade::Category(id=>0);
      if (my $to_emails = $cat->get_admin_and_cat_emails) {
	 my $t = $self->load_tmpl('emails/item-alert-comment.txt');
	 $t->param(
	    to_emails   => $to_emails,
	    from_email 	=>$SES{email},
	    title 	=> $FORM{title},
	    rating	=> $FORM{rating},
	    comment     => $FORM{comment},
	    comment_url => "$CFG{CASCADE_CGI}/item_view_comments?item_id=$FORM{item_id}",
	    delete_url  =>
	      "$CFG{CASCADE_CGI}/item_comments_delete?item_id=$FORM{item_id}&comment_delete=$SES{user_id}",
	      
	   );
	 open(MAIL, "|$CFG{MAILPROG} -t") or return 
	   err(title=>'Error Opening Mail Program', msg=>'There was an error opening the mail program');
	 eval {print MAIL $t->output };
	 $@ and carp $@; 
	 close(MAIL);
       }

   return $self->item_view_comments;

}

sub item_comments_delete {
   my $self = shift;
   length $FORM{item_id} or error(title=>"Insufficient Information",
				  msg=>"No item_id was found");

   # delete the marked comments
   foreach my $c ($self->query->param('comment_delete')) {
      $DBH->do("DELETE FROM cas_user_item_map
         WHERE item_id = ?
           AND user_id = ? ",{},$FORM{item_id},$c);
   }

   # return to the page
   return $self->item_view_comments;
}

sub password_forgot_form {
   my $self = shift;
   my $t = $self->load_tmpl('register-forgot-password.tmpl');
   return $t->output;
}

sub password_mail_success {
   my $self = shift;
   my $t = $self->load_tmpl('register-password-emailed.tmpl');
   return $t->output;
}

sub password_mail_forgotten {
   my $self = shift;

   unless ($FORM{user_id} or $FORM{email}) {
	return err(title=>'Insufficient Information',
		msg=>'There was an error processing your request-- Insufficient Information was received');
     }

   my (@bind);
   my $sql = "SELECT password,email FROM cas_users WHERE ";
   if ($FORM{user_id}) {
		$sql .= " user_id = ? ";
		push @bind, $FORM{user_id};
   } else {
	   $sql .= " lower(email) = ? ";
	   push @bind, lc $FORM{email};
   }
   my ($password,$email) = $DBH->selectrow_array($sql,{},@bind);

   unless ($password and $email) {
      	return err(title=>'Information not found',
		msg=>qq!We could not find sufficient information on your account.
			<P>
			Return to our <A HREF="$CFG{CASCADE_CGI}/login">login page</A> to try logging in again! );
   }

   open(MAIL,"|$CFG{MAILPROG} -t ") || return err(title=>'Error sending email',msg=>"There was an error sending the message,
			please contact $CFG{CONTACT_EMAIL} for assistance.");
   my $msg = $self->load_tmpl('emails/password-forgot.txt');
   $msg->param( email=>$email, password=>$password );
   print MAIL $msg->output;
   close(MAIL);

   return $self->password_mail_success;
}

# make text a little more readable as HTML
sub htmlicize {
   my $txt = shift;
   # convert 2 or more blank lines to a paragraph break
   $txt =~ s/(\s*\n){2}/<P>/gsi;

   # convert remaining newlines to html line breaks
   $txt =~ s/\n/<BR>\n/gsi;

   return $txt;
}

# We use this sometimes to avoid the overhead of DBIx::Abstract
# and take advantage of prepare_cached for mass inserting
# (which only happened for a bookmark import script when I added this. -mls )
# credit: This is basically straight from the DBI documentation. 
sub insert_hash {
    my ($table, $field_values) = @_;
    my @fields = sort keys %$field_values; # sort required
    my @values = @{$field_values}{@fields};
    my $sql = sprintf "insert into %s (%s) values (%s)",
        $table, join(",", @fields), join(",", ("?")x@fields);
    my $sth = $DBH->prepare_cached($sql);
    return $sth->execute(@values);
}

1;


