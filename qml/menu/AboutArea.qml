/**

	About area.

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
	id: aboutArea
	width: aboutAreaFlickable.contentWidth // see next alias below

	property alias contentWidth: aboutAreaFlickable.contentWidth // let aboutAreaFlickable.contentWidth be fixed and let aboutArea.width depend on aboutAreaFlickable.contentWidth and be variable, and not conversely, so that making aboutArea smaller during hiding doesn't change the text width, this is necessary for not screwing up the text wrap
	property alias font: aboutAreaText.font

	border { color: "#444444"; width: 2 }
	radius: 5
	gradient: Gradient {
		GradientStop { position: 0; color: "#666666" }
		GradientStop { position: 1; color: "#333333" }
	}

	Flickable {
		id: aboutAreaFlickable
		anchors.fill: parent
		contentHeight: aboutAreaText.height + 2 * aboutAreaText.anchors.topMargin
		flickableDirection: Flickable.VerticalFlick
		clip: true

		Text {
			id: aboutAreaText
			width: parent.width - 2 * anchors.topMargin
			anchors {
				top: parent.top
				topMargin: 10
				horizontalCenter: parent.horizontalCenter
			}
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignHCenter
			color: "#CCCCCC"
			textFormat: Text.RichText
			text: qsTr("<p>This is a Sokoban game. The purpose of the game "
			      + "is to move the diamonds to the green spots by "
			      + "letting the man push against the diamonds. You "
			      + "move the man using the arrow keys or by clicking/touching "
			      + "the place where the man must move (only horizontal "
			      + "or vertical moves are possible).</p><p>Enjoy!</p>"
			      + "<p>If the screen is small, the buttons in the menu "
			      + "or in the toolbar may not all be visible, in this case "
			      + "the menu and the toolbar can be dragged to make these "
			      + "buttons visible.</p>")
			      + "<p>Copyright 2010, 2011 Glad Deschrijver</p>"
			      + qsTr("<p>This program is free software; you can redistribute it and/or modify "
			      + "it under the terms of the GNU General Public License as published by "
			      + "the Free Software Foundation; either version 3 of the License, or "
			      + "(at your option) any later version.</p>"
			      + "<p>This program is distributed in the hope that it will be useful, "
			      + "but WITHOUT ANY WARRANTY; without even the implied warranty of "
			      + "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
			      + "GNU General Public License for more details.</p>"
			      + "<p>You should have received a copy of the GNU General Public License "
			      + "along with this program; if not, see <a style=\"color: #BBBBEE\" href=\"http://www.gnu.org/licenses\">http://www.gnu.org/licenses</a>.</p>")
			onLinkActivated: Qt.openUrlExternally(link)
		}
	}

	states: State {
		name: "hidden"
		PropertyChanges {
			target: aboutArea
			opacity: 0
			width: 0
			anchors.leftMargin: 0 // set this to 0 so that the margins of the smaller version of the menu are decent
		}
	}

	transitions: Transition {
		NumberAnimation {
			properties: "opacity, width, anchors.leftMargin"
			duration: 400
		}
	}
}
