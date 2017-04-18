Colorer schemes
========================
Библиотека схем - это базовый набор описаний синтаксисов и стилей раскраски, используемый библиотекой Colorer.
Проект содержит файлы и скрипты для создания бибилиотеки схем.

Состав
------------------------

  * hrc - базовый набор описаний синтаксисов (hrc-файлов) и их генераторов
  * hrd - базовый набор стилей раскраски (hrd-файлов), их генераторов и дополнений
  * shared - общие xml схемы файлов colorer
  * javalib - нужные проекту java библиотеки

Сборка библиотеки схем
------------------------

### Общее ###

Для сборки библиотеки схем необходимо

  * git
  * ant 1.8 или выше
  * java development kit 6 (jdk) или выше
  * perl

Скачиваем последние исходники с github

    git clone https://github.com/colorer/Colorer-schemes.git

или обновляем репозиторий

    git pull

Запускаем сборку

    build.cmd цель

где *цель* одно из значений

  * base        - простая сборка библиотеки схем. Папка build/base
  * base.pack   - сборка библиотеки схем с упакованными hrc-файлами в архив. Папка build/basep
  * base.far    - сборка библиотеки схем для распространения с дистрибутивом FarColorer. Папка build/basefar
  * base.update - архив с base.pack. Папка build

### Особенности сборки под Windows ###

Перед запуском скриптов сборки необходимо убедиться, что в переменной окружения *PATH* есть пути до jdk и ant.
Так же должна быть задана переменная окружения *JAVA_HOME*. Например:

    set PATH=v:\apps\jdk\bin;v:\apps\ant\bin;%PATH%
    set JAVA_HOME=v:\apps\jdk

### Особенности сборки под Linux ###

На примере Debian Wheezy.

Устанавливаем ant и jdk

    apt-get install ant openjdk-6-jdk

Если в конфигах apt указано `APT::Install-Recommends "False";`, то необходимо так же установить `ant-optional`.

В файле */usr/share/ant/bin/ant* комментируем строки

    # Add the Xerces 2 XML parser in the Debian version
    if [ -z "$LOCALCLASSPATH" ] ; then
      LOCALCLASSPATH="/usr/share/java/xmlParserAPIs.jar:/usr/share/java/xercesImpl.jar"
    else
      LOCALCLASSPATH="/usr/share/java/xmlParserAPIs.jar:/usr/share/java/xercesImpl.jar:$LOCALCLASSPATH"
    fi

Данное действие исправляет ошибку `Warning: XML resolver not found; external catalogs will be ignored` при сборке схем.
Более подробное описание ошибки [в багтрекере Debian](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=552032)

## Разработка ##

Описания синтаксисов (схемы) делятся на статичные и генерируемые. Статичные находятся в директории hrc/hrc, генерируемые в hrc/src.

После изменения схемы, нужно произвести тестирование изменений на регресии. Для этого нужно:

  1. собрать библиотеку схем `build base`
  2. убедиться, что в директории bin в корне проекта лежит colorer.exe (утилита для работы с библиотекой схем)
  3. в директории hrc/test запустить скрипт `perl runtest.pl --full`. либо аналог `runtest.py` 
  4. в ходе работы скрипта будет проверен результат раскраски файла с эталоном, результат выведен в консоль и в файл fails.html в директории hrc/test/*время_теста*.
  5. после анализа расхождений в случае ошибок нужно исправить схему. Если же текущая раскраска считается верной, то нужно заменить файл эталона на новый.
     Файлы эталоны находятся в hrc/test/_valid. Новые файлы в hrc/test/*время_теста*

Так же перед внесением изменений в репозиторий, рекомендуется отредактировать файл hrc/hrc/CHANGELOG
                                               
Ссылки
------------------------

* Сайт проекта: [http://colorer.sourceforge.net/](http://colorer.sourceforge.net/)
