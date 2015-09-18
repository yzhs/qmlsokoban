/**

	Menu panel.

	Copyright (C) 2010, 2011 Glad Deschrijver <glad.deschrijver@gmail.com>

	This file is part of qmlsokoban.

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, see <http://www.gnu.org/licenses/>.

*/

import QtQuick 2.0

Rectangle {
	id: menuPanel
	width: menuArea.width // the width of menuPanel depends on the width of its components and changes automatically when one of the components becomes hidden
	height: parent.height - 2 * margin
	x: margin
	y: margin

	property int margin: 20
	property int maxWidth: parent.width - 2 * margin // this is the width of menuPanel when everything is visible

	signal startNewGame
	signal setLevelCollection(string name)

	border { color: "#666666"; width: 2 }
	radius: 5
	smooth: true
	gradient: Gradient {
		GradientStop { position: 0; color: "#333333" }
		GradientStop { position: 1; color: "#111111" }
	}

	// Title

	MenuTitle {
		id: menuTitle
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
			margins: 10
		}
		state: levelCollectionArea.state == "hidden" && aboutArea.state == "hidden" ? "collapsed" : ""
	}

	// Main part of the menu

	Item {
		id: menuArea
		anchors {
			top: menuTitle.bottom
			left: parent.left
			bottom: parent.bottom
			margins: 10
		}
		width: menuButtonArea.width + levelCollectionArea.width + levelCollectionArea.anchors.leftMargin + aboutArea.width + aboutArea.anchors.leftMargin + 2 * anchors.leftMargin

		// Menu

		Flickable { // put the buttons in a Flickable so that they can be made visible when the screen is not high enough
			id: menuButtonArea
			anchors {
				top: parent.top
				left: parent.left
				bottom: parent.bottom
			}
			width: 0.4 * menuPanel.maxWidth - 2 * parent.anchors.leftMargin
			flickableDirection: Flickable.VerticalFlick
			boundsBehavior: Flickable.StopAtBounds
			contentHeight: Math.max(height, menuButtonColumn.height + aboutButton.height + menuButtonColumn.spacing)
			clip: true

			Column {
				id: menuButtonColumn
				spacing: 10
				anchors {
					top: parent.top
					left: parent.left
				}

				Button {
					id: newGameButton
					textWidth: menuButtonArea.width - 2 * paddingX // dirty hack to let the eliding and multi-length string selection work
					paddingY: 5
					text: qsTr("Start New Game") + "\x9C" + qsTr("New Game") + "\u009C" + qsTr("New") // multi-length string; the first one that fits is selected, otherwise the last one is elided
					onClicked: {
						menuPanel.startNewGame();
						menuPanel.state = "hidden";
					}
				}

				Button {
					id: continueGameButton
					textWidth: menuButtonArea.width - 2 * paddingX // dirty hack to let the eliding and multi-length string selection work
					paddingY: 5
					opacity: 0
					text: qsTr("Continue Game") + "\u009C" + qsTr("Continue") // multi-length string; the first one that fits is selected, otherwise the last one is elided
					onClicked: menuPanel.state = "hidden";
				}

				Button {
					id: chooseLevelCollectionButton
					textWidth: menuButtonArea.width - 2 * paddingX // dirty hack to let the eliding and multi-length string selection work
					paddingY: 5
					text: qsTr("Choose level collection") + "\u009C" + qsTr("Level collection") + "\u009C" + qsTr("Levels") // multi-length string; the first one that fits is selected, otherwise the last one is elided
					onClicked: {
						if (levelCollectionArea.state == "hidden") {
							aboutArea.state = "hidden";
							levelCollectionArea.state = "";
						} else {
							levelCollectionArea.state = "hidden";
						}
					}
				}

				Button {
					id: quitButton
					width: menuButtonArea.width
					paddingY: 5
					text: qsTr("Quit")
					onClicked: Qt.quit();
				}
			}

			Button {
				id: aboutButton
				anchors { left: parent.left; bottom: parent.bottom }
				width: parent.width
				paddingY: 5
				text: qsTr("About")
				onClicked: {
					if (aboutArea.state == "hidden") {
						levelCollectionArea.state = "hidden";
						aboutArea.state = "";
					} else {
						aboutArea.state = "hidden";
					}
				}
			}
		}

		// Level collection chooser

		LevelCollectionArea {
			id: levelCollectionArea
			anchors {
				top: parent.top
				left: menuButtonArea.right
				bottom: parent.bottom
				leftMargin: 10
			}
			contentWidth: 0.6 * menuPanel.maxWidth - 10 // use contentWidth so that making this panel smaller (using width) during hiding doesn't change the text width and screw up the text wrapping; use 10 instead of anchors.leftMargin because the latter changes when levelCollectionArea is hidden
			state: "hidden"
			onLevelCollectionChosen: {
				setLevelCollection(name);
				continueGameButton.opacity = 0;
				gameView.clearGame();
			}
		}

		// About box

		AboutArea {
			id: aboutArea
			anchors {
				top: parent.top
				left: menuButtonArea.right
				bottom: parent.bottom
				leftMargin: 10
			}
			contentWidth: 0.6 * menuPanel.maxWidth - 10 // use contentWidth so that making this panel smaller (using width) during hiding doesn't change the text width and screw up the text wrapping; use 10 instead of anchors.leftMargin because the latter changes when aboutArea is hidden
		}
	}

	states: [
		State {
			name: "hidden"
			PropertyChanges {
				target: menuPanel
				opacity: 0
				y: parent.height
			}
			onCompleted: {
				aboutArea.state = "hidden"; // aboutArea should be hidden when the menu is shown again
				levelCollectionArea.state = "hidden"; // idem
			}
		},
		State {
			name: "playing"
			StateChangeScript { // use StateChangeScript because making continueGameButton visible must happen only when starting the first game of a new collection
				script: continueGameButton.opacity = 1;
			}
		}
	]

	transitions: Transition {
		NumberAnimation {
			properties: "opacity, y"
			duration: 400
		}
	}
}
