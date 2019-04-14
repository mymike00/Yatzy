/*
 * Copyright (C) 2015 Robert Ancell <robert.ancell@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    property int potential_score: 0
    property var actual_score: undefined
    property var effective_score: actual_score == undefined ? 0 : actual_score
    signal selected ()
    implicitWidth: button.width
    implicitHeight: button.height
    Button {
        id: button
        width: units.gu(5)
        anchors.verticalCenter: parent.verticalCenter
        text: parent.potential_score
        opacity: actual_score == undefined ? 1 : 0
        onClicked: {
            if (parent.actual_score == undefined) {
                parent.actual_score = parent.potential_score
                parent.selected ()
            }
        }
        Behavior on opacity {
            NumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }
        }
    }
    Label {
        id: label
        width: button.width
        height: button.height
        opacity: actual_score == undefined ? 0 : 1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: parent.actual_score != undefined ? parent.actual_score : ""
        font.bold: true
        Behavior on opacity {
            NumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }
        }
    }
}
