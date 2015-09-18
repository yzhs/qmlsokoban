/**

	Game view.

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
import "game.js" as Game

Item {
	id: gameView

	opacity: 1

	property int currentLevel: -1
	property alias isAnimated: gameCanvas.isAnimated
	property variant levels

	function loadLevelCollection(name) {
		var levelCollection = Qt.createQmlObject('import QtQuick 1.0; import "../levels/' + name + '.js" as Levels; Item { property variant levels: Levels.levels }', gameView, "LevelCollection");
		levels = levelCollection.levels;
		levelCollection.destroy();
	}
	Component.onCompleted: loadLevelCollection("levels_original");
	function startNewGame() {
		Game.startNewGame();
	}
	function clearGame() {
		Game.deleteBlocks();
	}
	function goToPreviousLevel() {
		Game.goToPreviousLevel();
	}
	function goToNextLevel() {
		Game.goToNextLevel();
	}
	function zoomIn() {
		Game.zoomIn();
	}
	function zoomOut() {
		Game.zoomOut();
	}
	function undo() {
		Game.undo();
	}

	// Messages

	Text {
		id: messageText
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
		width: parent.width
		color: "white"
		style: Text.Outline
		styleColor: "black"
		textFormat: Text.StyledText // must be specified to have the outline correctly positioned
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		z: 2;
		font {
			//pointSize: 14
			pixelSize: 24 // device-dependent size
			bold: true
		}
	}

	// Game canvas

	Item {
		id: gameCanvas
		property bool isAnimated: false

		x: parent.x
		y: parent.y
		width: parent.width
		height: parent.height
		opacity: 0

		property int numOfColumns // determined in game.js for each level
		property int numOfRows // idem
		property real blockSize: Math.min(gameCanvas.width / numOfColumns, gameCanvas.height / numOfRows) + addBlockSize // Math.floor ensures that the blocks remain connected, but rotation is bumpy
		property real offsetX: (gameCanvas.width - numOfColumns * blockSize) / 2 + addOffsetX
		property real offsetY: (gameCanvas.height - numOfRows * blockSize) / 2 + addOffsetY
		property real addBlockSize: 0 // have this as a separate variable so that changing this variable in game.js doesn't destroy the bindings of blockSize
		property real addOffsetX: 0 // idem
		property real addOffsetY: 0 // idem

		MouseArea {
			id: gameCanvasMouseArea

			property int oldX
			property int oldY
			property bool wasDragging: false

			property int maxOffsetX: (gameCanvas.width + gameCanvas.numOfColumns * gameCanvas.blockSize) / 2 - gameCanvas.blockSize;
			property int maxOffsetY: (gameCanvas.height + gameCanvas.numOfRows * gameCanvas.blockSize) / 2 - gameCanvas.blockSize;

			enabled: false
			anchors.fill: parent

			onPressed: { // drag
				oldX = mouse.x;
				oldY = mouse.y;
			}
			onPositionChanged: { // drag
				gameCanvas.addOffsetX += mouse.x - oldX;
				gameCanvas.addOffsetY += mouse.y - oldY;
				oldX = mouse.x;
				oldY = mouse.y;
				// make sure that the board doesn't completely go out of the view
				if (gameCanvas.addOffsetX > maxOffsetX)
					gameCanvas.addOffsetX = maxOffsetX;
				else if (gameCanvas.addOffsetX < -maxOffsetX)
					gameCanvas.addOffsetX = -maxOffsetX;
				if (gameCanvas.addOffsetY > maxOffsetY)
					gameCanvas.addOffsetY = maxOffsetY;
				else if (gameCanvas.addOffsetY < -maxOffsetY)
					gameCanvas.addOffsetY = -maxOffsetY;
				wasDragging = true;
			}
			onReleased: { // click
				if (!wasDragging)
					Game.moveManWithMouse(mouse.x, mouse.y);
				wasDragging = false;
			}
		}

		MouseArea {
			id: gameCanvasLevelWonMouseArea
			enabled: false
			anchors.fill: parent
			onClicked: Game.goToNextLevel();
		}

		MouseArea {
			id: gameCanvasGameOverMouseArea
			enabled: false
			anchors.fill: parent
			onClicked: Game.startNewGame();
		}
	}

	// Input handlers

	Item {
		id: gameInputHandler
		anchors.fill: parent
		width: parent.width
		height: parent.height
		focus: false

		Keys.onLeftPressed: Game.moveLeft();
		Keys.onRightPressed: Game.moveRight();
		Keys.onDownPressed: Game.moveDown();
		Keys.onUpPressed: Game.moveUp();
		Keys.onCancelPressed: gameView.state = "gameover";
		Keys.onBackPressed: gameView.state = "gameover";
		Keys.onEscapePressed: gameView.state = "gameover";
		Keys.onHangupPressed: gameView.state = "gameover";
		Keys.onDeletePressed: gameView.state = "gameover";
		Keys.onPressed: {
			if (event.modifiers == Qt.ControlModifier && event.key == Qt.Key_Z)
				Game.undo();
		}
	}

	Item {
		id: levelWonInputHandler
		anchors.fill: parent
		width: parent.width
		height: parent.height
		focus: false

		Keys.onPressed: {
			if (event.key != Qt.Key_Control && event.key != Qt.Key_Meta
			    && event.key != Qt.Key_Alt && event.key != Qt.Key_Shift)
				Game.goToNextLevel();
		}
	}

	Item {
		id: gameOverInputHandler
		anchors.fill: parent
		width: parent.width
		height: parent.height
		focus: false

		Keys.onCancelPressed: Qt.quit();
		Keys.onBackPressed: Qt.quit();
		Keys.onEscapePressed: Qt.quit();
		Keys.onHangupPressed: Qt.quit();
		Keys.onDeletePressed: Qt.quit();
		Keys.onPressed: {
			if (event.key != Qt.Key_Control && event.key != Qt.Key_Meta
			    && event.key != Qt.Key_Alt && event.key != Qt.Key_Shift)
				gameView.state = "playing";
		}
	}

	states: [
		State {
			name: "playing"
			PropertyChanges { target: gameCanvas; opacity: 1.0 }
			PropertyChanges { target: messageText; text: "" }
			PropertyChanges { target: messageText; opacity: 0.0 }
			PropertyChanges { target: gameInputHandler; focus: true }
			PropertyChanges { target: gameCanvasMouseArea; enabled: true }
		},
		State {
			name: "levelwon"
			PropertyChanges { target: gameCanvas; opacity: 0.5 }
			PropertyChanges { target: messageText; text: qsTr("Level %1 won!<br>Press any key or click/touch the screen to continue").arg(gameView.currentLevel) }
			PropertyChanges { target: messageText; opacity: 1.0 }
			PropertyChanges { target: levelWonInputHandler; focus: true }
			PropertyChanges { target: gameCanvasLevelWonMouseArea; enabled: true }
			PropertyChanges { target: toolBar; state: "disabled" }
		},
		State {
			name: "gamewon"
			PropertyChanges { target: gameCanvas; opacity: 0.5 }
			PropertyChanges { target: messageText; text: qsTr("Game won!<br>Press any key or click/touch the screen to start again") }
			PropertyChanges { target: messageText; opacity: 1.0 }
			PropertyChanges { target: levelWonInputHandler; focus: true }
			PropertyChanges { target: gameCanvasLevelWonMouseArea; enabled: true }
			PropertyChanges { target: toolBar; state: "disabled" }
		},
		State {
			name: "gameover"
			PropertyChanges { target: gameCanvas; opacity: 0.5 }
			PropertyChanges { target: messageText; text: qsTr("Game over") }
			PropertyChanges { target: messageText; opacity: 1.0 }
			PropertyChanges { target: gameOverInputHandler; focus: true }
			PropertyChanges { target: gameCanvasGameOverMouseArea; enabled: true }
			PropertyChanges { target: toolBar; state: "disabled" }
		}
	]

	transitions: [
		Transition {
			from: "*"; to: "levelwon,gamewon"
			NumberAnimation { properties: "opacity"; duration: 350 }
		},
		Transition {
			from: "*"; to: "playing"
			NumberAnimation { properties: "opacity"; duration: 100 }
		}
	]
}
