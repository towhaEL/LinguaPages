package com.linguapages.app

import android.app.SearchManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import android.view.KeyEvent
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val incomingDocumentsChannel = "lingua_pages/incoming_documents"
        private const val getInitialDocumentMethod = "getInitialDocument"
        private const val incomingDocumentMethod = "incomingDocument"
        private const val volumeKeysChannel = "lingua_pages/volume_keys"
        private const val textActionsChannel = "lingua_pages/text_actions"
        private const val folderImportChannel = "lingua_pages/folder_import"
        private val supportedExtensions =
            setOf("epub", "pdf", "txt", "md", "markdown", "html", "htm", "xhtml", "fb2")

        // Bounds a folder walk so a huge tree cannot stall the import.
        private const val maxFolderDepth = 4
        private const val maxFolderDocuments = 500
    }

    private val pendingIntentLock = Any()
    private var pendingDocumentUri: Uri? = null
    private var incomingDocumentsChannelInstance: MethodChannel? = null
    private var volumeKeysChannelInstance: MethodChannel? = null

    private var pendingFolderResult: MethodChannel.Result? = null

    // The system folder picker grants read access to that tree only, so no
    // storage permission is needed.
    private val folderPicker =
        registerForActivityResult(ActivityResultContracts.OpenDocumentTree()) { treeUri ->
            val result = pendingFolderResult ?: return@registerForActivityResult
            pendingFolderResult = null
            if (treeUri == null) {
                result.success(null)
                return@registerForActivityResult
            }
            Thread {
                val documents = runCatching { listFolderDocuments(treeUri) }.getOrNull()
                runOnUiThread {
                    if (documents == null) {
                        result.error("unreadable", "The folder could not be read.", null)
                    } else {
                        result.success(documents)
                    }
                }
            }.start()
        }

    // Set by the reader while it is open with volume-key paging on.
    private var volumeKeyPaging = false

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

        volumeKeysChannelInstance = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            volumeKeysChannel,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEnabled" -> {
                        volumeKeyPaging = call.arguments as? Boolean ?: false
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            folderImportChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFolder" -> {
                    if (pendingFolderResult != null) {
                        result.error("busy", "A folder is already being picked.", null)
                    } else {
                        pendingFolderResult = result
                        folderPicker.launch(null)
                    }
                }
                "copyDocument" -> {
                    val uri = (call.arguments as? String)?.let(Uri::parse)
                    if (uri == null) {
                        result.success(null)
                    } else {
                        copyIncomingDocument(uri) { document -> result.success(document) }
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            textActionsChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "webSearch" -> result.success(webSearch(call.arguments as? String ?: ""))
                "openTtsSettings" -> result.success(openTtsSettings())
                else -> result.notImplemented()
            }
        }

        handleDocumentIntent(intent, emitDocument = false)
    }

    // Where voices are installed and the default engine is chosen.
    private fun openTtsSettings(): Boolean = try {
        startActivity(Intent("com.android.settings.TTS_SETTINGS"))
        true
    } catch (_: ActivityNotFoundException) {
        false
    }

    // The user's default search app handles the query; false when none does.
    private fun webSearch(query: String): Boolean = try {
        startActivity(Intent(Intent.ACTION_WEB_SEARCH).putExtra(SearchManager.QUERY, query))
        true
    } catch (_: ActivityNotFoundException) {
        false
    }

    // Intercepted before any view, so it also works while the native Readium
    // view has focus. Key up is consumed too, or the system volume panel shows.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val direction = when (event.keyCode) {
            KeyEvent.KEYCODE_VOLUME_DOWN -> "next"
            KeyEvent.KEYCODE_VOLUME_UP -> "previous"
            else -> null
        }
        if (!volumeKeyPaging || direction == null) return super.dispatchKeyEvent(event)
        if (event.action == KeyEvent.ACTION_DOWN) {
            volumeKeysChannelInstance?.invokeMethod("pageTurn", direction)
        }
        return true
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

    /** Supported documents in [treeUri] and its subfolders, as uri and file name. */
    private fun listFolderDocuments(treeUri: Uri): List<Map<String, String>> {
        val documents = mutableListOf<Map<String, String>>()

        fun walk(parentId: String, depth: Int) {
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentId)
            contentResolver.query(
                children,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                ),
                null,
                null,
                null,
            )?.use { cursor ->
                while (cursor.moveToNext() && documents.size < maxFolderDocuments) {
                    val id = cursor.getString(0)
                    val name = cursor.getString(1) ?: continue
                    if (cursor.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR) {
                        if (depth < maxFolderDepth) walk(id, depth + 1)
                    } else if (name.substringAfterLast('.', "").lowercase() in supportedExtensions) {
                        documents += mapOf(
                            "uri" to DocumentsContract.buildDocumentUriUsingTree(treeUri, id).toString(),
                            "fileName" to name,
                        )
                    }
                }
            }
        }

        walk(DocumentsContract.getTreeDocumentId(treeUri), 0)
        return documents
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
