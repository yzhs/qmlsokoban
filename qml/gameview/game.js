/**

	Game implementation in Javascript.

	Copyright (C) 2010 Glad Deschrijver <glad.deschrijver@gmail.com>

	This file is part of qmlsokoban.

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, see <http://www.gnu.org/licenses/>.

*/

// gameCanvas.blockSize: size of a cell in the current level's field
// gameCanvas.offsetX: x-offset for adding the items to the field (to center the field)
// gameCanvas.offsetY: y-offset for adding the items to the field (to center the field)
// gameCanvas.numOfColumns: number of columns in the current level's field
// gameCanvas.numOfRows: number of rows in the current level's field
var boardItems; // list of floor, goal and border items on the field
var maxIndex = 0; // number of cells in the current level's field = gameCanvas.numOfColumns * gameCanvas.numOfRows
var board; // array containing the description of the current level's board
var numOfGoals = 0; // number of goal items (= number of objects)
var numOfTreasures = 0; // number of objects already on a goal item
var itemObjects; // list of object items on the field
var itemMan; // man item
var undoHistory; // list of moves of the man and whether the man pushed an object on each move
var undoHistoryStep; // number of the current step in the undo history

// Index function used instead of 2D array
function index(column, row) {
	return column + (row * gameCanvas.numOfColumns);
}

function startNewGame() {
	// go to playing state
	gameView.state = "playing"
	if (gameView.currentLevel < 0)
		gameView.currentLevel = 0;
	gameCanvas.isAnimated = false;

	// reset gameView.currentLevel after the player has won the game
	if (gameView.currentLevel >= gameView.levels.length)
		gameView.currentLevel = 0;
	undoHistory = new Array();
	undoHistoryStep = 0;
	deleteBlocks(); // delete blocks from previous game

	// reset variables
	gameCanvas.addBlockSize = 0;
	gameCanvas.addOffsetX = 0;
	gameCanvas.addOffsetY = 0;

	// calculate board size
	gameCanvas.numOfRows = gameView.levels[gameView.currentLevel].length;
	gameCanvas.numOfColumns = 0;
	for (var i = 0; i < gameCanvas.numOfRows; ++i) {
		gameCanvas.numOfColumns = Math.max(gameCanvas.numOfColumns, gameView.levels[gameView.currentLevel][i].length);
	}
	maxIndex = gameCanvas.numOfRows * gameCanvas.numOfColumns;

	initBoard(); // initialize board
	gameCanvas.isAnimated = true;
}

/*******************************************************************/
/* Initialization */

function deleteBlocks() {
	for (var i = 0; i < maxIndex; ++i) {
		if (boardItems[i] != null)
		{
			boardItems[i].opacity = 0;
			boardItems[i].destroy();
		}
	}
	for (var i = 0; i < numOfGoals; ++i) { // numOfGoals = number of objects
		if (itemObjects[i] != null)
		{
			itemObjects[i].opacity = 0;
			itemObjects[i].destroy();
		}
	}
	if (itemMan != null)
		itemMan.opacity = 0;
}

function createBoard() {
	board = new Array(gameCanvas.numOfRows);
	numOfGoals = 0;
	numOfTreasures = 0;

	for (var row = 0; row < gameCanvas.numOfRows; ++row) {
		board[row] = new Array(gameCanvas.numOfColumns);
		for (var column = 0; column < gameCanvas.numOfColumns; ++column) {
			// 0: outside, 1: inside, 2: border, 3: goal, 4: object, 5: man, 6: object on goal, 7: man on goal
			var boardElement = (column < gameView.levels[gameView.currentLevel][row].length) ? gameView.levels[gameView.currentLevel][row].charAt(column) : ' ';
			switch (boardElement) {
				case ' ': board[row][column] = 1; break;
				case '#': board[row][column] = 2; break;
				case '.': board[row][column] = 3; ++numOfGoals; break;
				case '$': board[row][column] = 4; break;
				case '@': board[row][column] = 5; break;
				case '*': board[row][column] = 6; ++numOfGoals; ++numOfTreasures; break;
				case '+': board[row][column] = 7; ++numOfGoals; break;
				default: board[row][column] = 0;
			}
		}
	}
	// create outside area
	// FIXME: find a better algorithm for this
	for (var row = 0; row < gameCanvas.numOfRows; ++row) {
		for (var column = 0; column < gameCanvas.numOfColumns && board[row][column] == 1; ++column) {
			board[row][column] = 0;
		}
		for (var column = gameCanvas.numOfColumns-1; column >= 0 && board[row][column] == 1; --column) {
			board[row][column] = 0;
		}
	}
	for (var column = 0; column < gameCanvas.numOfColumns; ++column) {
		for (var row = 0; row < gameCanvas.numOfRows && board[row][column] < 2; ++row) {
			board[row][column] = 0;
		}
		for (var row = gameCanvas.numOfRows-1; row >= 0 && board[row][column] < 2; --row) {
			board[row][column] = 0;
		}
	}
}

