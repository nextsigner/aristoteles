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
    }

    Item {
        id: xApp
        anchors.fill: parent

        Column {
            spacing: app.fs*2
            anchors.centerIn: parent

            Text {
                text: "V1\n" + mediaPlayer.position + '\n'
                width: app.width
                color: 'white'
                font.pixelSize: app.fs
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "URL: " + mediaPlayer.source
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
                    Rectangle {
                        width: app.fs*0.1
                        height: parent.height
                        anchors.centerIn: parent
                        SequentialAnimation on color {
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

        // --- ListView Horizontal Inferior ---
        ListView {
            id: markersList
            width: parent.width
            height: 300
            anchors.bottom: parent.bottom
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            z: 5

            model: ListModel {
                ListElement { titulo: "Introducción"; descripcion: "Física y Metafísica Aristotélica. Mundo sublunar y supralunar, elementos y ether."; posicion: 0 }
                ListElement { titulo: "Física"; descripcion: "Teoría Hilemórfica"; posicion: 655000 }  // 30 seg
                ListElement { descripcion: "Capítulo 2: Conclusión"; posicion: 805000 }     // 60 seg
                /*ListElement { titulo: "Introducción"; descripcion: "Física y Metafísica Aristotélica. Mundo sublunar y supralunar, elementos y ether."; posicion: 0 }
                ListElement { titulo: "Teoría Hilemórfica"; descripcion: "Forma y materia, sustancia primera y sustancia segunda."; posicion: 701000 }  -
                ListElement { titulo: "Teleología"; descripcion: "Cambio, potencia y acto."; posicion: 1473000 }
                ListElement { titulo: "Teoría de las 4 causas"; descripcion: "Escuchando..."; posicion: 1973000 }*/
            }

            delegate: Rectangle {
                width: markersList.width
                height: markersList.height
                color: "#222222"
                border.color: "white"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: descripcion
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Posición: " + (posicion / 1000) + " seg (" + posicion + " ms)"
                        color: "#AAAAAA"
                        font.pixelSize: 18
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Al deslizar y cambiar el elemento seleccionado, actualiza la posición del audio
            onCurrentIndexChanged: {
                if (currentItem && mediaPlayer.duration > 0) {
                    var targetPos = model.get(currentIndex).posicion;
                    mediaPlayer.position = Math.min(targetPos, mediaPlayer.duration);
                }
            }
        }

        MediaPlayer {
            id: mediaPlayer
            source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
            audioOutput: AudioOutput {
                id: audioOutput
                volume: apps.volumeValue / 100.0
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

    Shortcut {
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
