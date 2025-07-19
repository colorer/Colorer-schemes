
<?
echo <<< END
test
END
.'test';
?>

<?
/* также неверно обрабатывались строки в двойных кавычках */
$var1 = '1';
echo "${var1}test{$var1}test${'va'."r1"}<br>\n";
$a['test'] = 'hello';
echo "test$a[test]test<br>\n";
class a { }
$a = new a;
$a->ddd = 'c';
echo "var is [$a->ddd]test<br>\n";

?>
/*
    Добавлена подсветка ПХП вида:
    <script language="php">
    php script class{}
    </script>
*/

/*
    не подсвечивались новые keyword'ы, появившиеся в PHP5.
<?
    try, catch, trhow, public, private и т.п.
?>
*/