function initBoard() {
	boardItems = new Array(maxIndex);
	itemObjects = new Array();

	createBoard();

	for (var column = 0; column < gameCanvas.numOfColumns; ++column) {
		for (var row = 0; row < gameCanvas.numOfRows; ++row) {
			boardItems[index(column, row)] = null;
			createBlock(column, row);
		}
	}
}

function createBlockObject(item, column, row) {
	var dynamicObject = null;
	var component = Qt.createComponent(item);

	if (component.status == Component.Ready) {
		dynamicObject = component.createObject(gameCanvas);
		if (dynamicObject == null) {
			console.log("error creating block");
			console.log(component.errorString());
			return null;
		}
		dynamicObject.column = column
		dynamicObject.row = row
	} else {
		console.log("error loading block component");
		console.log(component.errorString());
		return null;
	}
	return dynamicObject;
}

function createBlock(column, row) {
	var blockSet = ["ItemFloor.qml", "ItemGoal.qml", "ItemObject.qml", "ItemMan.qml", "ItemBorder0.qml", "ItemBorder1.qml", "ItemBorder2.qml", "ItemBorder3.qml"];
	var which = board[row][column]; // 0: outside, 1: inside, 2: border, 3: goal, 4: object, 5: man, 6: object on goal, 7: man on goal
	var item;

	if (which <= 0)
		return true;

	switch (which) {
		case 1:
		case 4: // when the spot has an object on it, put a floor item on this place and separately create the object below
		case 5: // when the spot has the man on it, put a floor item on this place and separately create the man below
		default:
			item = blockSet[0];
			break;
		case 3:
		case 6: // when the spot has an object on it, put a goal item on this place and separately create the object below
		case 7: // when the spot has the man on it, put a goal item on this place and separately create the man below
			item = blockSet[1];
			break;
		case 2: // border
			if (board[row][column-1] != 2 && board[row][column+1] == 2)
				item = blockSet[4];
			else if (board[row][column-1] == 2 && board[row][column+1] == 2)
				item = blockSet[5];
			else if (board[row][column-1] == 2 && board[row][column+1] != 2)
				item = blockSet[6];
			else
				item = blockSet[7];
			break;
	}

	var dynamicObject = createBlockObject(item, column, row);
	if (dynamicObject == null)
		return false;
	boardItems[index(column, row)] = dynamicObject;

	if (which == 4 || which == 6) { // create the object
		dynamicObject = createBlockObject(blockSet[2], column, row);
		if (dynamicObject == null)
			return false;
		dynamicObject.z = 1;
		itemObjects[itemObjects.length] = dynamicObject;
	} else if (which == 5 || which == 7) { // create the man
		if (itemMan == null) {
			dynamicObject = createBlockObject(blockSet[3], column, row);
			if (dynamicObject == null)
				return false;
			dynamicObject.z = 1;
			itemMan = dynamicObject;
		} else { // the man already exists from a previous level, reposition him
			itemMan.column = column;
			itemMan.row = row;
			itemMan.opacity = 1;
		}
	}
	return true;
}

/*******************************************************************/
/* Zooming */

function setZooming(isZooming) {
	for (var row = 0; row < gameCanvas.numOfRows; ++row) {
		for (var column = 0; column < gameCanvas.numOfColumns; ++column) {
			if (board[row][column] > 0)
				boardItems[index(column, row)].isZooming = isZooming;
		}
	}
	for (var i = 0; i < numOfGoals; ++i) // numOfGoals = number of objects
		itemObjects[i].isZooming = isZooming;
	if (itemMan != null)
		itemMan.isZooming = isZooming;
}

