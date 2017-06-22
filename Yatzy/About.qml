import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    header: PageHeader {
        id: pageHeader
        // TRANSLATORS: Title of the About page
        title: i18n.tr("About")
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: pageStack.pop()
            }
        ]
    }

    Flickable {

        id: page_flickable
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight:  about_column.height + units.gu(6)
        clip: true
        Column {
            id: about_column
            anchors.centerIn: parent
            spacing: units.gu(4)

            Column {
                width: parent.width

                Text {
                    font.weight: Font.DemiBold
                    // TRANSLATORS: app name
                    text: i18n.tr("Yatzy")
                    font.pointSize: units.gu(2.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: i18n.tr("Version ") + "0.2"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ProportionalShape {
                id: logo
                width: units.gu(17)
                source: Image {
                    source: "Yatzy.svg"
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                width: parent.width

                Text {
                    text: "© 2016-2017 Michele Castellazzi"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    font.pointSize: units.gu(1)
                    text: i18n.tr("Released under the terms of the GNU GPL v3")
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: parent.width
                spacing: units.gu(2)

                Text {
                    font.underline: false
                    text: i18n.tr("Source code available on <a style=\"text-decoration: none;\" href=\"https://github.com/mymike00/Yatzy\">GitHub.com</a>")
                    font.pointSize: units.gu(1)

                    anchors.horizontalCenter: parent.horizontalCenter
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }

    }
}
