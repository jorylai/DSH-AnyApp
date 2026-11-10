package io.github.ccch1mneyyy.dsh_app.wish

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.TextUtils
import android.view.*
import android.widget.*
import io.github.ccch1mneyyy.dsh_app.phone.PhoneControl
import io.github.ccch1mneyyy.dsh_app.phone.a11y.PhoneA11yService
import kotlin.math.abs

/** A single persistent ball. Actions grow from its anchor; a second tap folds them away. */
object WishActionOverlay {
    private const val HOST_ENTRY = "local-anyapp-entry"
    private val main = Handler(Looper.getMainLooper())
    private var ctx: Context? = null
    private var root: FrameLayout? = null
    private var ball: ImageView? = null
    private var cluster: View? = null
    private var params: WindowManager.LayoutParams? = null
    private var clusterParams: WindowManager.LayoutParams? = null
    private var work: String? = null
    private var shown = false
    private var expanded = false
    private var watching = false
    private var starting = false
    private var anchorX = 0
    private var anchorY = 0
    private var usableHeight = 0
    var visibility: ((Boolean, String?) -> Unit)? = null
    var dispatch: ((Map<String, Any?>) -> Unit)? = null
    private fun dp(n: Int) = (n * (ctx?.resources?.displayMetrics?.density ?: 1f)).toInt()
    private fun label(cn: String, en: String) = if (ctx?.let { !io.github.ccch1mneyyy.dsh_app.i18n.AppStrings.isEnglish(it) } != false) cn else en
    private fun surface(radius: Int, active: Boolean = false) = GradientDrawable(
        GradientDrawable.Orientation.TL_BR, intArrayOf(Color.parseColor("#FA223454"), Color.parseColor("#FA111D32")),
    ).apply {
        cornerRadius = dp(radius).toFloat()
        setStroke(dp(1), Color.parseColor(if (active) "#B896B2FF" else "#665474A3"))
    }
    fun showEntry(context: Context, userInitiated: Boolean = false): Boolean {
        val selected = WishDeviceStore.work ?: selectedWork()
            ?: context.getSharedPreferences("wish-entry-v1", 0).getString("selected", null)
        return show(context, selected ?: HOST_ENTRY, userInitiated)
    }
    fun show(context: Context, id: String, userInitiated: Boolean = false): Boolean {
        check(Looper.myLooper() == Looper.getMainLooper())
        check(Settings.canDrawOverlays(context)) { "overlay-permission-required" }
        WishDeviceStore.check(id)
        val entryPrefs = context.getSharedPreferences("wish-entry-v1", 0)
        if (entryPrefs.getBoolean("manually-hidden", false) && !userInitiated) return false
        if (userInitiated) entryPrefs.edit().putBoolean("manually-hidden", false).apply()
        val owner = WishDeviceStore.work
        check(owner == null || owner == id || !WishDeviceStore.allowed(context, owner)) { "another-work-task-running" }
        if (work != id) { expanded = false; starting = false }
        ctx = context.applicationContext; work = id; shown = true
        val prefs = context.getSharedPreferences("wish-entry-v1", 0)
        if (id != HOST_ENTRY) prefs.edit().putString("selected", id).apply()
        if (root == null) {
            anchorX = prefs.getInt("x", context.resources.displayMetrics.widthPixels - dp(60))
            anchorY = prefs.getInt("y", dp(200))
            usableHeight = context.resources.displayMetrics.heightPixels - dp(32)
        }
        if (!watching) {
            watching = true
            PhoneControl.get(context).tasks.addListener { state -> main.post {
                if (state.active) remove() else if (shown && root == null) render()
            } }
        }
        if (!PhoneControl.get(context).tasks.isActive) render()
        visibility?.invoke(shown, id)
        return shown
    }
    fun hide(userInitiated: Boolean = false) {
        if (userInitiated) ctx?.getSharedPreferences("wish-entry-v1", 0)?.edit()?.putBoolean("manually-hidden", true)?.apply()
        shown = false; expanded = false; remove(); visibility?.invoke(false, work)
    }
    fun isShown() = shown
    fun selectedWork() = work?.takeUnless { it == HOST_ENTRY }
    fun starting(id: String, value: Boolean) {
        if (work != id) return
        starting = value
        if (shown && ctx?.let { !PhoneControl.get(it).tasks.isActive } == true) render()
    }
    private fun removeCluster() {
        cluster?.let { v -> v.animate().cancel(); runCatching { ctx?.getSystemService(WindowManager::class.java)?.removeView(v) } }
        cluster = null; clusterParams = null
    }
    private fun remove() {
        removeCluster()
        root?.let { v -> v.animate().cancel(); runCatching { ctx?.getSystemService(WindowManager::class.java)?.removeView(v) } }
        root = null; ball = null; cluster = null; params = null
    }
    private fun text(value: String, size: Float = 14f) = TextView(ctx).apply {
        text = value; textSize = size; setTextColor(Color.parseColor("#F4F1EA")); gravity = Gravity.CENTER_VERTICAL
        maxLines = 2; ellipsize = TextUtils.TruncateAt.END
    }
    private fun saveAnchor() {
        ctx?.getSharedPreferences("wish-entry-v1", 0)?.edit()?.putInt("x", anchorX)?.putInt("y", anchorY)?.apply()
    }
    private fun ensureWindow(context: Context): FrameLayout {
        root?.let { return it }
        val frame = FrameLayout(context).apply { clipChildren = false; clipToPadding = false }
        val entry = ImageView(context).apply {
            setImageBitmap(AnyappBrand.bitmap(context)); scaleType = ImageView.ScaleType.FIT_CENTER
            setPadding(0, 0, 0, 0); elevation = dp(10).toFloat()
            isClickable = true; isFocusable = true
            setOnClickListener { performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK); expanded = !expanded; render(true) }
            setOnLongClickListener { hide(userInitiated = true); true }
        }
        frame.addView(entry, FrameLayout.LayoutParams(dp(52), dp(52)))
        var downX = 0f; var downY = 0f; var oldX = 0; var oldY = 0; var dragging = false
        val hold = Runnable { if (!dragging && root != null) entry.performLongClick() }
        entry.setOnTouchListener { _, e ->
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downX = e.rawX; downY = e.rawY; oldX = (params?.x ?: anchorX) + entry.left; oldY = (params?.y ?: anchorY) + entry.top; dragging = false
                    main.postDelayed(hold, ViewConfiguration.getLongPressTimeout().toLong()); true
                }
                MotionEvent.ACTION_MOVE -> {
                    if (abs(e.rawX - downX) + abs(e.rawY - downY) > dp(8)) {
                        dragging = true; main.removeCallbacks(hold)
                    }
                    if (dragging && root != null) {
                        expanded = false; anchorX = oldX + (e.rawX - downX).toInt(); anchorY = oldY + (e.rawY - downY).toInt()
                        layoutWindow()
                    }; true
                }
                MotionEvent.ACTION_UP -> {
                    main.removeCallbacks(hold)
                    if (root != null) {
                        if (dragging) {
                            val width = context.resources.displayMetrics.widthPixels
                            anchorX = if (anchorX + dp(26) < width / 2) dp(8) else width - dp(60)
                            layoutWindow(); saveAnchor()
                        } else entry.performClick()
                    }; true
                }
                MotionEvent.ACTION_CANCEL -> { main.removeCallbacks(hold); true }
                else -> false
            }
        }
        val p = WindowManager.LayoutParams(dp(52), dp(52), WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN, PixelFormat.TRANSLUCENT).apply {
            gravity = Gravity.TOP or Gravity.LEFT; x = anchorX; y = anchorY
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING
        }
        root = frame; ball = entry; params = p
        if (Build.VERSION.SDK_INT >= 30) frame.setOnApplyWindowInsetsListener { _, insets ->
            val bottom = maxOf(insets.getInsets(WindowInsets.Type.ime()).bottom, insets.getInsets(WindowInsets.Type.systemBars()).bottom)
            val height = context.resources.displayMetrics.heightPixels - bottom
            if (height != usableHeight) { usableHeight = height; main.post { if (root === frame) layoutWindow() } }
            insets
        }
        try { context.getSystemService(WindowManager::class.java).addView(frame, p); frame.requestApplyInsets() }
        catch (e: Exception) { shown = false; remove(); visibility?.invoke(false, work); throw e }
        return frame
    }
    private fun render(animate: Boolean = false) {
        val context = ctx ?: return; val id = work ?: return
        if (!Settings.canDrawOverlays(context)) { hide(); return }
        val frame = ensureWindow(context)
        removeCluster()
        if (expanded) {
            val data = WishWorkStore.get(context, id)
            val name = (data["customName"] as? String)?.takeIf { it.isNotBlank() } ?: data["title"] as? String ?: "DSH AnyApp"
            val foreground = PhoneA11yService.instance?.clock?.lastPackage
            val actions = (data["actions"] as? List<*>)?.filterIsInstance<Map<*, *>>() ?: emptyList()
            val ordered = actions.sortedByDescending { (it["apps"] as? List<*>)?.contains(foreground) == true }
            val column = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL; setPadding(dp(12), dp(10), dp(12), dp(8))
                background = surface(22); elevation = dp(10).toFloat()
            }
            column.addView(text(name, 11f).apply {
                maxLines = 1; setTextColor(Color.parseColor("#ACBCDA")); setPadding(dp(4), 0, dp(4), dp(7))
            }, LinearLayout.LayoutParams(-1, -2))
            for (action in ordered) {
                val title = action["label"] as? String ?: label("执行动作", "Run action")
                val row = LinearLayout(context).apply {
                    gravity = Gravity.CENTER_VERTICAL; isClickable = true; isFocusable = true
                    setPadding(dp(4), dp(5), dp(4), dp(5)); alpha = if (starting) .45f else 1f
                    background = android.graphics.drawable.StateListDrawable().apply {
                        addState(intArrayOf(android.R.attr.state_pressed), surface(13, true))
                        addState(intArrayOf(), android.graphics.drawable.ColorDrawable(Color.TRANSPARENT))
                    }
                }
                row.addView(text("↗", 20f).apply { gravity = Gravity.CENTER; setTextColor(Color.parseColor("#B3C4FF")) }, LinearLayout.LayoutParams(dp(30), dp(40)))
                row.addView(text(title).apply { setPadding(dp(6), 0, dp(2), 0) }, LinearLayout.LayoutParams(0, -2, 1f))
                column.addView(row, LinearLayout.LayoutParams(-1, -2).apply { bottomMargin = dp(2) })
                row.setOnClickListener {
                    if (starting) return@setOnClickListener
                    row.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                    val supported = action["apps"] as? List<*> ?: emptyList<Any>()
                    val source = foreground?.takeIf { it != context.packageName && (supported.isEmpty() || it in supported) }
                    val input = if (source != null) mapOf("sourcePackage" to source) else emptyMap<String, String>()
                    expanded = false; render()
                    dispatch?.invoke(mapOf("work" to id, "id" to action["id"], "input" to input))
                        ?: context.startActivity(WishEntries.entry(context, id, action["id"] as String).putExtra("sourcePackage", source).addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK))
                }
            }
            if (actions.isEmpty()) column.addView(text(label("打开 AnyApp", "Open AnyApp"), 14f).apply {
                setPadding(dp(10), dp(10), dp(10), dp(10)); minHeight = dp(48)
                isClickable = true; isFocusable = true
                setOnClickListener {
                    expanded = false; render()
                    context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
                        context.startActivity(it.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK))
                    }
                }
            })
            column.addView(View(context).apply { setBackgroundColor(Color.parseColor("#295474A3")) },
                LinearLayout.LayoutParams(-1, dp(1)).apply { topMargin = dp(6); bottomMargin = dp(4) })
            column.addView(text(label("隐藏悬浮入口", "Hide floating button"), 13f).apply {
                setTextColor(Color.parseColor("#ACBCDA")); setPadding(dp(10), dp(10), dp(10), dp(10))
                minHeight = dp(48); isClickable = true; isFocusable = true
                setOnClickListener { performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK); hide(userInitiated = true) }
            }, LinearLayout.LayoutParams(-1, -2))
            val scroll = ScrollView(context).apply { isFillViewport = false; isVerticalScrollBarEnabled = false; addView(column) }
            cluster = scroll
        }
        layoutWindow()
        if (animate && expanded && ValueAnimator.areAnimatorsEnabled()) cluster?.let { v ->
            v.alpha = 0f; v.scaleX = .9f; v.scaleY = .9f
            v.animate().alpha(1f).scaleX(1f).scaleY(1f).setDuration(190).setInterpolator(android.view.animation.DecelerateInterpolator()).start()
        }
    }
    private fun layoutWindow() {
        val context = ctx ?: return; val frame = root ?: return; val entry = ball ?: return; val p = params ?: return
        val width = context.resources.displayMetrics.widthPixels
        if (!expanded) removeCluster()
        val panelWidth = dp(212).coerceAtMost(width - dp(16))
        cluster?.measure(View.MeasureSpec.makeMeasureSpec(panelWidth, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        val desired = (cluster?.measuredHeight ?: dp(88)).coerceAtMost(dp(340))
        val placement = WishEntryGeometry.place(width, usableHeight, anchorX, anchorY,
            dp(52), dp(8), dp(8), panelWidth, desired, expanded)
        // The anchor has its own fixed-size window: Android's window-resize animation
        // must never move the ball while actions unfold beside it.
        entry.layoutParams = FrameLayout.LayoutParams(dp(52), dp(52))
        entry.background = if (expanded) surface(18, true) else null
        entry.alpha = if (starting) .6f else 1f
        entry.contentDescription = if (expanded) label("收起作品动作，长按隐藏", "Collapse app actions, hold to hide") else label("打开作品动作，长按隐藏", "Open app actions, hold to hide")
        val wm = context.getSystemService(WindowManager::class.java)
        p.x = placement.x + placement.ballX; p.y = placement.y + placement.ballY
        p.width = dp(52); p.height = dp(52)
        runCatching { wm.updateViewLayout(frame, p) }
        cluster?.let { v ->
            val cp = clusterParams ?: WindowManager.LayoutParams(placement.width, placement.clusterHeight,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN, PixelFormat.TRANSLUCENT).apply {
                gravity = Gravity.TOP or Gravity.LEFT
                softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING
                windowAnimations = 0
            }
            cp.x = placement.x; cp.y = if (placement.above) placement.y else placement.y + dp(60)
            cp.width = placement.width; cp.height = placement.clusterHeight
            v.pivotX = (placement.ballX + dp(26)).toFloat()
            v.pivotY = if (placement.above) placement.clusterHeight.toFloat() else 0f
            if (clusterParams == null) {
                try { wm.addView(v, cp); clusterParams = cp }
                catch (e: Exception) { removeCluster(); expanded = false; layoutWindow(); throw e }
            } else runCatching { wm.updateViewLayout(v, cp) }
        }
    }
}
