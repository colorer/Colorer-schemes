# CMake.hrc
Colorer cmake.hrc scheme

Add following lines into proto.hrc and correct location link, don't forget to remove comments ;)

```
<prototype name="cmake" group="scripts" description="CMake script">
  <location link="types/cmake.hrc"/>
  <filename>/(\.cmake)$/i</filename>
  <filename weight="3">/(^CMakeLists\.txt)$/i</filename>
  <firstline weight="2">/^cmake_minimum_required/xi</firstline>
</prototype>
```
