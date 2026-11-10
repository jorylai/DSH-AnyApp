package io.github.ccch1mneyyy.dsh_app.wish

import org.junit.Assert.*
import org.junit.Test

class WishIconMetadataTest {
    private fun metadata(vararg fields: Pair<String, Any>) = WishWorkStore.bitmapMetadata(mapOf(*fields))
    private fun rejects(vararg fields: Pair<String, Any>) {
        try { metadata(*fields); fail("Invalid icon metadata was accepted") }
        catch (_: IllegalArgumentException) { }
    }

    @Test fun restoresEmojiAndAiVectorEditingWithoutRetainingArbitraryPayloads() {
        val emoji = metadata("kind" to "emoji", "emoji" to "🧑🏽‍🚀", "styleVersion" to 2,
            "builtin" to "rocket", "palette" to "mint", "variant" to 2,
            "url" to "https://invalid.example/unused", "svg" to "<svg/>")
        assertEquals("🧑🏽‍🚀", emoji["emoji"])
        assertEquals("emoji", emoji["kind"])
        assertEquals(2, emoji["styleVersion"])
        assertEquals("rocket", emoji["builtin"])
        assertFalse(emoji.containsKey("url"))
        assertFalse(emoji.containsKey("svg"))
        val vector = metadata("kind" to "vector", "styleVersion" to 2, "builtin" to "brain")
        assertEquals("vector", vector["kind"])
        assertEquals("brain", vector["builtin"])
    }

    @Test fun legacyBitmapMetadataKeepsDefaultsAndNewGlyphsHaveKnownFallbacks() {
        assertEquals(mapOf("builtin" to "spark", "styleVersion" to 1, "palette" to "indigo", "variant" to 0), metadata())
        assertFalse(metadata("builtin" to "timer").containsKey("kind"))
        assertEquals("school", metadata("builtin" to "school")["builtin"])
        assertEquals("spark", metadata("builtin" to "<script/>")["builtin"])
        assertEquals("glyph", metadata("kind" to "glyph")["kind"])
    }

    @Test fun acceptsCompoundEmojiWithoutSeparatingTheirCodePoints() {
        val values = listOf("😀", "❤️", "🏳️‍🌈", "👩🏾‍💻", "👨‍👩‍👧‍👦", "🇨🇳", "1️⃣", "#️⃣", "🧑‍🦽‍➡️",
            "\uD83C\uDFF4\uDB40\uDC67\uDB40\uDC62\uDB40\uDC65\uDB40\uDC6E\uDB40\uDC67\uDB40\uDC7F")
        for (value in values) assertTrue(value, WishWorkStore.validEmojiSequence(value))
    }

    @Test fun rejectsTextControlsMultipleEmojiAndBrokenSequences() {
        val values = listOf("", "hello", "app图标", "<script>", "😀😀", "😀\n", "🇨", "1", "#", "1️", "😀‍", "‍😀", "😀\u202e", "😀".repeat(100))
        for (value in values) assertFalse(value, WishWorkStore.validEmojiSequence(value))
        rejects("kind" to "emoji")
        rejects("kind" to "emoji", "emoji" to "任意文字")
        rejects("emoji" to "😀")
        rejects("kind" to "url")
        rejects("styleVersion" to 3)
        rejects("styleVersion" to 1.5)
    }
}
