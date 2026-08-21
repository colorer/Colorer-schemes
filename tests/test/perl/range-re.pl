# range/flip-flop: second regexp after .. must be recognised
/'/ .. /"/
print if /'/ .. /"/;
print if /foo/../bar/;
print if /start/ ... /end/;

# still a regexp after other operators
print if /a/ or /b/;

# still division, not a regexp
$a = $b / $c / $d;
