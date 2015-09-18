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
#include <QDir>
#include <QLocale>
#include <QTranslator>
#ifdef Q_OS_SYMBIAN
// Lock orientation in Symbian
#include <eikenv.h>
#include <eikappui.h>
#include <aknenv.h>
#include <aknappui.h>
#endif

#include "mainwidget.h"

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

#ifdef Q_OS_SYMBIAN
	// Lock orientation in Symbian
	CAknAppUi* appUi = dynamic_cast<CAknAppUi*> (CEikonEnv::Static()->AppUi());
	TRAP_IGNORE( if(appUi) { appUi->SetOrientationL(CAknAppUi::EAppUiOrientationPortrait); } );
#endif

	QTranslator translator;
#ifdef QMLSOKOBAN_TRANSLATIONS_INSTALL_DIR
	const QDir translationsDir(QMLSOKOBAN_TRANSLATIONS_INSTALL_DIR);
	translator.load("qml_" + QLocale::system().name().left(2).toLower() + ".qm", translationsDir.absolutePath());
#else
	translator.load("qml_" + QLocale::system().name().left(2).toLower() + ".qm");
#endif
	app.installTranslator(&translator);

	MainWidget mainWidget;
	mainWidget.show();

	return app.exec();
}
