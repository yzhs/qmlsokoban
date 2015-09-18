/**

	General item on the board.

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

import QtQuick 2.0

Item {
	id: boardItem
	width: gameCanvas.blockSize
	height: gameCanvas.blockSize
	x: column * gameCanvas.blockSize + gameCanvas.offsetX
	y: row * gameCanvas.blockSize + gameCanvas.offsetY

	property int column // determined in game.js for each item
	property int row // idem
	property bool isZooming: false
	property bool isAnimated: gameCanvas.isAnimated
	property int animationDuration: isZooming ? 300 : 100
	property int animationType: isZooming ? Easing.InOutQuint : Easing.Linear
	property alias source: backgroundImage.source

	Image {
		id: backgroundImage
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		sourceSize.width: 96
		sourceSize.height: 96
	}

	Behavior on x {
		enabled: isZooming || isAnimated
		NumberAnimation { duration: animationDuration; easing.type: animationType }
	}

	Behavior on y {
		enabled: isZooming || isAnimated
		NumberAnimation { duration: animationDuration; easing.type: animationType }
	}

	Behavior on width {
		enabled: isZooming
		NumberAnimation { duration: animationDuration; easing.type: animationType }
	}

	Behavior on height {
		enabled: isZooming
		NumberAnimation { duration: animationDuration; easing.type: animationType }
	}
}
