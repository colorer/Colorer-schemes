#include "dlabel.h"
#include "dlcat.h"

DCatWidget::DCatWidget(QWidget *p) : QWidget(p)
{
	cat = new DLabel("<h2>lo","ng</h2>");
	add = new QPushButton("&Add");
	
	
	QVBoxLayout *l1 = new QVBoxLayout;
	l1->addSpacing(20);
	l1->addWidget(new QLabel("<h2>Long cat is</h2>"));
	l1->addStretch(1);
	l1->addWidget(cat);
	l1->addStretch(2);
	l1->addWidget(add);
	
	QLabel *img = new QLabel;
	img->setPixmap(QPixmap(":img/longcat.png"));
	
	QHBoxLayout *l0 = new QHBoxLayout;
	l0->addLayout(l1);
	l0->addWidget(img);
	setLayout(l0);
	
	connect(add, SIGNAL(clicked()), this, SLOT(isLong()));
}

void DCatWidget::isLong()
{
	cat->addText("o");
}
