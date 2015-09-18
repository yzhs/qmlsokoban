/**

	Main application QML file.
	Run qmlviewer main.qml to run the game.

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
import "../qml"
import "../qml/menu"
import "../qml/gameview"

Item {
	id: window
	width: 480
	height: 320

	// Background

	Image {
		id: backgroundImage
		anchors.fill: parent
		source: "../qml/starfield.jpg"
		fillMode: Image.Tile
	}

	// Main container for game view and toolbar (and anything that must also rotate)

	Item {
		id: gameItem
		width: parent.width
		height: parent.height
		anchors.centerIn: parent
		//state: "orientation " + Orientation.state // defined in mainwidget.cpp
		state: "orientation Portrait"

		GameView {
			id: gameView
			width: parent.width
			height: parent.height - toolBar.height // no anchors (see toolBar below)
			anchors.top: parent.top
		}

		ToolBar {
			id: toolBar
			width: parent.width
			y: parent.height - toolBar.height // no anchors because we must be able to let the toolbar slide in from below when unhiding; this is the default y-coordinate when not in the state "hidden"
			state: "hidden"
			z: 1

			// pass signals from the buttons on toolBar to gameView
			onGoToPreviousLevel: gameView.goToPreviousLevel()
			onGoToNextLevel: gameView.goToNextLevel()
			onZoomIn: gameView.zoomIn()
			onZoomOut: gameView.zoomOut()
			onUndo: gameView.undo()
		}

		MenuPanel {
			id: menuPanel
			height: toolBar.y - 2 * margin // no parent.height - 2 * margin because menuPanel fills up the whole screen when toolBar is invisible (and toolBar.y == parent.height) and fills up the area above toolBar when toolBar is visible

			onStartNewGame: {
				toolBar.state = "" // state != "hidden", so toolBar becomes visible
				gameView.startNewGame()
			}
		}

		states: [
			State {
				name: "orientation Portrait"
				PropertyChanges { target: gameItem; rotation: 0 }
			},
			State {
				name: "orientation Landscape"
				PropertyChanges { target: gameItem; rotation: 90; width: window.height; height: window.width }
			},
			State {
				name: "orientation PortraitInverted"
				PropertyChanges { target: gameItem; rotation: 180 }
			},
			State {
				name: "orientation LandscapeInverted"
				PropertyChanges { target: gameItem; rotation: 270; width: window.height; height: window.width }
			}
		]

		transitions: Transition {
			SequentialAnimation {
				ScriptAction { script: gameView.isAnimated = false }
				ParallelAnimation {
					RotationAnimation { direction: RotationAnimation.Shortest; duration: 300; easing.type: Easing.InOutQuint }
					NumberAnimation { properties: "x, y, width, height"; duration: 300; easing.type: Easing.InOutQuint }
				}
				ScriptAction { script: gameView.isAnimated = true }
			}
		}
	}
}
