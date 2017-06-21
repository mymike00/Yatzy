/*
 * Copyright 2015 Robert Ancell <robert.ancell@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3 as published by the
 * Free Software Foundation. See http://www.gnu.org/copyleft/gpl.html the full
 * text of the license.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3

GridLayout {
    id: entry
    columns: 1

    property string date: ""
    property string score: ""

    Label {
        Layout.alignment: Qt.AlignHCenter
        fontSize: "x-large"
        font.bold: true
        text: entry.score
    }

    Label {
        Layout.alignment: Qt.AlignHCenter
        text: entry.date
    }
}
