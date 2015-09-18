# Included by src.pro

TRANSLATIONS = ../qml/i18n/qml_fr.ts

QMFILES = $$replace(TRANSLATIONS, "\\.ts", ".qm")
QMFILES = $$replace(QMFILES, ".*\\/", "$${OUT_PWD}/")

# Create qm files
updateqm.name = lrelease ${QMAKE_FILE_IN}
updateqm.input = TRANSLATIONS
updateqm.output = ${QMAKE_FILE_BASE}.qm
updateqm.commands = lrelease -silent ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
updateqm.CONFIG = no_link target_predeps
QMAKE_EXTRA_COMPILERS += updateqm

# Install
symbian {
	# Include translation files in package
	translations.sources = $${QMFILES}
	translations.path = .
	DEPLOYMENT += translations
}

unix:!symbian {
	TRANSLATIONS_INSTALL_DIR = $${PREFIX}/qmlsokoban
	DEFINES += QMLSOKOBAN_TRANSLATIONS_INSTALL_DIR=\\\"$${TRANSLATIONS_INSTALL_DIR}\\\"
	translations.path = $${TRANSLATIONS_INSTALL_DIR}
	translations.files = $${QMFILES}
	translations.CONFIG += no_check_exist
	INSTALLS += translations
}
