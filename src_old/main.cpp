/***************************************************************************
 *   Copyright (C) 2011 by Glad Deschrijver                                *
 *     <glad.deschrijver@gmail.com>                                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.  *
 ***************************************************************************/

#include <QApplication>
#include <QDeclarativeView>

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	QDeclarativeView view;
#if defined(Q_OS_SYMBIAN)
	view.setWindowState(Qt::WindowFullScreen);
#endif
	view.setResizeMode(QDeclarativeView::SizeRootObjectToView);

	QObject::connect((QObject*)view.engine(), SIGNAL(quit()), &app, SLOT(quit())); // grab Qt.quit() in the QML files

	view.setSource(QUrl("qrc:/qmlsokoban.qml"));
	view.show();

	return app.exec();
}
