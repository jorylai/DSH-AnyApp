package io.github.ccch1mneyyy.dsh_app.phone.a11y

import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OverlayBrandStringsTest {
    private val resources: File
        get() = generateSequence(File(requireNotNull(System.getProperty("user.dir")))) { it.parentFile }
            .flatMap { base -> sequenceOf("src/main/res", "app/src/main/res", "app/android/app/src/main/res").map { File(base, it) } }
            .first { File(it, "values/phone_a11y_strings.xml").isFile }

    private fun strings(folder: String, name: String): Map<String, String> {
        val factory = DocumentBuilderFactory.newInstance().apply {
            setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
        }
        val nodes = factory.newDocumentBuilder().parse(File(resources, "$folder/$name.xml")).getElementsByTagName("string")
        return (0 until nodes.length).associate { index ->
            val node = nodes.item(index)
            node.attributes.getNamedItem("name").nodeValue to node.textContent
        }
    }

    @Test fun bothLanguagesKeepTheActionSeparateFromTheAnyappCaption() {
        for (folder in listOf("values", "values-zh")) {
            val status = strings(folder, "i18n_strings")
            val parser = StatusLines(status.getValue("phone_waived_status"), status.getValue("phone_acting"))
            val press = String.format(status.getValue("phone_status_press"), "Back")
            val line = parser.parse(press)
            assertTrue(line.acting)
            assertFalse(line.text.contains("AnyApp"))
            assertFalse(line.text.contains("DSH"))
            assertTrue(line.text.contains("Back"))
            assertEquals(1, StepHistory().apply { add(line) }.before(null, 3).size)
        }
    }

    @Test fun overlayControlsUseAnyappInBothLanguages() {
        for (folder in listOf("values", "values-zh")) {
            val controls = strings(folder, "phone_a11y_strings")
            for (key in listOf("overlay_anyapp_working", "overlay_anyapp_paused", "overlay_anyapp_waiting", "overlay_anyapp_stopped")) {
                assertTrue("$folder/$key", controls.getValue(key).startsWith("AnyApp"))
            }
            val overlay = controls + strings(folder, "i18n_strings")
            for ((key, value) in overlay.filterKeys { it.startsWith("overlay_") }) {
                assertFalse("$folder/$key", Regex("(?i)\\bDSH\\b").containsMatchIn(value))
            }
        }
    }
}
