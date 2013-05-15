#ifndef DCAT_H
#define DCAT_H
#include <QtGui>

class DLabel;

class DCatWidget : public QWidget
{
	Q_OBJECT
	
private:
	QPushButton *add;
	DLabel *cat;
	
public:
	DCatWidget(QWidget *p=0);
	
private slots:
	void isLong();
};

#endif
