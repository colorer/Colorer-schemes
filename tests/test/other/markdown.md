Inline HTML should not bleed:
<sub>lower with<br>*breaks*</sub> and <custom-tag attr="v">inline with<br> breaks</custom-tag>
_and break highlighting_.

Inline <div style=">" />

<!--some comment-->

Inline <!--some XML comment--> followed by a self-closing tag <hr    />

HTML block type 1 (pre/script/style/textarea):
<pre>
    *This*
        **is**
            `not`
                _markdown_
<!DOCTYPE html>

*Still* __not__
<html lang="en">
<body>
    <p>This is <br> HTML</p>
</body>
</html>
</pre>

HTML block type 2 (comment):
<!--
*not markdown*
-->

HTML block type 3 (processing instruction):
<?pi
*not markdown*
?>

<?xml version="1.0"?>
<?xml-stylesheet href="style.css" type="text/css"?>

HTML block type 4 (declaration):
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
  "http://www.w3.org/TR/html4/frameset.dtd">

HTML block type 5 (CDATA):
<![CDATA[
*not markdown*

*Still* __not__
<data attr='v'></data>
]]>

HTML block type 6 (block tags, blank line ends):
<div id=1>
*not markdown*

_Hello_ **markdown*
</div>

Additional block tag samples (type 6):
<table style="CSS" >
<tr>
*no*

_yes_
<td attr="v">`not markdown`</td></tr>
</table>

<section>
*not markdown*
</section>
<SEARCH>
*not markdown*

`markdown`
</SEARCH>

HTML block type 7 (complete tag line, blank line ends):
<custom-tag>
*not markdown*
</custom-tag>

Additional complete-tag samples (type 7):
<ns:x-tag data-x="1">
*not markdown*

<down>*lies* _mark_</down>
</ns:x-tag>
`not markdown`
 
In list:

- before
  <pre>
  `not highlighted` _neither_  *nor this*
  </pre>
- after
  and here `code span` _emphasis_  **strong**
