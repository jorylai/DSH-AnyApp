package io.github.ccch1mneyyy.dsh_app.wish

/** Coordinates refer to the ball, never the expanded window. All units are pixels. */
internal data class WishEntryPlacement(
    val x: Int, val y: Int, val width: Int, val height: Int,
    val ballX: Int, val ballY: Int, val above: Boolean, val clusterHeight: Int,
)
internal object WishEntryGeometry {
    fun place(screenWidth: Int, usableHeight: Int, anchorX: Int, anchorY: Int,
              ball: Int, edge: Int, gap: Int, desiredWidth: Int, desiredHeight: Int,
              expanded: Boolean): WishEntryPlacement {
        val sx = anchorX.coerceIn(edge, maxOf(edge, screenWidth - ball - edge))
        val sy = anchorY.coerceIn(edge, maxOf(edge, usableHeight - ball - edge))
        if (!expanded) return WishEntryPlacement(sx, sy, ball, ball, 0, 0, true, 0)
        val aboveRoom = maxOf(0, sy - edge - gap)
        val belowRoom = maxOf(0, usableHeight - sy - ball - edge - gap)
        val above = aboveRoom >= desiredHeight || aboveRoom >= belowRoom
        val content = minOf(desiredHeight, if (above) aboveRoom else belowRoom)
        val width = minOf(desiredWidth, screenWidth - edge * 2).coerceAtLeast(ball)
        val right = sx + ball / 2 >= screenWidth / 2
        val x = if (right) maxOf(edge, sx + ball - width) else minOf(sx, screenWidth - width - edge)
        val ballY = if (above) content + gap else 0
        return WishEntryPlacement(x, sy - ballY, width, ball + gap + content,
            sx - x, ballY, above, content)
    }
}
