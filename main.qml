import QtQuick 2.7
import QtQuick.Window 2.0
import QtMultimedia 5.0
//import QtTextToSpeech

Window {
    id: mainWindow
    width: 480
    height: 800
    visible: true
    title: "Reproductor Accesible"
    color: "#0a0a0a" // Fondo oscuro de alto contraste

    // Módulo de Texto a Voz para accesibilidad de personas no videntes
    /*TextToSpeech {
        id: tts
        locale: "es_ES" // Configurado en español
    }*/

    Audio{
        id: mediaPlayer
        source: "https://github.com/nextsigner/aristoteles/releases/download/filosof%C3%ADa/1.wav"
        volume: 1.0
        autoLoad: true
        autoPlay: true
    }
    // Área táctil que abarca toda la pantalla para facilitar la interacción sin mirar
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

                        // Si el arrastre es mínimo (menos del 5% de la pantalla), se toma como un toque (Play/Pause)
                        if (ratio < 0.05) {
                            if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                                mediaPlayer.pause();
                            } else {
                                mediaPlayer.play();
                            }
                            return;
                        }

                        // Rango solicitado: 10 segundos (10000 ms) a 5 minutos (300000 ms)
                        var minJump = 10 * 1000;         // 10 segundos
                        var maxJump = 5 * 60 * 1000;     // 5 minutos (300 segundos)

                        // Mapear el porcentaje de arrastre (ratio) al rango de tiempo
                        var jumpTime = minJump + ratio * (maxJump - minJump);
                        if (jumpTime > maxJump) jumpTime = maxJump;

                        var newPosition = mediaPlayer.position;
                        var secondsFormatted = Math.round(jumpTime / 1000);

                        if (deltaX > 0) {
                            // Deslizamiento hacia la DERECHA -> Avanzar
                            newPosition += jumpTime;
                            //mediaPlayer.position = Math.min(newPosition, mediaPlayer.duration);
                            mediaPlayer.seek(Math.min(newPosition, mediaPlayer.duration));
                            //tts.say("Avanzando " + secondsFormatted + " segundos");
                        } else {
                            // Deslizamiento hacia la IZQUIERDA -> Retroceder
                            newPosition -= jumpTime;
                            //mediaPlayer.position = Math.max(newPosition, 0);
                            mediaPlayer.seek(Math.max(newPosition, 0));
                            //tts.say("Retrocediendo " + secondsFormatted + " segundos");
                        }
                    }
    }

    // Reproducir automáticamente y anunciar al iniciar la app
    Component.onCompleted: {
        mediaPlayer.play();
        //tts.say("Reproductor iniciado. Deslice a la derecha para avanzar, a la izquierda para retroceder según la longitud del gesto. Toque una vez para pausar o reproducir.");
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: Qt.quit()
    }
}
