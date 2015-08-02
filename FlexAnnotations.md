## Flex Annotations ##

If you plan to use Annotations you should modify you flex-config.xml
```
<?xml version="1.0"?>
<flex-config>
    <compiler>
      <keep-as3-metadata>
	  <name>Inject</name>
	  <source-path>
	       <path-element>.</path-element>
	   </source-path>
           <include-libraries>
              <library>/../libs/parade.swc</library>
           </include-libraries>
    </compiler>
</flex-config>
```
Note. To use flex-config.xml set **Additional Compiler Arguments** to  `-load-config+=flex-config.xml` of **Flex Compiler** in Project Properties.