/**

	Tool bar.

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

import QtQuick 1.0
import "menu" // for Button

Rectangle {
	id: toolBar
	height: menuButton.height + 2 * buttonRow.anchors.leftMargin
	color: "black"

	signal goToPreviousLevel()
	signal goToNextLevel()
	signal zoomIn()
	signal zoomOut()
	signal undo()

	Flickable { // put the buttons in a Flickable so that they can be made visible when the screen is too narrow
		anchors.left: parent.left
		width: parent.width - levelText.width - 2 * levelText.anchors.rightMargin // do not cover levelText
		height: parent.height
		contentWidth: buttonRow.width + 2 * buttonRow.anchors.leftMargin
		flickableDirection: Flickable.HorizontalFlick
		boundsBehavior: Flickable.StopAtBounds
		clip: true

		Row {
			id: buttonRow
			spacing: 3
			anchors {
				left: parent.left
				leftMargin: 3
				verticalCenter: parent.verticalCenter
			}

			Button {
				id: menuButton
				text: qsTr("Menu")
				onClicked: menuPanel.state = menuPanel.state == "hidden" ? "playing" : "hidden"
			}

			Button {
				id: previousLevelButton
				text: qsTr("Previous Level")
				onClicked: goToPreviousLevel()
			}

			Button {
				id: nextLevelButton
				text: qsTr("Next Level")
				onClicked: goToNextLevel()
			}

			Button {
				id: zoomInButton
				text: "+"
				onClicked: zoomIn()
			}

			Button {
				id: zoomOutButton
				text: "<span>&#8211;</span>"
				onClicked: zoomOut()
			}

			Button {
				id: undoButton
				text: qsTr("Undo")
				onClicked: undo()
			}
		}
	}

	Text {
		id: levelText
		anchors {
			right: parent.right
			rightMargin: 3
			verticalCenter: parent.verticalCenter
		}
		text: qsTr("Level: %1").arg(gameView.currentLevel)
		color: "white"
	}

	states: [
		State {
			name: "hidden"
			PropertyChanges {
				target: toolBar
				y: parent.height
				opacity: 0
			}
		},
		State {
			name: "disabled"
			PropertyChanges { target: zoomInButton; state: "disabled" }
			PropertyChanges { target: zoomOutButton; state: "disabled" }
			PropertyChanges { target: undoButton; state: "disabled" }
		}
	]

	transitions: Transition {
		NumberAnimation {
			properties: "opacity, y"
			duration: 400
		}
	}
}
