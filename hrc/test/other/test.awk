"sdf"saf"
BEGIN {  i=1; }
{
  if(i == 1)  {
    ss=substr($7,1,3)
    # исключючить localhost
    # и мои заходы из 147.45.142.194
    if(ss != "127" && ss != "10." && $7 != "147.45.142.194------")
      ip[$7]++;
  }
  else if(i == 3) {
    i=0
  }
  ++i
}
END{
  i=0
  for(a in ip)
  {
    # для удобства сортировки разобъем IP на 4 части
    split(substr(a,1,index(a,'-')-1),ia,".")
    printf "%3s.%3s.%3s.%3s %4d\n", ia[1],ia[2],ia[3],ia[4], ip[a]
    ++i
  }
  print "\n\nUnique: ",i
}
