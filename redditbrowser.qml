import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.XmlListModel 2.0
import QtWebKit 3.0

ApplicationWindow {
    width: 800
    height: 600
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        resizing: true
        handleDelegate: Rectangle { width: 1; color: 'black' }
        ColumnLayout {
            id: sidebarPane
            width: 300
            RowLayout {
                Layout.fillWidth: true
                anchors.bottomMargin: 10
                Text {
                    text: "subreddit: "
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: subredditNameEdit.implicitHeight
                    color: "white"
                    border.width: 1
                    border.color: "grey"
                    radius: 3
                    TextEdit {
                        id: subredditNameEdit
                        anchors.fill: parent
                        Layout.fillWidth: true
                        Keys.onReturnPressed: subredditListModel.subredditName = text
                    }
                }
            }

            ListView {
                id: linkSelector
                model: subredditListModel
                Layout.fillHeight: true
                Layout.fillWidth: true
                highlight: Rectangle { color: "lightsteelblue" }
                focus: true
                spacing: 5
                delegate: Text {
                    property string link: model.url
                    property string comments: model.commentsUrl
                    width: parent.width
                    text: model.title
                    wrapMode: Text.Wrap
                    MouseArea {
                        anchors.fill: parent
                        onClicked: linkSelector.currentIndex = index
                    }
                }
            }
            ListModel {
                id: subredditListModel
                property string subredditName
                onSubredditNameChanged: {
                    var xhr = new XMLHttpRequest()
                    xhr.open("GET", "http://reddit.com/r/" + subredditListModel.subredditName + "/hot.json", true);
                    xhr.onreadystatechange = function () {
                        if (xhr.readyState == xhr.DONE) {
                            subredditListModel.clear();
                            var obj = JSON.parse(xhr.responseText);
                            for (var idx in obj.data.children) {
                                var child = obj.data.children[idx].data;
                                subredditListModel.append({
                                    "title":child.title,
                                    "url":child.url,
                                    "commentsUrl": 'http://reddit.com' + child.permalink
                                });
                            }
                        }
                    };
                    xhr.send();
                }
            }
        }
        SplitView {
            id: browserPane
            Layout.minimumWidth: 500
            orientation: Qt.Vertical
            handleDelegate: Rectangle {height: 1; color: "black"}
            resizing: true
            WebView {
                id: commentView
                Layout.minimumHeight: parent.height / 4.0
                Layout.fillWidth: true
                url: linkSelector.currentItem ? linkSelector.currentItem.comments : ""
            }
            WebView {
                id: webView
                Layout.minimumHeight: parent.height / 4.0
                Layout.fillWidth: true
                url: linkSelector.currentItem ? linkSelector.currentItem.link : ""
            }
        }
    }
}

