# CMake.hrc
Colorer cmake.hrc scheme.

## Installation

### Using 'proto.hrc' file (fast way)

1. Download repository into somewhere
2. Add the following lines into proto.hrc and correct `location link`

```
<prototype name="cmake" group="scripts" description="CMake script">
  <location link="somewhere/cmake.hrc"/>
  <filename>/(\.cmake)$/i</filename>
  <filename weight="3">/(^CMakeLists\.txt)$/i</filename>
  <firstline weight="2">/^cmake_minimum_required/xi</firstline>
</prototype>
```


### Using 'auto' folder (simple way)

1. `cd <FarManager>\Plugins\FarColorer\base\hrc\auto`
2. `git clone https://github.com/Extrunder/CMake.hrc.git scripts\cmake`
   * `rmdir /S /Q scripts\cmake\.git` (it saves some space)
3. Create file `<FarManager>\Plugins\FarColorer\base\hrc\auto\proto.hrc` with following lines:

```
<?xml version="1.0" encoding='Windows-1251'?>
<!DOCTYPE hrc PUBLIC "-//Cail Lomecb//DTD Colorer HRC take5//EN"
  "http://colorer.sf.net/2003/hrc.dtd">

<hrc version="take5" xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://colorer.sf.net/2003/hrc http://colorer.sf.net/2003/hrc.xsd">

  <prototype name="cmake" group="scripts" description="CMake script">
    <location link="scripts/cmake/cmake.hrc"/>
	  <filename>/(\.cmake)$/i</filename>
	  <filename weight="3">/(^CMakeLists\.txt)$/i</filename>
	  <firstline weight="2">/^cmake_minimum_required/xi</firstline>
  </prototype>
</hrc>
```

### Using custom directory (compatible way)

1. `cd <SomeGoodDir>`
2. `git clone https://github.com/Extrunder/CMake.hrc.git cmake`
   * `rmdir /S /Q cmake\.git` (it saves some space)
3. Create file `<SomeGoodDir>\proto.hrc`
```
<?xml version="1.0" encoding='Windows-1251'?>
<!DOCTYPE hrc PUBLIC "-//Cail Lomecb//DTD Colorer HRC take5//EN"
  "http://colorer.sf.net/2003/hrc.dtd">

<hrc version="take5" xmlns="http://colorer.sf.net/2003/hrc"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://colorer.sf.net/2003/hrc http://colorer.sf.net/2003/hrc.xsd">

  <prototype name="cmake" group="scripts" description="CMake script">
    <location link="cmake/cmake.hrc"/>
	  <filename>/(\.cmake)$/i</filename>
	  <filename weight="3">/(^CMakeLists\.txt)$/i</filename>
	  <firstline weight="2">/^cmake_minimum_required/xi</firstline>
  </prototype>
</hrc>
```
4. _**F9** -> **O**ptions -> Pl**u**gins configuration -> Fa**r**Colorer -> Users **f**ile of schemes_
5. Type there `<SomeGoodDir>\proto.hrc`


### Using catalog.xml (correct way)

... TODO ...