function recenterMan(x, y, dx, dy) {
	var currentManPixelX = x * gameCanvas.blockSize + gameCanvas.offsetX;
	var currentManPixelY = y * gameCanvas.blockSize + gameCanvas.offsetY;

	if (gameCanvas.numOfColumns * gameCanvas.blockSize <= gameCanvas.width) {
		dx = 0;
		gameCanvas.addOffsetX = 0;
	}
	if (gameCanvas.numOfRows * gameCanvas.blockSize <= gameCanvas.height) {
		dy = 0;
		gameCanvas.addOffsetY = 0;
	}

	if (dx < 0 || dx > 1)
		while (currentManPixelX < 3 * gameCanvas.blockSize) {
			gameCanvas.addOffsetX += gameCanvas.blockSize;
			currentManPixelX += gameCanvas.blockSize;
		}
	if (dy < 0 || dy > 1)
		while (currentManPixelY < 3 * gameCanvas.blockSize) {
			gameCanvas.addOffsetY += gameCanvas.blockSize;
			currentManPixelY += gameCanvas.blockSize;
		}
	if (dx > 0)
		while (currentManPixelX > gameCanvas.width - 3 * gameCanvas.blockSize) {
			gameCanvas.addOffsetX -= gameCanvas.blockSize;
			currentManPixelX -= gameCanvas.blockSize;
		}
	if (dy > 0)
		while (currentManPixelY > gameCanvas.height - 3 * gameCanvas.blockSize) {
			gameCanvas.addOffsetY -= gameCanvas.blockSize;
			currentManPixelY -= gameCanvas.blockSize;
		}
}

function zoomIn() {
	if (6 * gameCanvas.blockSize > gameCanvas.width || 6 * gameCanvas.blockSize > gameCanvas.height)
		return;

	setZooming(true);
	gameCanvas.addBlockSize += 5;
	recenterMan(itemMan.column, itemMan.row, 2, 2); // dx = 2 and dy = 2 in order to force recentering in both directions
	setZooming(false);
}

function zoomOut() {
	if (gameCanvas.blockSize < 10)
		return;

	setZooming(true);
	gameCanvas.addBlockSize -= 5;
	recenterMan(itemMan.column, itemMan.row, 2, 2); // dx = 2 and dy = 2 in order to force recentering in both directions
	setZooming(false);
}

/*******************************************************************/
/* Move man in board */

function testLevelWon() {
	if (numOfTreasures == numOfGoals) {
		if (gameView.currentLevel >= gameView.levels.length - 1)
			gameView.state = "gamewon";
		else
			gameView.state = "levelwon";
	}
}

function findItemObjectNumber(column, row) {
	var which = -1;
	for (var i = 0; i < itemObjects.length; ++i) {
		if (itemObjects[i].column == column && itemObjects[i].row == row) {
			which = i;
			break;
		}
	}
	return which;
}

function changeManPosition(oldX, oldY, newX, newY, dx, dy) {
	board[newY][newX] += 4; // 1: inside -> 5: man; 3: goal -> 7: man on goal
	board[oldY][oldX] -= 4; // 5 -> 1; 7 -> 3
	recenterMan(newX, newY, dx, dy);
}

function changeObjectPosition(which, oldX, oldY, newX, newY) {
	if (board[oldY][oldX] == 6) // if object previously on goal
		--numOfTreasures;
	board[newY][newX] += 3; // 1: inside -> 4: object; 3: goal -> 6: treasure
	board[oldY][oldX] -= 3; // 4 -> 1; 6 -> 3
	itemObjects[which].column = newX
	itemObjects[which].row = newY
	if (board[newY][newX] == 6) // if object now on goal
		++numOfTreasures;
}

