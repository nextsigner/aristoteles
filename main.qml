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
    color: 'black'
    property int fs: width*0.035

    Item {
        id: xApp
        anchors.fill: parent

        Column{
            spacing: app.fs*2
            anchors.centerIn: parent
            Text{
                text: "V1\n"+mediaPlayer.position+'\n'
                width: app.width
                color: 'white'
                font.pixelSize: app.fs
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text{
                text: "URL: "+mediaPlayer.source
                width: app.width
                color: 'white'
                font.pixelSize: app.fs
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // --- Barra de progreso (Slider no interactivo) ---
        Rectangle {
            id: progressContainer
            width: parent.width
            height: 100
            color: "white"
            anchors.centerIn: parent

            Rectangle {
                id: progressIndicator
                width: 1
                height: parent.height
                color: "black"
                // Calcula la posición 'x' en base a la proporción transcurrida del audio
                x: (mediaPlayer.duration > 0)
                   ? (mediaPlayer.position / mediaPlayer.duration) * (progressContainer.width - width)
                   : 0
            }
        }
        // ------------------------------------------------

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
                                mediaPlayer.position = Math.min(newPosition, mediaPlayer.duration)
                            } else {
                                newPosition -= jumpTime;
                                mediaPlayer.position = Math.max(newPosition, 0)
                            }
                        }
        }
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
