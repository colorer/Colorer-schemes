while(<>)
{
	next if/^\s+xml(ns)?:\w+/;
	s/log4j:([\w\-]+)/$1/g;
	print
}
