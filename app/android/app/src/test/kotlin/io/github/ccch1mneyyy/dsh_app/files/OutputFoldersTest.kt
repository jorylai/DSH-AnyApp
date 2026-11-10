package io.github.ccch1mneyyy.dsh_app.files

import java.io.File
import java.nio.file.Files
import org.junit.Assert.*
import org.junit.Test

class OutputFoldersTest {
    @Test fun newAndHistoricalFilesRemainAvailableWithoutChangingTheirContents() = withDirectory { root ->
        val files = listOf("DSH-AnyApp", "DSH-Go", "DSH").map { folder ->
            File(root, "Download/$folder/report.pdf").apply {
                parentFile!!.mkdirs()
                writeText("report from $folder")
            }
        }
        val outputs = FilesPlugin.listOutputs(root.path, 3, "Download")
        assertEquals(
            listOf(
                "/sdcard/Download/DSH-AnyApp/report.pdf",
                "/sdcard/Download/DSH-Go/report.pdf",
                "/sdcard/Download/DSH/report.pdf",
            ),
            outputs.map { it["path"] },
        )
        files.forEach { file ->
            assertEquals("report from ${file.parentFile!!.name}", file.readText())
            val output = outputs.single { (it["path"] as String).endsWith("/${file.parentFile!!.name}/report.pdf") }
            assertEquals(file.length(), output["bytes"])
            assertEquals(file.lastModified(), output["modified"])
        }
    }

    @Test fun anUpgradeReadsOldFilesWithoutCreatingOrMovingToTheNewFolder() = withDirectory { root ->
        val old = File(root, "Download/DSH-Go/old.pdf").apply {
            parentFile!!.mkdirs()
            writeText("keep this file here")
        }
        assertEquals(listOf("/sdcard/Download/DSH-Go/old.pdf"), FilesPlugin.listOutputs(root.path, 3, "Download").map { it["path"] })
        assertTrue(old.exists())
        assertEquals("keep this file here", old.readText())
        assertFalse(File(root, "Download/DSH-AnyApp").exists())
        assertFalse(File(root, "Download/DSH").exists())
    }

    @Test fun historicalFoldersKeepTheSameDepthAndHiddenFileRules() = withDirectory { root ->
        for (folder in listOf("DSH-AnyApp", "DSH-Go", "DSH")) {
            File(root, "Download/$folder/sub/report.pdf").apply { parentFile!!.mkdirs(); writeText("nested") }
            File(root, "Download/$folder/.hidden.pdf").writeText("hidden")
        }
        assertTrue(FilesPlugin.listOutputs(root.path, 1, "Download").isEmpty())
        assertEquals(3, FilesPlugin.listOutputs(root.path, 2, "Download").size)
        assertTrue(FilesPlugin.listOutputs(root.path, 3, "Download").none { (it["path"] as String).contains(".hidden") })
    }

    private fun withDirectory(test: (File) -> Unit) {
        val root = Files.createTempDirectory("anyapp-output-folders-").toFile()
        try { test(root) } finally { root.deleteRecursively() }
    }
}
