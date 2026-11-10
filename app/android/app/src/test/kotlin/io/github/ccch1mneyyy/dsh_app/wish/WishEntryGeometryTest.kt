package io.github.ccch1mneyyy.dsh_app.wish
import org.junit.Assert.*
import org.junit.Test
class WishEntryGeometryTest {
    private fun place(x:Int,y:Int,height:Int=800,open:Boolean=true)=WishEntryGeometry.place(400,height,x,y,52,8,8,212,200,open)
    @Test fun expansionKeepsTheBallAtItsAnchorOnEitherEdge() {
        for(x in listOf(8,340)) for(y in listOf(80,500)) {
            val closed=place(x,y,open=false);val open=place(x,y)
            assertEquals(closed.x,open.x+open.ballX);assertEquals(closed.y,open.y+open.ballY)
            assertEquals(8, if(open.above)open.ballY-open.clusterHeight else open.height-52-open.clusterHeight)
            assertTrue(open.x>=8 && open.x+open.width<=392)
        }
    }
    @Test fun keyboardMovesTheWholeClusterIntoTheVisibleAreaAndCanRestore() {
        val ime=place(340,700,400)
        assertTrue(ime.y>=8);assertTrue(ime.y+ime.height<=392)
        val restored=place(340,700,800)
        assertEquals(700,restored.y+restored.ballY)
    }
    @Test fun limitedSpaceScrollsTheActionsInsteadOfMovingTheAnchor() {
        val p=place(340,100,240)
        assertEquals(100,p.y+p.ballY);assertTrue(p.clusterHeight<200)
    }
}
