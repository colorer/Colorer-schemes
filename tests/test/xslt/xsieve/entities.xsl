<x:stylesheet
  xmlns:x = "http://www.w3.org/1999/XSL/Transform"
  xmlns:s = "http://xsieve.sourceforge.net"
  xmlns:entity = "http://xsieve.sourceforge.net/entity"
  extension-element-prefixes="s"
  version = "1.0">
<!-- -->

<x:template match="@*|node()">
  <x:copy>
    <x:apply-templates select="@*|node()"/>
  </x:copy>
</x:template>

<x:template match="entity:*">
  <a>
  <s:scheme>
    (list '&amp; (x:eval "local-name()"))
  </s:scheme>
  </a>
  <b>
  <s:scheme>
  <![CDATA[
    (list '& (x:eval "local-name()"))
  ]]>
  </s:scheme>  
  </b>  
</x:template>

</x:stylesheet>
