import QtQuick
import QtQuick.Controls
import QtCore
import unik.Unik 1.0
import QtMultimedia

Window {
    id: app
    width: Qt.platform.os==='android'?640:608
    height: Qt.platform.os==='android'?480:1080
    visible: true
    title: "Aristoteles"
    color: '#ff8833'
    property int fs: width*0.035
    // Loader {
    //     id: mediaLoader
    //     anchors.fill: parent
    //     sourceComponent: multimediaComponent
    //     asynchronous: true
    // }

    // Component {
    //     id: multimediaComponent
    //     Item {
    //         anchors.fill: parent

    //         MediaPlayer {
    //             id: mediaPlayer
    //             source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
    //             audioOutput: AudioOutput {
    //                 id: audioOutput
    //                 volume: 1.0
    //             }
    //             autoPlay: true
    //         }

    //         MouseArea {
    //             id: touchArea
    //             anchors.fill: parent

    //             property real startX: 0

    //             onPressed: (mouse) => {
    //                 startX = mouse.x;
    //             }

    //             onReleased: (mouse) => {
    //                 var deltaX = mouse.x - startX;
    //                 var screenWidth = mainWindow.width;
    //                 var ratio = Math.abs(deltaX) / screenWidth;

    //                 if (ratio < 0.05) {
    //                     if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
    //                         mediaPlayer.pause();
    //                     } else {
    //                         mediaPlayer.play();
    //                     }
    //                     return;
    //                 }

    //                 var minJump = 10 * 1000;
    //                 var maxJump = 5 * 60 * 1000;

    //                 var jumpTime = minJump + ratio * (maxJump - minJump);
    //                 if (jumpTime > maxJump) jumpTime = maxJump;

    //                 var newPosition = mediaPlayer.position;

    //                 if (deltaX > 0) {
    //                     newPosition += jumpTime;
    //                     mediaPlayer.seek(Math.min(newPosition, mediaPlayer.duration));
    //                 } else {
    //                     newPosition -= jumpTime;
    //                     mediaPlayer.seek(Math.max(newPosition, 0));
    //                 }
    //             }
    //         }
    //     }

    // }
    Item {
        anchors.fill: parent

        MediaPlayer {
            id: mediaPlayer
            source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
            audioOutput: AudioOutput {
                id: audioOutput
                volume: 1.0
            }
            autoPlay: true
        }

        MouseArea {
            id: touchArea
            anchors.fill: parent

            property real startX: 0

            onPressed: (mouse) => {
                startX = mouse.x;
            }

            onReleased: (mouse) => {
                var deltaX = mouse.x - startX;
                var screenWidth = app.width;
                var ratio = Math.abs(deltaX) / screenWidth;

                if (ratio < 0.05) {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause();
                    } else {
                        mediaPlayer.play();
                    }
                    return;
                }

                var minJump = 10 * 1000;
                var maxJump = 5 * 60 * 1000;

                var jumpTime = minJump + ratio * (maxJump - minJump);
                if (jumpTime > maxJump) jumpTime = maxJump;

                var newPosition = mediaPlayer.position;

                if (deltaX > 0) {
                    newPosition += jumpTime;
                    mediaPlayer.seek(Math.min(newPosition, mediaPlayer.duration));
                } else {
                    newPosition -= jumpTime;
                    mediaPlayer.seek(Math.max(newPosition, 0));
                }
            }
        }
    }


    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
