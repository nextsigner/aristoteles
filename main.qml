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
            // --- Barra de progreso con color dinámico según estado ---
            Rectangle {
                id: progressContainer
                width: parent.width
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter

                color: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        return "red";       // Rojo si está reproduciendo
                    } else if (mediaPlayer.playbackState === MediaPlayer.PausedState) {
                        return "green";     // Verde si está pausado
                    } else if (mediaPlayer.mediaStatus === MediaPlayer.LoadedMedia) {
                        return "yellow";    // Amarillo si está Listo (LoadedMedia equivale a Ready)
                    } else {
                        return "white";     // Blanco si está detenido o sin cargar
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

        // --- Control de volumen vertical (Lateral izquierdo) ---
        Rectangle {
            id: volumeTrack
            width: 50
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "gray"
            z: 10 // Asegura que quede por encima de otros elementos e intercepte el ratón/tacto

            // Deslizador blanco
            Rectangle {
                id: volumeHandle
                width: parent.width
                height: 50
                color: "white"

                // Mapea el volumen (0.0 a 1.0) a la coordenada Y (1.0 arriba -> 0.0 abajo)
                y: (1.0 - audioOutput.volume) * (volumeTrack.height - height)

                Text {
                    text: Math.round(audioOutput.volume * 100)
                    color: "black"
                    font.pixelSize: 18
                    font.bold: true
                    anchors.centerIn: parent
                }
            }

            // Área de arrastre/interacción para el volumen
            MouseArea {
                id: volumeMouseArea
                anchors.fill: parent

                function updateVolume(mouseY) {
                    // Limita el punto Y dentro de los bordes del riel
                    var clampedY = Math.max(0, Math.min(mouseY, volumeTrack.height));
                    // Calcula la proporción invertida (0 abajo, 1 arriba)
                    var newVolume = 1.0 - (clampedY / volumeTrack.height);
                    audioOutput.volume = Math.max(0.0, Math.min(1.0, newVolume));
                }

                onPressed: (mouse) => updateVolume(mouse.y)
                onPositionChanged: (mouse) => updateVolume(mouse.y)
            }
        }

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
