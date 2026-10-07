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
    property bool appRotated: Qt.platform.os==='android'?Screen.width>Screen.height:Screen.width<Screen.height
    property int fs: !appRotated?width*0.035:height*0.035
    property var json


    Settings {
        id: apps
        property int volumeValue: 100
    }
    Item {
        Unik {
            id: unikObj
            property string cProject: ''

            onDownloadProgress: function(bytesReceived, bytesTotal) {
                let msg=""
                if (bytesTotal > 0) {
                    let percent = (bytesReceived / bytesTotal) * 100;
                    msg="Progreso: " + percent.toFixed(2) + "% (" + bytesReceived + " / " + bytesTotal + " bytes)"
                    console.log(msg);
                    //statusText.text=msg
                    progressBar.value = bytesReceived / bytesTotal;
                } else {
                    msg="Descargando... Bytes recibidos: " + bytesReceived
                    console.log(msg);
                    //statusText.text=msg
                }
            }
            onDownloadFinished: function(success, filePath) {
                let msg=""
                if (success) {
                    console.log("¡Archivo descargado en la ruta temporal!: " + filePath);
                } else {
                    msg="Error al descargar el archivo ZIP."
                    console.log(msg);
                }
            }
        }


    }

    Item {
        id: xApp
        width: !app.appRotated?parent.width-app.fs:parent.height-app.fs
        height: !app.appRotated?parent.height-app.fs*6:parent.width-app.fs*6
        rotation: !app.appRotated?0:90
        anchors.centerIn: parent
        MouseArea {
            id: touchArea
            //anchors.fill: parent
            width: xApp.width-volumeTrack.width
            height: parent.height
            anchors.right: parent.right

            property real startX: 0

            onPressed: (mouse) => {
                           startX = mouse.x;
                       }

            onReleased: (mouse) => {
                            var deltaX = mouse.x - startX;
                            var screenWidth = xApp.width;
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
        /*Column {
            spacing: app.fs*2
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
        }*/

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
            anchors.verticalCenter: parent.verticalCenter
            ListView {
                id: lvAudios
                width: xApp.width-volumeTrack.width
                height: xApp.height*0.2
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                z: 5
                rotation: -180

                model: lmAudios
                delegate: Rectangle {
                    width: lvAudios.width
                    height: lvAudios.height
                    color: "#222222"
                    border.color: "white"
                    border.width: 1
                    clip: true
                    rotation: -180
                    MouseArea{
                        anchors.fill: parent
                        //onDoubleClicked: mediaPlayer.position = posicion
                    }
                    Column {
                        anchors.centerIn: parent
                        spacing: app.fs*0.5

                        Text {
                            text: titulo
                            width: parent.parent.width-app.fs
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font.pixelSize: app.fs*2
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: descripcion
                            width: parent.parent.width-app.fs
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font.pixelSize: app.fs*1.2
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "URL: " + url
                            color: "#AAAAAA"
                            font.pixelSize: 18
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: false
                        }
                    }
                }

                // Al deslizar y cambiar el elemento seleccionado, actualiza la posición del audio
                onCurrentIndexChanged: {
                    loadData(currentIndex)
                }
                ListModel{
                    id: lmAudios
                    function addItem(t, d, u){
                        return{
                            titulo: t,
                            descripcion: d,
                            url: u
                        }

                    }
                }
            }
            Item{
                width: xApp.width
                height: volumeTrack.height-lvAudios.height-markersList.height-progressContainer.height-progressBar.height-parent.spacing*3
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "" + getMsToString(mediaPlayer.position) + '\n'+getMsToString(mediaPlayer.duration)
                    width: progressContainer.width
                    color: 'white'
                    font.pixelSize: app.fs*4
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                }
            }
            Rectangle {
                id: progressContainer
                width: xApp.width-volumeTrack.width
                height: app.fs*4
                border.width: 1
                border.color: 'white'
                //anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left

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
                    font.pixelSize: parent.height*0.5
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
            ProgressBar {
                id: progressBar
                width: xApp.width
                anchors.horizontalCenter: parent.horizontalCenter
                from: 0
                to: 1
                value: 0
                Rectangle{
                    color: 'transparent'
                    border.width: 2
                    border.color: apps.fontColor
                    anchors.fill: parent
                    Text{
                        text:  '%'+progressBar.value
                        font.pixelSize: app.fs*0.5
                        color: apps.fontColor
                        anchors.centerIn: parent
                        Rectangle{
                            width: parent.contentWidth+4
                            height: parent.contentHeight
                            color: apps.backgroundColor
                            anchors.centerIn: parent
                            z: parent.z-1
                        }
                    }
                }
            }
            // --- ListView Horizontal Inferior ---
            ListView {
                id: markersList
                width: xApp.width-volumeTrack.width
                height: xApp.height*0.3
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                z: 5
                rotation: -180

                model: lm
                delegate: Rectangle {
                    width: markersList.width
                    height: markersList.height
                    color: "#222222"
                    border.color: "white"
                    border.width: 1
                    clip: true
                    rotation: -180
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
                            font.pixelSize: app.fs*2
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: descripcion
                            width: parent.parent.width-app.fs
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font.pixelSize: app.fs*1.2
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
            MouseArea{
                anchors.fill: parent
                onClicked: xLog.visible=false
            }
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
        item.tit="Enrique Pedro Mesa\nARISTÓTELES 1/6"
        item.des="Se introduce a los conceptos de física y metafísica y comienza a explicar la física aristotélica."
        let marcs=[]

        let marc={}
        marc.titulo="Introducción a la física"
        marc.des="Separamos la Física y la Metafísica Aristotélica. Mundo sublunar y supralunar, elementos y ether."
        marc.ms=0
        marcs.push(marc)

        marc={}
        marc.titulo="Teoría Hilemórficas"
        marc.des="Forma y materia, sustancia primera y sustancia segunda."
        marc.ms=701000
        marcs.push(marc)

        marc={}
        marc.titulo="Teleología y Cambio"
        marc.des="Potencia y acto."
        marc.ms=1471000
        marcs.push(marc)

        marc={}
        marc.titulo="Teoría de las 4 causas"
        marc.des="Formal, Material, Eficiente y Final"
        marc.ms=2081600
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 41, 5)
        marcs.push(marc)

        item.marcs=marcs
        j.items.push(item)

        //Item 2
        item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/2.wav"
        item.tit="Enrique Pedro Mesa\nARISTÓTELES 2/6"
        item.des="Comienza a explicar metafísica aristotélica, axiomas, categorías (principios universales que rigen la realidad física)"
        marcs=[]

        marc={}
        marc.titulo="Introducción a la METAFÍSICA"
        marc.des="¿Qué es la Metafísica? Estudia la realidad en cuanto tal."
        marc.ms=0
        marcs.push(marc)

        marc={}
        marc.titulo="El ENTE"
        marc.des="¿Qué es un Ente? El verbo SER. Las cosas son en cuanto que SON."
        marc.ms=getHmsToMs(0, 7, 8)
        marcs.push(marc)

        marc={}
        marc.titulo="AXIOMAS Y CATAGORÍAS"
        marc.des="¿Qué son los Axiomas y Categorías? Principios universales e indemostrables que rigen lo real."
        marc.ms=getHmsToMs(0, 9, 33)
        marcs.push(marc)

        marc={}
        marc.titulo="AXIOMAS"
        marc.des="Se explican algunos axiomas. Principio de identidad y de NO contradicción."
        marc.ms=getHmsToMs(0, 11, 48)
        marcs.push(marc)

        marc={}
        marc.titulo="CATEGORÍAS"
        marc.des="Se explican las categorías. Lo que puedo predicar de cualquier cosa. Por ejemplo tiempo y espacio."
        marc.ms=getHmsToMs(0, 17, 10)
        marcs.push(marc)

        marc={}
        marc.titulo="EL PRIMER MOTOR INMOVIL"
        marc.des="El fundamento del primer movimiento. La idea del infinito."
        marc.ms=getHmsToMs(0, 19, 29)
        marcs.push(marc)

        marc={}
        marc.titulo="LA PERFECCIÓN DEL PRIMER MOTOR"
        marc.des="La idea de bien. Teleologica de atraidos por la perfección, ACTO PURO SIN POTENCIA que solo se piensa a si mismo."
        marc.ms=getHmsToMs(0, 32, 14)
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 37, 14)
        marcs.push(marc)

        item.marcs=marcs
        j.items.push(item)

        //Item 3
        item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/3.wav"
        item.tit="Enrique Pedro Mesa\nARISTOTELES 3/6"
        item.des="Epistemología. Conocimiento Aristotélico."
        marcs=[]

        marc={}
        marc.titulo="Introducción"
        marc.des="Nos ponemos en contexto. ¿Cómo se conoce? Reminiscencia Platónica."
        marc.ms=getHmsToMs(0, 0, 0)
        marcs.push(marc)

        marc={}
        marc.titulo="La inducción"
        marc.des="Comienza con los sentidos. El proceso del conocimiento que va desde los particular a lo general. Ejemplo de la madre, el niño y el perro."
        marc.ms=getHmsToMs(0, 1, 45)
        marcs.push(marc)

        marc={}
        marc.titulo="Introducción: IMAGINACIÓN Y ENTENDIMIENTO"
        marc.des="Introducción a la imaginación y el entendimiento (agente universal que abstrae y paciente individual que posibilita juicio)."
        marc.ms=getHmsToMs(0, 7, 50)
        marcs.push(marc)

        marc={}
        marc.titulo="Explicación: IMAGINACIÓN Y ENTENDIMIENTO"
        marc.des="Se explica la imaginación y el entendimiento. Abstracción y se descubre la esencia."
        marc.ms=getHmsToMs(0, 9, 42)
        marcs.push(marc)

        marc={}
        marc.titulo="ENTENDIMIENTOS AGENTE Y PACIENTE"
        marc.des="¿Porqué el entendimiento agente es universal y el entendimiento paciente es individual?"
        marc.ms=getHmsToMs(0, 13, 59)
        marcs.push(marc)

        marc={}
        marc.titulo="LA LÓGICA"
        marc.des="¿Qué sería la lógica? Aristóteles ha creado la lógica. Es un MÉTODO para agumentación rigurosa y coherente. Se ocupa de la validez no del contenido. SILOGISMO y FALACIA."
        marc.ms=getHmsToMs(0, 15, 59)
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 23, 45)

        item.marcs=marcs
        j.items.push(item)

        //Item 4
        item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/4.wav"
        item.tit="Enrique Pedro Mesa\nARISTOTELES 4/6"
        item.des="Antropología Aristotélica."
        marcs=[]

        marc={}
        marc.titulo="Introducción"
        marc.des="¿Qué es, cómo es un ser humano?. Se repasa el HILEMORFISMO. Cuerpo y alma son UNO (unión sustanciál conforman la sustancia primera)."
        marc.ms=getHmsToMs(0, 0, 0)
        marcs.push(marc)

        marc={}
        marc.titulo="Sobre el ALMA"
        marc.des="El alma es mortal. Metáfora: El alma como energía de una batería. El entendimiento AGENTE es INMORTAL"
        marc.ms=getHmsToMs(0, 4, 4)
        marcs.push(marc)

        marc={}
        marc.titulo="Las 3 FACULTADES DEL ALMA"
        marc.des="Vegetativa, Sensitiva y Intelectiva."
        marc.ms=getHmsToMs(0, 6, 4)
        marcs.push(marc)

        marc={}
        marc.titulo="La FACULTAD VEGETATIVA"
        marc.des="ATENCIÓN! Aquí se equivoca al decir SENSITIVA al comienzo. La capacidad de alimentarse y estar vivos."
        marc.ms=getHmsToMs(0, 8, 14)
        marcs.push(marc)

        marc={}
        marc.titulo="La FACULTAD SENSITIVA"
        marc.des="La capacidad de sentir de los animales y humanos que no tienen los vegetales. La capacidad de recibir estímolos nerviosos y desarrollarlos."
        marc.ms=getHmsToMs(0, 9, 22)
        marcs.push(marc)

        marc={}
        marc.titulo="La FACULTAD INTELECTIVA"
        marc.des="La capacidad del pensamiento racional. Intelección, capacidad superior, esencial y distintiva. Solo exclusiva de los seres humanos."
        marc.ms=getHmsToMs(0, 12, 12)
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 15, 13)
        marcs.push(marc)

        item.marcs=marcs
        j.items.push(item)

        //Item 5
        item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/5.wav"
        item.tit="Enrique Pedro Mesa\nARISTOTELES 5/6"
        item.des="Ética Aristotélica."
        marcs=[]

        marc={}
        marc.titulo="Introducción"
        marc.des="Ética Teleológica o basada en ella. El DEMONISMO. Desarrollar la esencia para ALCANZAR LA FELICIDAD propia del ser humano."
        marc.ms=getHmsToMs(0, 0, 0)
        marcs.push(marc)

        marc={}
        marc.titulo="La FELICIDAD de la VIDA CONTEMPLATIVA"
        marc.des="¿Cuál es esta felicidad?. PENSAR. Facultad intelectiva. La vida contemplativa propia de los seres humanos."
        marc.ms=getHmsToMs(0, 2, 35)
        marcs.push(marc)

        marc={}
        marc.titulo="PENSAR ¿EN QUÉ?"
        marc.des="Lo que nos hace más felices es pensar sobre lo más abstracto, sobre el conocimiento de los seres y el primer motor inmóvil. FILOSOFAR."
        marc.ms=getHmsToMs(0, 7, 22)
        marcs.push(marc)

        marc={}
        marc.titulo="VIRTUDES DIANOÉTICAS"
        marc.des="Exclusiva de la divinidad. Son las que tienen que ver con el entendimiento, las facultades intelectuales, la sabiduría, reflexxión, comprensión, la argumentación..."
        marc.ms=getHmsToMs(0, 10, 5)
        marcs.push(marc)

        marc={}
        marc.titulo="VIDA CONTEMPLATIVA LIMITADA"
        marc.des="Imposible de cumplir permanentemente porque tenemos necesidades corporales y sociales."
        marc.ms=getHmsToMs(0, 11, 33)
        marcs.push(marc)

        marc={}
        marc.titulo="¿QUIÉN SERÁ SIEMPRE FELIZ?"
        marc.des="La absoluta felicidad la tendrá aquél que no tenga ningúna necesidad corporal ni social, ninguna facultad vegetativa ni sensitiva. El primer motor inmovil."
        marc.ms=getHmsToMs(0, 13, 13)
        marcs.push(marc)

        marc={}
        marc.titulo="VIRTUDES ÉTICAS/PRÁCTICAS"
        marc.des="Las que realizamos en la vida cotidiana en relación con los demás, virtudes con características humanas. Permiten organizar la vida para ganar tiempo para la intelección."
        marc.ms=getHmsToMs(0, 14, 28)
        marcs.push(marc)

        marc={}
        marc.titulo="PRUDENCIA: VIRTUD ÉTICA TÉRMINO MEDIO"
        marc.des="Un hábito que va a consistir que a travez de la prudencia elija entre 2 extremos el término medio, extremo por defecto y otro por exceso."
        marc.ms=getHmsToMs(0, 24, 47)
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 39, 4)
        marcs.push(marc)

        item.marcs=marcs
        j.items.push(item)

        //Item 6
        item={}
        item.url="https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/6.wav"
        item.tit="Enrique Pedro Mesa\nARISTOTELES 6/6"
        item.des="Política Aristotélica."
        marcs=[]

        marc={}
        marc.titulo="Introducción"
        marc.des="ZOON POLITIKÓN. Ser humano cono SER SOCIAL POR NATURALEZA."
        marc.ms=getHmsToMs(0, 0, 0)
        marcs.push(marc)

        marc={}
        marc.titulo="EL LOGOS"
        marc.des="El ser humano desea el LOGOS. La RACIANALIDAD, PENSAMIENTO RACIONAL, COMUNICACCIÓN Y LENGUAJE."
        marc.ms=getHmsToMs(0, 2, 12)
        marcs.push(marc)

        marc={}
        marc.titulo="POLÍTICA REGIDA POR LA TELEOLOGÍA"
        marc.des="Finalidad o meta, LA POLIS, el fin último de todo proceso social. Conformada por familia, tribu y aldeas."
        marc.ms=getHmsToMs(0, 5, 27)
        marcs.push(marc)

        marc={}
        marc.titulo="LA FELICIDAD COMO FIN"
        marc.des="Permitiendo que en dicha sociedad se desarrolle la VIRTUD ÉTICA O PRÁCITCA, tendría más tiempo para contemplar la vida y ser feliz."
        marc.ms=getHmsToMs(0, 7, 54)
        marcs.push(marc)

        marc={}
        marc.titulo="EL LEGISLADOR - TEORÍA Y PRÁCTICA"
        marc.des="El legislador no tiene que se solo un terórico, debe tener conocimientos prácticos regidos por LA PRUDENCIA, INTELIGENCIA PRÁCTICA."
        marc.ms=getHmsToMs(0, 9, 23)
        marcs.push(marc)

        marc={}
        marc.titulo="UN BUEN GOBIERNO"
        marc.des="El que junta la teoría y la práctica y busca el BIEN COMÚN y posibilitar que cada individuo pueda desarrollar su VIRTUD INDIVIDUAL."
        marc.ms=getHmsToMs(0, 11, 43)
        marcs.push(marc)

        marc={}
        marc.titulo="Resume CLAVE"
        marc.des="Se resume los dicho anteriormente."
        marc.ms=getHmsToMs(0, 13, 10)
        marcs.push(marc)

        marc={}
        marc.titulo="3 TIPOS DE GOBIERNOS"
        marc.des="Pueden ser perfectamente justos pero pueden generar CORRUPCIÓN. Las justas: MONARQUÍA (DE UNO), ARISTROCRACIA Y DEMOCRACIA. Formas corruptas: TIRANÍA, OLIGARQUÍA Y DEMAGOGIA."
        marc.ms=getHmsToMs(0, 13, 49)
        marcs.push(marc)

        marc={}
        marc.titulo="RESUMEN FINAL"
        marc.des="Se explica de manera resumida lo explicado."
        marc.ms=getHmsToMs(0, 21, 32)
        marcs.push(marc)

        item.marcs=marcs
        j.items.push(item)

        app.json=j

        loadDataAudios()
        loadData(0)
    }

    Shortcut {
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
    function loadDataAudios(){
        lmAudios.clear()
        for(var i=0;i<app.json.items.length;i++){
            lmAudios.append(lmAudios.addItem(app.json.items[i].tit, app.json.items[i].des,  app.json.items[i].url))
        }
    }
    function loadData(index){
        lm.clear()
        let item=app.json.items[index]
        //labelTit.text=item.tit
        unikObj.downloadGitHubZip(item.url, unikObj.getPath(4)+"/prueba.wav");
        mediaPlayer.source=item.url
        //xLog.visible=true
        //log.text=JSON.stringify(item, null, 2)
        //return
        for(var i=0;i<item.marcs.length;i++){
            let marc=item.marcs[i]
            //log.text=JSON.stringify(marc, null, 2)
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
    function getHmsToMs(hours, minutes, seconds) {
        var h = hours || 0;
        var m = minutes || 0;
        var s = seconds || 0;

        return ((h * 3600) + (m * 60) + s) * 1000;
    }
}
