/**

	Menu title.

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

Row {
	id: menuTitle
	anchors {
		top: parent.top
		horizontalCenter: parent.horizontalCenter
		margins: 10
	}
	height: menuTitleText.height
	spacing: 10

	Image {
		anchors.verticalCenter: parent.verticalCenter
		width: parent.height
		height: parent.height
		source: "../gameview/images/man.png"
	}

	Text {
		id: menuTitleText
		anchors.verticalCenter: parent.verticalCenter
		font {
			//pixelSize: Math.min(32, Math.floor((menuPanel.maxWidth - 32 - 2 * parent.anchors.leftMargin - 2 * parent.spacing) / 11))
			pointSize: aboutArea.font.pointSize + 2 // hopefully this is small enough to fit on the screen
			bold: true
		}
		smooth: true
		color: "white"
		style: Text.Outline
		styleColor: "#555555"
		verticalAlignment: Text.AlignVCenter
		text: "QML Sokoban"
		clip: true
	}

	Image {
		anchors.verticalCenter: parent.verticalCenter
		width: parent.height
		height: parent.height
		source: "../gameview/images/object.png"
	}

	states: State {
		name: "collapsed"
		PropertyChanges {
			target: menuTitleText
			opacity: 0.0001 // not 0 in order to prevent menuTitleText to disappear completely and let the spacing between the icons suddenly reduce from 20 to 10 (because there is one item less in the row)
			width: 0.5 // idem
		}
	}

	transitions: Transition {
		NumberAnimation {
			properties: "opacity, width"
			duration: 400
		}
	}
}
