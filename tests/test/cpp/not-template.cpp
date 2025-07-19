  for(Num = 1;Num < (GDTSIZE>>3);Num++){
    if(!p[Num*2] && !p[Num*2+1]){
      sysSetDesc(Num,Lo,Hi);
      return Num;
    };
  };
  return false;
