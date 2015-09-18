/**

	Menu button.

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
	id: container

	property alias text: buttonLabel.text
	property alias textWidth: buttonLabel.width // must be specified for multi-length string selection to work (see MenuPanel)

	property string buttonColor: "#555555"
	property string borderColor: "#666666"
	property real paddingX: 10
	property real paddingY: 3

	signal clicked

	width: buttonLabel.width + 2 * paddingX
	height: buttonLabel.height + 2 * paddingY
	smooth: true
	border { width: 1; color: borderColor }
	radius: 5
	color: "white"

	gradient: Gradient {
		GradientStop { position: 0.0; color: buttonColor }
		GradientStop { position: 0.4; color: "#111111" }
		GradientStop { position: 1.0; color: buttonColor }
	}

	Text {
		id: buttonLabel
		anchors.centerIn: container
		color: "white"
		horizontalAlignment: Text.AlignHCenter
		elide: Text.ElideRight // must be specified for multi-length string selection to work
		text: "Button"
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: container.clicked()
	}

	states: [
		State {
			name: "pressed"
			when: mouseArea.pressed
			PropertyChanges {
				target: container
				buttonColor: "#333333"
				borderColor: "#555555"
			}
		},
		State {
			name: "disabled"
			PropertyChanges {
				target: container
				buttonColor: "#111111"
				borderColor: "#444444"
			}
			PropertyChanges { target: mouseArea; enabled: false }
		}
	]
}
