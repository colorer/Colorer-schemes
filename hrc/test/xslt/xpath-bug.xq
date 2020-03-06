xquery version "1.0" encoding "windows-1251";

declare namespace def = "colorer://hrc/lib/default.hrc";

declare variable 
	(: типы от потолка (: из hrc :) берем :)
	$def:test1 as def:empty := aaa/bbb/ccc; 
declare variable $def:test2 := aaa/bbb/ccc + ccc; (: отвалилось... :)
declare variable $def:test3:=aaa/bbb;
declare variable $test4:=aaa/bbb; (: глюка :)

declare function def:foo ($bar as xs:string) as def:Text
{
	let $xx:= aaa/bbb, (: глюка :)
	let $aa as empty()? := aaa/bbb,
		$bb := aaa/bbb,
		$cc:= aaa/bbb (: совсем плохо... :)
	
	<aaa>
	{
		for $aa in $n return xxx (: и так далее... 
все возможности будем проверять как-нибудь в другой раз... :) 
	}
	</aaa>
};

<foo>
{
	def:foo("&lt;фигня&gt;")/bar
}
</foo>
