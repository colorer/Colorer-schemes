TEMPLATE = app
CONFIG  += qt warn_on

#in
DEPENDPATH  += ../dll
INCLUDEPATH += ../dll
LIBS        += -L../../lib -ldlabel
HEADERS     = dlcat.h 
SOURCES     = dlcat.cpp dmain.cpp 
RESOURCES   = longcat.qrc

#out
DESTDIR = ../../bin
TARGET  = longcat
