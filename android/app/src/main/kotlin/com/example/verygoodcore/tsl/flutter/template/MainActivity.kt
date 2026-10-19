package com.hadi.me

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val incomingDocumentsChannel = "lingua_pages/incoming_documents"
        private const val getInitialDocumentMethod = "getInitialDocument"
        private const val incomingDocumentMethod = "incomingDocument"
    }

    private val pendingIntentLock = Any()
    private var pendingDocumentUri: Uri? = null
    private var incomingDocumentsChannelInstance: MethodChannel? = null

    override fun shouldHandleDeeplinking(): Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        incomingDocumentsChannelInstance = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            incomingDocumentsChannel,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    getInitialDocumentMethod -> takeInitialDocument(result)
                    else -> result.notImplemented()
                }
            }
        }

        handleDocumentIntent(intent, emitDocument = false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleDocumentIntent(intent, emitDocument = true)
    }

    private fun handleDocumentIntent(intent: Intent?, emitDocument: Boolean) {
        if (intent?.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return

        if (emitDocument && incomingDocumentsChannelInstance != null) {
            copyIncomingDocument(uri) { document ->
                if (document != null) {
                    incomingDocumentsChannelInstance?.invokeMethod(
                        incomingDocumentMethod,
                        document,
                    )
                }
            }
        } else {
            synchronized(pendingIntentLock) {
                pendingDocumentUri = uri
            }
        }
    }

    private fun takeInitialDocument(result: MethodChannel.Result) {
        val uri = synchronized(pendingIntentLock) {
            val pendingUri = pendingDocumentUri
            pendingDocumentUri = null
            pendingUri
        }

        if (uri == null) {
            result.success(null)
            return
        }

        copyIncomingDocument(uri) { document ->
            result.success(document)
        }
    }

    private fun copyIncomingDocument(
        uri: Uri,
        callback: (Map<String, String>?) -> Unit,
    ) {
        Thread {
            val document = runCatching { copyUriToCache(uri) }.getOrNull()
            runOnUiThread { callback(document) }
        }.start()
    }

    private fun copyUriToCache(uri: Uri): Map<String, String>? {
        val input = contentResolver.openInputStream(uri) ?: return null
        val fileName = resolveFileName(uri)
        val directory = File(cacheDir, "linguapages-incoming").apply { mkdirs() }
        val destination = File(directory, "${System.currentTimeMillis()}-$fileName")

        input.use { source ->
            destination.outputStream().use { target ->
                source.copyTo(target)
            }
        }

        return mapOf(
            "path" to destination.absolutePath,
            "fileName" to fileName,
        )
    }

    private fun resolveFileName(uri: Uri): String {
        val displayName = contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                cursor.getString(cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME))
            } else {
                null
            }
        }

        val baseName = displayName
            ?.takeIf { it.isNotBlank() }
            ?: uri.lastPathSegment
            ?: "document"
        val mimeType = contentResolver.getType(uri).orEmpty()
        val withExtension = if (baseName.contains('.')) {
            baseName
        } else {
            "$baseName${extensionForMimeType(mimeType)}"
        }
        return withExtension
            .replace(Regex("[^A-Za-z0-9._-]"), "_")
            .ifBlank { "document" }
    }

    private fun extensionForMimeType(mimeType: String): String = when (mimeType) {
        "application/epub+zip" -> ".epub"
        "application/pdf" -> ".pdf"
        "text/markdown" -> ".md"
        "text/html", "application/xhtml+xml" -> ".html"
        "application/x-fictionbook+xml", "application/xml", "text/xml" -> ".fb2"
        else -> ".txt"
    }
}
