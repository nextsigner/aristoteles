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
    //visibility: 'FullScreen'
    title: "Aristoteles"
    color: 'black'
    property int fs: width*0.035
    property var json


    Settings {
        id: apps
        property int volumeValue: 100
    }

    Item {
        id: xApp
        width: parent.width-app.fs
        height: parent.height-app.fs*6
        anchors.centerIn: parent
        //anchors.horizontalCenter: parent.horizontalCenter
        //anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            id: touchArea
            //anchors.fill: parent
            width: app.width-volumeTrack.width
            height: parent.height
            anchors.right: parent.right

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
        Column {
            spacing: app.fs*2
            //anchors.centerIn: parent
            //anchors.verticalCenter: parent.verticalCenter
            //anchors.verticalCenterOffset: 0-progressContainer.height//-markersList.height
            anchors.top: parent.top
            anchors.topMargin: app.fs*8
            Text {
                text: "" + getMsToString(mediaPlayer.position) + '\n'+getMsToString(mediaPlayer.duration)
                width: progressContainer.width
                color: 'white'
                font.pixelSize: app.fs*2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "URL: " + mediaPlayer.source
                width: progressContainer.width
                color: 'white'
                font.pixelSize: app.fs
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: labelTit
                width: progressContainer.width
                color: 'white'
                font.pixelSize: app.fs*2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // --- Control de volumen vertical (Lateral izquierdo) ---
        Rectangle {
            id: volumeTrack
            width: app.fs*3
            height: parent.height-app.fs*2
            border.width: 2
            border.color: 'white'
            color: "gray"
            z: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: volumeHandle
                width: parent.width
                height: width
                color: "white"

                y: (1.0 - audioOutput.volume) * (volumeTrack.height - height)

                Text {
                    text: Math.round(audioOutput.volume * 100)
                    color: "black"
                    font.pixelSize: parent.width*0.5
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

        Column{
            spacing: app.fs
            anchors.bottom: parent.bottom
            anchors.bottomMargin: app.fs*3
            Rectangle {
                id: progressContainer
                width: xApp.width-volumeTrack.width
                height: app.fs*4
                border.width: 1
                border.color: 'white'
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
                    //text: "Reproducido: %" + progressContainer.porcentaje
                    text: {
                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                            return "Reproduciendo: %" + progressContainer.porcentaje;
                        } else if (mediaPlayer.playbackState === MediaPlayer.PausedState) {
                            return "Pausado: %" + progressContainer.porcentaje;
                        } else if (mediaPlayer.mediaStatus === MediaPlayer.LoadedMedia) {
                            return "Preparado: %100";
                        } else {
                            return "?";
                        }
                    }
                    color: {
                        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                            return "white";
                        } else if (mediaPlayer.playbackState === MediaPlayer.PausedState) {
                            return "white";
                        } else if (mediaPlayer.mediaStatus === MediaPlayer.LoadedMedia) {
                            return "black";
                        } else {
                            return "black";
                        }
                    }
                    font.pixelSize: parent.height*0.7
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

            // --- ListView Horizontal Inferior ---
            ListView {
                id: markersList
                width: parent.width
                height: app.height*0.3
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                z: 5

                model: lm
                delegate: Rectangle {
                    width: markersList.width
                    height: markersList.height
                    color: "#222222"
                    border.color: "white"
                    border.width: 1
                    MouseArea{
                        anchors.fill: parent
                        onDoubleClicked: mediaPlayer.position = posicion
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: titulo
                            width: parent.parent.width-app.fs
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font.pixelSize: app.fs*1.5
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: descripcion
                            width: parent.parent.width-app.fs
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font.pixelSize: app.fs
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            //text: "Posición: " + (posicion / 1000) + " seg (" + posicion + " ms)"
                            text: "Posición: " + getMsToString((posicion)) + " de " + getMsToString(mediaPlayer.duration)
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
                ListModel{
                    id: lm
                    function addItem(t, d, ms){
                        return{
                            titulo: t,
                            descripcion: d,
                            posicion: ms
                        }

                    }
                }
            }
        }
        MediaPlayer {
            id: mediaPlayer
            //source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
            audioOutput: AudioOutput {
                id: audioOutput
                volume: apps.volumeValue / 100.0
            }
            autoPlay: true
        }

        Rectangle{
            id: xLog
            color: 'black'
            anchors.fill: parent
            visible: false
            Text{
                id: log
                width: parent.width-app.fs
                color: 'white'
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                anchors.centerIn: parent
            }
        }
    }
    Component.onCompleted: {
        let j={}
        j.items=[]
        let item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
        item.tit="Enrique Pedro Mesa\nARISTÖTELES 1/5"
        item.marcs=[]
        let marcs=[]

        let marc={}
        marc.titulo="Introducción"
        marc.des="Física y Metafísica Aristotélica. Mundo sublunar y supralunar, elementos y ether."
        marc.ms=0
        marcs.push(marc)
        //item.marcs.push(marcs)

        marc={}
        marc.titulo="Teoría Hilemórficas"
        marc.des="Forma y materia, sustancia primera y sustancia segunda."
        marc.ms=701000
        marcs.push(marc)
        //item.marcs.push(marcs)

        marc={}
        marc.titulo="Teleología y Cambio"
        marc.des="Potencia y acto."
        marc.ms=1471000
        marcs.push(marc)
        //item.marcs.push(marcs)

        marc={}
        marc.titulo="Teleología y Cambio"
        marc.des="Potencia y acto."
        marc.ms=1471000
        marcs.push(marc)
        //item.marcs.push(marcs)

        marc={}
        marc.titulo="Teoría de las 4 causas"
        marc.des="Formal, Material, Eficiente y Final"
        marc.ms=2081600
        marcs.push(marc)

        item.marcs.push(marcs)
        j.items.push(item)

        app.json=j

        //log.text=JSON.stringify(app.json, null, 2)
        //return

        loadData(0)

        /*labelTit.text="Enrique Pedro Mesa\nARISTÖTELES 1/5"
        lm.append(lm.addItem("Introducción", "Física y Metafísica Aristotélica. Mundo sublunar y supralunar, elementos y ether.",0))
        lm.append(lm.addItem("Teoría Hilemórfica", "Forma y materia, sustancia primera y sustancia segunda.", 701000))
        lm.append(lm.addItem("Teleología y Cambio", "Potencia y acto.", 1471000))
        lm.append(lm.addItem("Teoría de las 4 causas", "Formal, Material, Eficiente y Final", 2081600))*/
    }

    Shortcut {
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
    function loadData(index){
        let item=app.json.items[index]
        labelTit.text=item.tit
        mediaPlayer.source=item.url
        xLog.visible=true
        log.text=JSON.stringify(item, null, 2)
        return
        for(var i=0;i<item.marcs.length;i++){
            let marc=item.marcs[i]
            log.text=JSON.stringify(marc, null, 2)
            lm.append(lm.addItem(marc.titulo, marc.des,marc.ms))
        }
    }
    function getMsToString(ms) {
        if (isNaN(ms) || ms < 0) {
            return "00:00:00";
        }

        // Convertir milisegundos a segundos totales
        var totalSeconds = Math.floor(ms / 1000);

        // Calcular horas, minutos y segundos restables
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds % 3600) / 60);
        var seconds = totalSeconds % 60;

        // Formatear a 2 dígitos con cero inicial
        var hStr = hours.toString().padStart(2, '0');
        var mStr = minutes.toString().padStart(2, '0');
        var sStr = seconds.toString().padStart(2, '0');

        return hStr + ":" + mStr + ":" + sStr;
    }
}