function moveMan(dx, dy) {
	// 0: outside, 1: inside, 2: border, 3: goal, 4: object, 5: man, 6: object on goal, 7: man on goal
	if (board[itemMan.row+dy][itemMan.column+dx] == 1 || board[itemMan.row+dy][itemMan.column+dx] == 3) {
		changeManPosition(itemMan.column, itemMan.row, itemMan.column + dx, itemMan.row + dy, dx, dy);
		addToUndoHistory(dx, dy, 0);
		itemMan.column += dx;
		itemMan.row += dy;
	}
	else if ((board[itemMan.row+dy][itemMan.column+dx] == 4 || board[itemMan.row+dy][itemMan.column+dx] == 6)
	    && (board[itemMan.row+2*dy][itemMan.column+2*dx] == 1 || board[itemMan.row+2*dy][itemMan.column+2*dx] == 3)) {
		var which = findItemObjectNumber(itemMan.column + dx, itemMan.row + dy);
		changeObjectPosition(which, itemMan.column + dx, itemMan.row + dy, itemMan.column + 2 * dx, itemMan.row + 2 * dy);
		changeManPosition(itemMan.column, itemMan.row, itemMan.column + dx, itemMan.row + dy, dx, dy); // must do this after changeObjectPosition because if the man goes to the place where the block was, the new type of the place is miscalculated
		addToUndoHistory(dx, dy, 1);
		itemMan.column += dx;
		itemMan.row += dy;
	}
	testLevelWon();
}

function moveUp() {
	moveMan(0, -1);
}

function moveDown() {
	moveMan(0, 1);
}

function moveLeft() {
	moveMan(-1, 0);
}

function moveRight() {
	moveMan(1, 0);
}

function moveManWithMouse(x, y) {
	var dx = Math.floor((x - gameCanvas.offsetX) / gameCanvas.blockSize) - itemMan.column;
	var dy = Math.floor((y - gameCanvas.offsetY) / gameCanvas.blockSize) - itemMan.row;

	if (dx != 0 && dy != 0) // we allow movement in one direction only
		return;

	var oldManX = 0;
	var oldManY = 0;
	if (dx > 0) {
		for (var i = 0; i < dx && itemMan.column != oldManX; ++i) {
			oldManX = itemMan.column;
			moveRight();
		}
	} else if (dx < 0) {
		for (var i = 0; i > dx && itemMan.column != oldManX; --i) {
			oldManX = itemMan.column;
			moveLeft();
		}
	} else if (dy > 0) {
		for (var i = 0; i < dy && itemMan.row != oldManY; ++i) {
			oldManY = itemMan.row;
			moveDown();
		}
	} else if (dy < 0) {
		for (var i = 0; i > dy && itemMan.row != oldManY; --i) {
			oldManY = itemMan.row;
			moveUp();
		}
	}
}

/*******************************************************************/
/* Undo */

function addToUndoHistory(dx, dy, isPushing) {
	var num = undoHistoryStep;
	var move = (dx == -1 ? 0 : (dx == 1 ? 1 : (dy == -1 ? 2 : 3)));
	if (isPushing)
		move += 4;
	undoHistory[num] = move;
	++undoHistoryStep;
}

function undo() {
	var dx;
	var dy;

	if (undoHistoryStep < 1)
		return;
	--undoHistoryStep;

	switch (undoHistory[undoHistoryStep]) {
		case 0: case 4: dx = -1; dy = 0; break;
		case 1: case 5: dx = 1; dy = 0; break;
		case 2: case 6: dx = 0; dy = -1; break;
		case 3: case 7: dx = 0; dy = 1; break;
	}
	changeManPosition(itemMan.column, itemMan.row, itemMan.column - dx, itemMan.row - dy, -dx, -dy); // must do this before changeObjectPosition because if the man is on the place where the block returns, the new type of the place is miscalculated
	if (undoHistory[undoHistoryStep] >= 4) { // if an object was moved in this step
		var which = findItemObjectNumber(itemMan.column + dx, itemMan.row + dy);
		changeObjectPosition(which, itemMan.column + dx, itemMan.row + dy, itemMan.column, itemMan.row);
	}
	itemMan.column -= dx;
	itemMan.row -= dy;
}

/*******************************************************************/
/* Change levels */

function goToPreviousLevel() {
	if (gameView.currentLevel > 0)
		--gameView.currentLevel;
	else
		gameView.currentLevel = gameView.levels.length - 1;
	startNewGame();
}

function goToNextLevel() {
	if (gameView.currentLevel < gameView.levels.length - 1)
		++gameView.currentLevel;
	else
		gameView.currentLevel = 0;
	startNewGame();
}
