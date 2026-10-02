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
    title: !isRunikStart?"Runik":"Runik!"
    color: apps.backgroundColor
    property int fs: width*0.035
    Loader {
        id: mediaLoader
        anchors.fill: parent
        sourceComponent: multimediaComponent
        asynchronous: true
    }

    Component {
        id: multimediaComponent
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
                    var screenWidth = mainWindow.width;
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
    }

    Component.onCompleted: {
        if(Qt.application.arguments.toString().indexOf('-folder')>=0){
            let folder=''
            for(var i=0;i<Qt.application.arguments.length;i++){
                let arg=Qt.application.arguments[i]
                if(arg.indexOf('-folder=')===0){
                    let m0=arg.split('-folder=')
                    folder=m0[1]
                    break
                }
            }
            let mainPath=folder+'/main.qml'
            if(unikObj.fileExist(mainPath)){
                engine.load(mainPath)
                app.close()
                return
            }else{
                statusText.text="El archivo "+mainPath+' no existe!'
            }
        }
        if(!app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0){
            tiAppId.text="0"
        }
        getAppsList()
        tiAppId.focus=true
    }

    /*Component.onCompleted: {
        // Retardamos la llamada 1.5 segundos
        timer.restart()
    }

    Timer {
        id: timer
        interval: 5000
        repeat: false
        onTriggered: getAppsList()
    }*/

    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }

    function getAppsList(){
        let d = new Date(Date.now())
        var targetUrl='https://raw.githubusercontent.com/nextsigner/nextsigner.github.io/main/runik/apps.txt?r='+d.getTime()

        statusText.text = "Cargando...";

        // Llamada a la función JS
        fetchAppsList(targetUrl, function(success, data) {
            if (success) {
                //textArea.text = data;
                statusText.text = "¡Archivo cargado con éxito!";
                statusText.text+='\n'+data
                app.uAppsList=data.split('\n')
                if(!app.isRunikStart && Qt.application.arguments.indexOf('-dev')<0){
                    btnCargar.clicked()
                }
            } else {
                statusText.text = data; // Muestra el mensaje de error
            }
        });
    }


    function fetchAppsList(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    // Éxito: pasamos el texto al callback
                    callback(true, xhr.responseText);
                } else {
                    // Error en la petición (ej. 404, 500)
                    callback(false, "Error al cargar el archivo. Código: " + xhr.status);
                }
            }
        }
        xhr.send();
    }
    function getGitHubZipUrl(repoUrl) {
        if (!repoUrl || typeof repoUrl !== "string") {
            return "";
        }

        // Limpiamos espacios y removemos una barra diagonal al final si existe
        let cleanUrl = repoUrl.trim();
        if (cleanUrl.endsWith("/")) {
            cleanUrl = cleanUrl.slice(0, -1);
        }

        // Si la URL ya termina en .git, se lo removemos
        if (cleanUrl.endsWith(".git")) {
            cleanUrl = cleanUrl.slice(0, -4);
        }

        // Verificamos si es una URL válida de GitHub (ej: https://github.com/usuario/repositorio)
        const regex = /^https?:\/\/github\.com\/([^\/]+)\/([^\/]+)$/i;
        const match = cleanUrl.match(regex);

        if (match) {
            const owner = match[1];
            const repo = match[2];
            // Retorna la URL estándar del zip de la rama principal (main)
            return "https://github.com/" + owner + "/" + repo + "/archive/refs/heads/main.zip";
        }

        // Si la URL ya es más específica (ej. incluye /tree/main o /blob/main), la adaptamos
        // O si no coincide con el formato básico, devolvemos cadena vacía o intentamos parsear
        return "";
    }
    function setHistorial(dato){
        let s=''
        let fp=unikObj.getPath(4)+'/historial.txt'
        let fd=''//unikObj.getFile(fp)
        if(unikObj.fileExist(fp)){
            fd=unikObj.getFile(fp)
        }else{
            fd=''
        }
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i]!==dato){
                s+=lines[i]+'\n'
            }
        }
        s+=dato+'\n'
        unikObj.setFile(fp, s)
        console.log('Se guarda historial: '+fp)
    }
    function getHistorial(){
        let cant=0
        let fp=unikObj.getPath(4)+'/historial.txt'
        let fd=unikObj.getFile(fp)
        if(fd==='error'){
            return
        }
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i]!=='\n'&&lines[i].length>1){
                lm.append(lm.addItem(lines[i]))
                cant++
            }
        }
        if(cant>0){
            xHistorial.visible=true
        }

    }
}
