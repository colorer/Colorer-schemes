000010 identification division.
000020 program-id. Stock-file-set-up.
000030 author. micro focus ltd.
000040 environment division.
000050 configuration section.
000060 source-computer. Mds-800.
000070 object-computer. mds-800.
000075 special-names. console is crt.
000080 input-output section.
000090 file-control.
000100  select stock-file assign "stock.it"
000110  organization indexed
000120  access dynamic
000130  record key stock-code.
000140  data division.
000150  file section.
000160  fd      stock-file; record 32.
000170  01      stock-item.
000180  02      stock-code       pic x(4).
000190  02      product-desc   pic x(24).
000200  02      unit-size        pic 9(4).
000210  working-storage section.
000220  01      screen-headings.
000230  02      ask-code     pic x(21) value "stock code    <   >".
000240  02      filler pic x(59).
000250  02      ask-desc     pic x(16) value "description   <".
000260  02      si-desc          pic x(25) value "       >".
000270  02      filler           pic x(39).
000280  02      ask-size      pic x(21) value "unit size  <    >".
000290  01 enter-it redefines screen-headings.
000300  02      filler          pic x(16).
000310  02      crt-stock-code  pic x(4).
000320  02      filler          pic x(76).
000330  02      crt-prod-desc   pic x(24).
000340  02      filler          pic x(56).
000350  02      crt-unit-size   pic 9(4).
000360  02      filler          pic x.
000370  procedure division.
000380  sr1.
000390  display space.
000400  open i-o stock-file.
000410  display screen-headings.
000420  normal-input.
000430  move space to enter-it.
000440  display enter-it.
000450 correct-error.
000460  accept enter-it.
000470  if crt-stock-code = space go to end-it.
000480  if crt-unit-size not numeric go to correct-error.
000490  move crt-prod-desc to product-desc.
000500  move crt-unit-size to unit-size.
000510  move crt-stock-code to stock-code.
000520  write stock-item; invalid go to correct-error.
000530  go to normal-input. 00054 end-it
000550  close stock-file.
000560  display space.
000570  display "end of program".
000580  stop run.