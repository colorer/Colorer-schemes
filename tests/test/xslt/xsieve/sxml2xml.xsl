<x:stylesheet
  xmlns:x = "http://www.w3.org/1999/XSL/Transform"
  xmlns:s = "http://xsieve.sourceforge.net"
  extension-element-prefixes="s"
  version = "1.0">
<!-- -->
<x:param name="input"/>

<s:init>
(define read-rest
  (lambda ()
    (let ((obj (read)))
      (if (eof-object? obj)
        '()
        (cons obj (read-rest))))))
</s:init>

<x:template match="/">
  <s:scheme>
    (with-input-from-file (x:eval "$input") read-rest)
  </s:scheme>
</x:template>

</x:stylesheet>
