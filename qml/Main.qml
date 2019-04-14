import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "yatzy.mike"

    width: units.gu(40)
    height: units.gu(75)

    property bool mode: false;

    Component {
        id: confirm_new_game_dialog
        Dialog {
            id: d
            // TRANSLATORS: Title for dialog shown when starting a new game while one in progress
            title: i18n.tr ("Game in progress")
            // TRANSLATORS: Content for dialog shown when starting a new game while one in progress
            text: i18n.tr ("Are you sure you want to restart this game?")
            Row {
                spacing: units.gu(1)
                width: d.width
                Component.onCompleted: console.log(width)

                Button {
                    id: restartButton
                    height: restartCol.height+units.gu(2)
                    width: parent.width/2

                    Column {
                        id: restartCol
                        x: (restartButton.width-restartCol.width)/2
                        y: units.gu(1)
                        spacing: units.gu(1)

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "reset"
                            width: height
                            height: units.gu(5) //< parent.height*3/5 ? parent.height*3/5 : units.gu(5)
                            color: "white"
                        }

                        Text {
                            // TRANSLATORS: Button in new game dialog that cancels the current game and starts a new one
                            text: i18n.tr("Start a<br/>new game")
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }

                    // TRANSLATORS: Button in new game dialog that cancels the current game and starts a new one
                    //text: i18n.tr ("Restart game")
                    color: UbuntuColors.red
                    onClicked: {
                        main_page.restart ()
                        PopupUtils.close (d)
                    }
                }
                Button {
                    id: closeButton
                    height: closeCol.height+units.gu(2)
                    width: parent.width/2

                    Column {
                        id: closeCol
                        x: (closeButton.width-closeCol.width)/2
                        y: units.gu(1)
                        spacing: units.gu(1)

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "media-playback-start"
                            width: height
                            height: units.gu(5) //< parent.height*3/5 ? parent.height*3/5 : units.gu(5)
                            color: "white"
                        }

                        Text {
                            // TRANSLATORS: Button in new game dialog that cancels the current game and starts a new one
                            text: i18n.tr("Continue<br/>current game")
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }

                    // TRANSLATORS: Button in new game dialog that cancels the current game and starts a new one
                    //text: i18n.tr ("Restart game")
                    color: UbuntuColors.green
                    onClicked: PopupUtils.close (d)
                }
            }
        }
    }
    Component {
        id: confirm_clear_scores_dialog
        Dialog {
            id: d
            // TRANSLATORS: Title for dialog confirming if scores should be cleared
            title: i18n.tr ("Clear scores")
            // TRANSLATORS: Content for dialog confirming if scores should be cleared
            text: i18n.tr ("Existing scores will be deleted. This cannot be undone.")
            Button {
                // TRANSLATORS: Button in clear scores dialog that clears scores
                text: i18n.tr ("Clear scores")
                color: UbuntuColors.red
                onClicked: {
                    main_page.clear_scores ()
                    PopupUtils.close (d)
                }
            }
            Button {
                // TRANSLATORS: Button in clear scores dialog that cancels clear scores request
                text: i18n.tr ("Keep existing scores")
                onClicked: PopupUtils.close (d)
            }
        }
    }

    PageStack {
        id:page_stack
        Component.onCompleted: push (main_page)

        Page {
            id: main_page
            visible: false
            header: PageHeader {
                id: pageHeader
                // TRANSLATORS: Title of application
                title: mode ? i18n.tr ("Kniffel") : i18n.tr ("Yatzy")
                trailingActionBar.numberOfSlots: 4
                trailingActionBar.actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("How to play")
                        onTriggered: page_stack.push (about_page)
                    },
                    Action {
                        text: i18n.tr("High scores")
                        iconSource: "../assets/high-scores.svg"
                        onTriggered: {
                            main_page.update_scores ()
                            page_stack.push (scores_page)
                        }
                    },
                    Action {
                        text: i18n.tr("Reload")
                        iconName: "reload"
                        onTriggered: {
                            if (main_page.is_started () && !main_page.is_complete ())
                                PopupUtils.open (confirm_new_game_dialog)
                            else
                                main_page.restart ()
                        }
                    },
                    Action {
                        text: i18n.tr("Mode")
                        iconName: "settings"
                        onTriggered: {
                            mode = !mode
                            main_page.restart ()
                        }
                    }
                ]
            }

            Component.onCompleted: restart ()

            property var dice: [ die0, die1, die2, die3, die4 ]
            property var rolling: die0.rolling || die1.rolling || die2.rolling || die3.rolling || die4.rolling
            property int reroll_count: 0
            property var score_labels: mode ? [ ones_score_label, twos_score_label, threes_score_label, fours_score_label, fives_score_label, sixes_score_label, three_of_a_kind_score_label, four_of_a_kind_score_label, small_straight_score_label, large_straight_score_label, house_score_label, yatzy_score_label, chance_score_label ] : [ ones_score_label, twos_score_label, threes_score_label, fours_score_label, fives_score_label, sixes_score_label, one_pair_score_label, two_pair_score_label, three_of_a_kind_score_label, four_of_a_kind_score_label, small_straight_score_label, large_straight_score_label, house_score_label, yatzy_score_label, chance_score_label ]
            property int total_score: mode ? ones_score_label.effective_score + twos_score_label.effective_score + threes_score_label.effective_score + fours_score_label.effective_score + fives_score_label.effective_score + sixes_score_label.effective_score + three_of_a_kind_score_label.effective_score + four_of_a_kind_score_label.effective_score + small_straight_score_label.effective_score + large_straight_score_label.effective_score + house_score_label.effective_score + yatzy_score_label.effective_score + chance_score_label.effective_score + bonus_score_label.effective_score : ones_score_label.effective_score + twos_score_label.effective_score + threes_score_label.effective_score + fours_score_label.effective_score + fives_score_label.effective_score + sixes_score_label.effective_score + one_pair_score_label.effective_score + two_pair_score_label.effective_score + three_of_a_kind_score_label.effective_score + four_of_a_kind_score_label.effective_score + small_straight_score_label.effective_score + large_straight_score_label.effective_score + house_score_label.effective_score + yatzy_score_label.effective_score + chance_score_label.effective_score + bonus_score_label.effective_score
            property bool game_is_over: false

            function roll () {
                for (var i = 0; i < dice.length; i++)
                    dice[i].roll ()
            }

            function restart () {
                game_is_over = false
                for (var i = 0; i < score_labels.length; i++) {
                    score_labels[i].potential_score = 0
                    score_labels[i].actual_score = undefined
                }
                next_turn ()
            }

            function next_turn () {
                if (is_complete ()) {
                    game_over ()
                    return
                }

                reroll_count = 0
                for (var i = 0; i < dice.length; i++)
                    dice[i].held = false
                roll ()
            }

            function game_over () {
                if (game_is_over)
                    return
                game_is_over = true

                // Save score
                var now = new Date ()
                get_database ().transaction (function (t) {
                    t.executeSql ("CREATE TABLE IF NOT EXISTS Scores(date TEXT, total NUMBER, ones NUMBER, twos NUMBER, threes NUMBER, fours NUMBER, fives NUMBER, sixes NUMBER, one_pair NUMBER, two_pair NUMBER, three_of_a_kind NUMBER, four_of_a_kind NUMBER, small_straight NUMBER, large_straight NUMBER, house NUMBER, yatzy NUMBER, chance NUMBER)")
                    t.executeSql ("INSERT INTO Scores VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [now.toISOString (), total_score, ones_score_label.effective_score, twos_score_label.effective_score, threes_score_label.effective_score, fours_score_label.effective_score, fives_score_label.effective_score, sixes_score_label.effective_score, one_pair_score_label.effective_score, two_pair_score_label.effective_score, three_of_a_kind_score_label.effective_score, four_of_a_kind_score_label.effective_score, small_straight_score_label.effective_score, large_straight_score_label.effective_score, house_score_label.effective_score, yatzy_score_label.effective_score, chance_score_label.effective_score])
                })
            }

            function update_scores () {
                var scores
                get_database ().transaction (function (t) {
                    try {
                        scores = t.executeSql ("SELECT * FROM Scores ORDER BY total DESC LIMIT 5")
                    }
                    catch (e) {
                    }
                })
                var n_scores = 0
                if (scores !== undefined)
                    n_scores = scores.rows.length

                var score_entries = [ score_entry0, score_entry1, score_entry2, score_entry3, score_entry4 ]
                var i
                for (i = 0; i < n_scores; i++) {
                    var item = scores.rows.item (i)
                    score_entries[i].visible = true
                    score_entries[i].score = item.total
                    score_entries[i].date = format_date (new Date (item.date))
                }
                for (; i < 5; i++) {
                    score_entries[i].score = ""
                    score_entries[i].date = ""
                }
            }

            function format_date (date) {
                var now = new Date ()
                var seconds = (now.getTime () - date.getTime ()) / 1000
                if (seconds < 1) {
                    // TRANSLATORS: Label shown below high score for a score just achieved
                    return i18n.tr ("Now")
                }
                if (seconds < 120) {
                    var n_seconds = Math.floor (seconds)
                    // TRANSLATORS: Label shown below high score for a score achieved seconds ago
                    return i18n.tr ("%n second ago", "%n seconds ago", n_seconds).replace ("%n", n_seconds)
                }
                var minutes = seconds / 60
                if (minutes < 120) {
                    var n_minutes = Math.floor (minutes)
                    // TRANSLATORS: Label shown below high score for a score achieved minutes ago
                    return i18n.tr ("%n minute ago", "%n minutes ago", n_minutes).replace ("%n", n_minutes)
                }
                var hours = minutes / 60
                if (hours < 48) {
                    var n_hours = Math.floor (hours)
                    // TRANSLATORS: Label shown below high score for a score achieved hours ago
                    return i18n.tr ("%n hour ago", "%n hours ago", n_hours).replace ("%n", n_hours)
                }
                var days = hours / 24
                if (days < 30) {
                    var n_days = Math.floor (days)
                    // TRANSLATORS: Label shown below high score for a score achieved days ago
                    return i18n.tr ("%n day ago", "%n days ago", n_days).replace ("%n", n_days)
                }
                if (date.getFullYear () != now.getFullYear ())
                    return Qt.formatDate (date, "MMM yyyy")
                return Qt.formatDate (date, "d MMM")
            }

            function clear_scores () {
                get_database ().transaction (function (t) {
                    try {
                        t.executeSql ("DELETE FROM Scores")
                    }
                    catch (e) {
                    }
                })
                update_scores ()
            }

            function get_database () {
                if (mode)
                    return LocalStorage.openDatabaseSync ("scoresk", "1", "Kniffel Scores", 1)
                else
                    return LocalStorage.openDatabaseSync ("scores", "1", "Yatzy Scores", 0)
            }

            function is_started () {
                for (var i = 0; i < score_labels.length; i++)
                    if (score_labels[i].actual_score !== undefined)
                        return true
                return false
            }

            function is_complete () {
                for (var i = 0; i < score_labels.length; i++)
                    if (score_labels[i].actual_score === undefined)
                        return false
                return true
            }

            function update_potential_scores () {
                ones_score_label.potential_score = sum_equal (1)
                twos_score_label.potential_score = sum_equal (2)
                threes_score_label.potential_score = sum_equal (3)
                fours_score_label.potential_score = sum_equal (4)
                fives_score_label.potential_score = sum_equal (5)
                sixes_score_label.potential_score = sum_equal (6)
                one_pair_score_label.potential_score = one_pair_score ()
                two_pair_score_label.potential_score = two_pair_score ()
                three_of_a_kind_score_label.potential_score = three_of_a_kind_score ()
                four_of_a_kind_score_label.potential_score = four_of_a_kind_score ()
                small_straight_score_label.potential_score = small_straight_score ()
                large_straight_score_label.potential_score = large_straight_score ()
                house_score_label.potential_score = house_score ()
                yatzy_score_label.potential_score = yatzy_score ()
                chance_score_label.potential_score = chance_score ()
            }

            function sum_total () {
                var s = 0
                for (var i = 0; i < dice.length; i++)
                    s += dice[i].value
                return s
            }

            function die_count (value) {
                var n = 0
                for (var i = 0; i < dice.length; i++)
                    if (dice[i].value === value)
                        n++
                return n
            }

            function get_counts () {
                var counts = [ 0, 0, 0, 0, 0, 0, 0 ]
                for (var i = 0; i < dice.length; i++)
                    counts[dice[i].value]++
                return counts
            }

            function sum_equal (value) {
                return die_count (value) * value
            }

            function one_pair_score () {
                var counts = get_counts ()
                for (var i = 6; i >= 1; i--)
                    if (counts[i] >= 2)
                        return i * 2
                return 0
            }

            function two_pair_score () {
                var counts = get_counts ()
                var score = 0
                var n_pairs = 0
                for (var i = 6; i >= 1; i--) {
                    if (counts[i] >= 4)
                        return i * 4
                    if (counts[i] >= 2) {
                        score += i * 2
                        n_pairs++
                        if (n_pairs == 2)
                            return score
                    }
                }
                return 0
            }

            function three_of_a_kind_score () {
                var counts = get_counts ()
                for (var i = 1; i <= 6; i++)
                    if (counts[i] >= 3)
                        if (mode)
                            return sum_total ()
                        else
                            return i * 3
                return 0
            }

            function four_of_a_kind_score () {
                var counts = get_counts ()
                for (var i = 1; i <= 6; i++)
                    if (counts[i] >= 4)
                        if (mode)
                            return sum_total ()
                        else
                            return i * 4
                return 0
            }

            function small_straight_score () {
                var counts = get_counts ()
                if (!mode && (counts[1] === 1 && counts[2] === 1 && counts[3] === 1 && counts[4] === 1 && counts[5] === 1))
                    return sum_total ()
                else if (mode && ((counts[1] >= 1 && counts[2] >= 1 && counts[3] >= 1 && counts[4] >= 1) || (counts[2] >= 1 && counts[3] >= 1 && counts[4] >= 1 && counts[5] >= 1) || (counts[3] >= 1 && counts[4] >= 1 && counts[5] >= 1 && counts[6] >= 1)))
                    return 30
                else
                    return 0
            }

            function large_straight_score () {
                var counts = get_counts ()
                if (!mode && (counts[2] === 1 && counts[3] === 1 && counts[4] === 1 && counts[5] === 1 && counts[6] === 1))
                    return sum_total ()
                else if (mode && (counts[1] === 1 && counts[2] === 1 && counts[3] === 1 && counts[4] === 1 && counts[5] === 1) || (counts[2] === 1 && counts[3] === 1 && counts[4] === 1 && counts[5] === 1 && counts[6] === 1))
                    return 40
                else
                    return 0
            }

            function house_score () {
                var counts = get_counts ()
                var have_3 = false
                var have_2 = false
                for (var i = 1; i <= 6; i++) {
                    if (counts[i] === 3 || counts[i] === 5)
                        have_3 = true
                    if (counts[i] === 2 || counts[i] === 5)
                        have_2 = true
                }

                if (have_3 && have_2)
                    if (mode)
                        return 25
                    else
                        return sum_total ()
                else
                    return 0
            }

            function yatzy_score () {
                var counts = get_counts ()
                for (var i = 1; i <= 6; i++)
                    if (counts[i] === 5)
                        return 50
                return 0
            }

            function chance_score () {
                return sum_total ()
            }

            RowLayout {
                id: dice_row
                anchors.top: pageHeader.bottom
                anchors.topMargin: units.gu (2)
                anchors.horizontalCenter: parent.horizontalCenter
                property var die_size: units.gu (7)

                Die {
                    id: die0
                    width: parent.die_size
                    height: parent.die_size
                    onChanged: main_page.update_potential_scores ()
                }
                Die {
                    id: die1
                    width: parent.die_size
                    height: parent.die_size
                    onChanged: main_page.update_potential_scores ()
                }
                Die {
                    id: die2
                    width: parent.die_size
                    height: parent.die_size
                    onChanged: main_page.update_potential_scores ()
                }
                Die {
                    id: die3
                    width: parent.die_size
                    height: parent.die_size
                    onChanged: main_page.update_potential_scores ()
                }
                Die {
                    id: die4
                    width: parent.die_size
                    height: parent.die_size
                    onChanged: main_page.update_potential_scores ()
                }
            }

            Button {
                id: reroll_button
                anchors.top: dice_row.bottom
                anchors.topMargin: units.gu (2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: main_page.game_is_over ? UbuntuColors.green : UbuntuColors.orange
                // TRANSLATORS: Button text for roll button when game is complete (starts a new game)
                property string new_game_text: i18n.tr ("New Game")
                // TRANSLATORS: Button text for roll button. %n is replaced with the number of rolls remaining
                property string roll_text: i18n.tr ("Roll (%n)")
                text: main_page.game_is_over ? new_game_text : roll_text.replace ("%n", 2 - main_page.reroll_count)
                enabled: (main_page.game_is_over || main_page.reroll_count < 2) && !main_page.rolling
                onClicked: {
                    if (main_page.game_is_over)
                        main_page.restart ()
                    else {
                        main_page.reroll_count++
                        main_page.roll ()
                    }
                }
            }
            /*ScrollView {
                id: page_scrollview
                anchors {
                    top: reroll_button.bottom
                    topMargin: units.gu (2)
                    bottom: total_label.top
                    bottomMargin: units.gu (2)
                    horizontalCenter: dice_row.horizontalCenter
                }*/
            Flickable {
                id: flick
                //anchors.fill: parent
                anchors {
                    top: reroll_button.bottom
                    topMargin: units.gu (2)
                    bottom: total_label.top
                    bottomMargin: units.gu (2)
                    horizontalCenter: dice_row.horizontalCenter
                }
                width: dice_row.width
                clip: true
                flickableDirection: Flickable.VerticalFlick //parent.width > width+units.gu(2) ? Flickable.VerticalFlick : Flickable.HorizontalAndVerticalFlick
                contentHeight: whole_grid.height
                contentWidth: whole_grid.width

                GridLayout {
                    id: whole_grid
                    columns: 2
                    columnSpacing: units.gu (2)
                    width: flick.width

                    GridLayout {
                        id: score_grid
                        columnSpacing: units.gu (1)
                        rowSpacing: units.gu (0.5)
                        columns: 2
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        Label {
                            id: ones_label
                            // TRANSLATORS: Label beside ones score (sum of dice showing 1)
                            text: i18n.tr ("Ones")
                        }
                        ScoreLabel {
                            id: ones_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside twos score (sum of dice showing 2)
                            text: i18n.tr ("Twos")
                        }
                        ScoreLabel {
                            id: twos_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside threes score (sum of dice showing 3)
                            text: i18n.tr ("Threes")
                        }
                        ScoreLabel {
                            id: threes_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside fours score (sum of dice showing 4)
                            text: i18n.tr ("Fours")
                        }
                        ScoreLabel {
                            id: fours_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside fives score (sum of dice showing 5)
                            text: i18n.tr ("Fives")
                        }
                        ScoreLabel {
                            id: fives_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside sixes score (sum of dice showing 6)
                            text: i18n.tr ("Sixes")
                        }
                        ScoreLabel {
                            id: sixes_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside bonus score (50 points if total of ones, twos, threes, fours, fives, sixes is at least 63)
                            text: i18n.tr ("Bonus")
                        }
                        ScoreLabel {
                            id: bonus_score_label
                            enabled: !main_page.rolling
                            actual_score: {
                                if ((ones_score_label.effective_score + twos_score_label.effective_score + threes_score_label.effective_score + fours_score_label.effective_score + fives_score_label.effective_score + sixes_score_label.effective_score) >= 63)
                                    if (mode)
                                        return 35
                                    else
                                        return 50
                                else
                                    return 0
                            }
                        }
                        Label {
                            // TRANSLATORS: Label beside chance score (sum of all dice)
                            text: i18n.tr ("Chance")
                        }
                        ScoreLabel {
                            id: chance_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                    }

                    GridLayout {
                        id: bonus_grid
                        columnSpacing: units.gu (1)
                        rowSpacing: units.gu (0.5)
                        columns: 2
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop

                        Label {
                            // TRANSLATORS: Label beside one pair score (sum of highest pair of dice)
                            visible: !mode
                            text: i18n.tr ("One Pair")
                        }
                        ScoreLabel {
                            id: one_pair_score_label
                            visible: !mode
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside two pair score (sum of two pair of dice)
                            visible: !mode
                            text: i18n.tr ("Two Pair")
                        }
                        ScoreLabel {
                            id: two_pair_score_label
                            visible: !mode
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside three of a kind score (sum of three dice with same value)
                            text: i18n.tr ("Three of a Kind")
                        }
                        ScoreLabel {
                            id: three_of_a_kind_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside four of a kind score (sum of four dice with same value)
                            text: i18n.tr ("Four of a Kind")
                        }
                        ScoreLabel {
                            id: four_of_a_kind_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside small straight score (1+2+3+4+5)
                            text: i18n.tr ("Small Straight")
                        }
                        ScoreLabel {
                            id: small_straight_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside large straight score (2+3+4+5+6)
                            text: i18n.tr ("Large Straight")
                        }
                        ScoreLabel {
                            id: large_straight_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside house score (three pair + two pair)
                            text: i18n.tr ("House")
                        }
                        ScoreLabel {
                            id: house_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                        Label {
                            // TRANSLATORS: Label beside Yatzy score (all dice same value)
                            text: i18n.tr ("Yatzy")
                        }
                        ScoreLabel {
                            id: yatzy_score_label
                            enabled: !main_page.rolling
                            onSelected: main_page.next_turn ()
                        }
                    }
                }
            }
            //}

            Label {
                id: total_label
                anchors.bottom: parent.bottom
                anchors.bottomMargin: units.gu (2)
                anchors.horizontalCenter: dice_row.horizontalCenter
                // TRANSLATORS: Label text for showing total score. %n is replaced with score value.
                text: i18n.tr ("Total: <b>%n</b>").replace ("%n", main_page.total_score)
            }
        }

        Page {
            id: about_page
            visible: false
            header: PageHeader {
                id: about_header
                // TRANSLATORS: Title of page with game instructions
                title: i18n.tr ("How to Play")

                trailingActionBar.actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("Info")
                        onTriggered: page_stack.push(Qt.resolvedUrl("About.qml"))
                    }
                ]
            }
            Flickable {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: units.gu (2)
                    top: about_header.bottom
                }
                contentHeight: how_to_play_label.height
                flickableDirection: Flickable.VerticalFlick

                Label {
                    id: how_to_play_label
                    width: parent.width
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                    // TRANSLATORS: Game instructions
                    text: i18n.tr ("<i>Yatzy</i> is a game where you roll five dice and try and make sets that score points. The goal is to get the highest score.<br/>\
<br/>\
The game is made up of 15 turns. A turn starts by rolling all five dice. You can re-roll some or all of the dice up to twice. Select dice to stop them from being re-rolled.<br/>\
<br/>\
Points are scored by summing the dice that make each set. The following sets are possible.<br/>\
<i>Ones</i>: Dice showing the number 1.<br/>\
<i>Twos</i>: Dice showing the number 2.<br/>\
<i>Threes</i>: Dice showing the number 3.<br/>\
<i>Fours</i>: Dice showing the number 4.<br/>\
<i>Fives</i>: Dice showing the number 5.<br/>\
<i>Sixes</i>: Dice showing the number 6.<br/>\
<i>Bonus</i>: If the above sets score at least 63 points (an average of three dice in each set) then a bonus of 50 points is given.<br/>\
<i>One Pair</i>: Two dice showing the same number (largest pair used).<br/>\
<i>Two Pairs</i>: Two pairs of dice.<br/>\
<i>Three of a Kind</i>: Three dice showing the same number.<br/>\
<i>Four of a Kind</i>: Four dice showing the same number.<br/>\
<i>Small Straight</i>: 1, 2, 3, 4, 5 in any order.<br/>\
<i>Long Straight</i>: 2, 3, 4, 5, 6 in any order.<br/>\
<i>House</i>: A pair and a three of a kind.<br/>\
<i>Yatzy</i>: All five dice showing the same number (worth 50 points).<br/>\
<i>Chance</i>: All dice used for scoring.<br/>\
<br/>\
You must choose a set for each turn. If the dice do not match the chosen set rules then zero is scored for that set.<br/>\
<br/>\
Have fun!<br/>")
                }
            }
        }

        Page {
            id: scores_page
            visible: false
            header: PageHeader {
                id: score_header
                // TRANSLATORS: Title of page showing high scores
                title: i18n.tr ("High Scores")
                trailingActionBar.actions: [
                    Action {
                        iconName: "reset"
                        onTriggered: PopupUtils.open (confirm_clear_scores_dialog)
                    }
                ]
            }

            GridLayout {
                anchors.top: score_header.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: units.gu (2)
                rowSpacing: units.gu (4)
                columns: 1

                ScoreEntry {
                    id: score_entry0
                    Layout.alignment: Qt.AlignHCenter
                }
                ScoreEntry {
                    id: score_entry1
                    Layout.alignment: Qt.AlignHCenter
                }
                ScoreEntry {
                    id: score_entry2
                    Layout.alignment: Qt.AlignHCenter
                }
                ScoreEntry {
                    id: score_entry3
                    Layout.alignment: Qt.AlignHCenter
                }
                ScoreEntry {
                    id: score_entry4
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
