TEMPLATE += app
TARGET = qmlsokoban

QT += gui declarative
CONFIG += mobility
MOBILITY += sensors

# Source files
#SOURCES += main.cpp mainwidget.cpp orientation.cpp
#HEADERS += mainwidget.h orientation.h
SOURCES += main.cpp mainwidget.cpp
HEADERS += mainwidget.h
RESOURCES += qmlsokoban.qrc

OTHER_FILES += ../qml/main.qml \
	../qml/ToolBar.qml \
	../qml/gameview/BoardItem.qml \
	../qml/gameview/GameView.qml \
	../qml/gameview/ItemBorder0.qml \
	../qml/gameview/ItemBorder1.qml \
	../qml/gameview/ItemBorder2.qml \
	../qml/gameview/ItemBorder3.qml \
	../qml/gameview/ItemFloor.qml \
	../qml/gameview/ItemGoal.qml \
	../qml/gameview/ItemMan.qml \
	../qml/gameview/ItemObject.qml \
	../qml/gameview/game.js \
	../qml/menu/AboutArea.qml \
	../qml/menu/Button.qml \
	../qml/menu/MenuPanel.qml \
	../qml/menu/MenuTitle.qml

# Install
symbian {
	# To lock the application orientation
	LIBS += -lcone -leikcore -lavkon

	# Translations
	include(translations.pri)

	#TARGET.UID3 =
	#TARGET.CAPABILITY +=
	#TARGET.EPOCSTACKSIZE = 0x14000
	#TARGET.EPOCHEAPSIZE = 0x020000 0x800000
}

unix:!symbian {
	PREFIX = /usr
	target.path = $${PREFIX}/bin
	INSTALLS += target

	# Translations (must be here because $${PREFIX} is used)
	include(translations.pri)

	# Desktop file
	desktop.path = $${PREFIX}/share/applications
	desktop.files = qmlsokoban.desktop
	INSTALLS += desktop
}
