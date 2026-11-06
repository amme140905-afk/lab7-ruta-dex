package mx.ipn.lab7.lab7_ruta_dex

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var player: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ruta_dex/audio")
            .setMethodCallHandler { call, result ->
                if (call.method != "play") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val url = call.argument<String>("url")
                if (url == null) {
                    result.error("NO_URL", "No hay sonido disponible", null)
                    return@setMethodCallHandler
                }
                player?.release()
                player = MediaPlayer().apply {
                    setDataSource(url)
                    setOnPreparedListener { it.start() }
                    setOnCompletionListener { it.release(); player = null }
                    prepareAsync()
                }
                result.success(null)
            }
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }
}
