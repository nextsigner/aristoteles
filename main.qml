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

    Settings {
        id: apps
        property int volumeValue: 100
        property string lastSource: ""
        property real lastPosition: 0
    }

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

            // --- Barra de progreso ---
            Rectangle {
                id: progressContainer
                width: parent.width
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                color: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        return "red";
                    } else if (mediaPlayer.playbackState === MediaPlayer.PausedState) {
                        return "green";
                    } else if (mediaPlayer.mediaStatus === MediaPlayer.LoadedMedia) {
                        return "yellow";
                    } else {
                        return "white";
                    }
                }

                property int porcentaje: (mediaPlayer.duration > 0)
                                         ? Math.floor((mediaPlayer.position / mediaPlayer.duration) * 100)
                                         : 0

                Text {
                    text: "Reproducido: %" + progressContainer.porcentaje
                    color: "black"
                    font.pixelSize: 50
                    anchors.centerIn: parent
                }

                Item {
                    id: progressIndicator
                    width: 1
                    height: parent.height
                    x: (mediaPlayer.duration > 0)
                       ? (mediaPlayer.position / mediaPlayer.duration) * (progressContainer.width - width)
                       : 0
                    Rectangle{
                        width: app.fs*0.1
                        height: parent.height
                        anchors.centerIn: parent
                        SequentialAnimation on color{
                            running: true
                            loops: Animation.Infinite

                            ColorAnimation {
                                from: "red"
                                to: "yellow"
                                duration: 200
                            }
                            ColorAnimation {
                                from: "yellow"
                                to: "red"
                                duration: 350
                            }
                        }
                    }
                }
            }
        }

        // --- Control de volumen ---
        Rectangle {
            id: volumeTrack
            width: 50
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "gray"
            z: 10

            Rectangle {
                id: volumeHandle
                width: parent.width
                height: 50
                color: "white"

                y: (1.0 - audioOutput.volume) * (volumeTrack.height - height)

                Text {
                    text: Math.round(audioOutput.volume * 100)
                    color: "black"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.centerIn: parent
                }
            }

            MouseArea {
                id: volumeMouseArea
                anchors.fill: parent

                function updateVolume(mouseY) {
                    var clampedY = Math.max(0, Math.min(mouseY, volumeTrack.height));
                    var newVolume = 1.0 - (clampedY / volumeTrack.height);
                    var finalVol = Math.max(0.0, Math.min(1.0, newVolume));

                    audioOutput.volume = finalVol;
                    apps.volumeValue = Math.round(finalVol * 100);
                }

                onPressed: (mouse) => updateVolume(mouse.y)
                onPositionChanged: (mouse) => updateVolume(mouse.y)
            }
        }

        MediaPlayer {
            id: mediaPlayer
            source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"

            // Removido autoPlay: true
            property bool positionRestored: false

            audioOutput: AudioOutput {
                id: audioOutput
                volume: apps.volumeValue / 100.0
            }

            // Guarda la posición solo si el archivo ya fue restaurado
            onPositionChanged: {
                if (positionRestored && position > 0) {
                    apps.lastPosition = position;
                }
            }

            onSourceChanged: {
                apps.lastSource = source.toString();
            }

            onMediaStatusChanged: {
                if (mediaStatus === MediaPlayer.LoadedMedia && !positionRestored) {
                    positionRestored = true;

                    // Si coincide la URL y hay una posición guardada previa
                    if (apps.lastSource === source.toString() && apps.lastPosition > 0) {
                        mediaPlayer.position = Math.min(apps.lastPosition, mediaPlayer.duration);
                    }

                    // Iniciamos la reproducción manualmente tras aplicar la posición
                    mediaPlayer.play();
                }
            }
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
                                mediaPlayer.position = Math.min(newPosition, mediaPlayer.duration);
                            } else {
                                newPosition -= jumpTime;
                                mediaPlayer.position = Math.max(newPosition, 0);
                            }
                        }
        }
    }

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
