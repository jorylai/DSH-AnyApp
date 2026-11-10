package io.github.ccch1mneyyy.dsh_app.runtime

import java.io.File

/** Injects a per-App-Form DSH profile into the `dsh web` launch command. */
object ProfileGuest {
    private const val WEB = "/usr/local/bin/dsh web"

    /**
     * Replaces `dsh web` with `dsh --profile <name>`. A missing profile is
     * created from the shipped web template only once; an existing profile is
     * never reset by a later App Form launch.
     */
    fun launchArg(arg: String, profile: String?, rootfs: File): String? {
        val p = profile?.trim().orEmpty()
        if (p.isEmpty() || p == "web") return null
        if (!Regex("^[a-z0-9][a-z0-9-]{0,63}$").matches(p)) return null
        if (!arg.contains("$WEB ") || arg.contains("--profile")) return null
        val fresh = !File(rootfs, "root/.dsh/profiles/$p").isDirectory
        val replacement = if (fresh) {
            "/usr/local/bin/dsh --profile $p --from-default-profile web"
        } else {
            "/usr/local/bin/dsh --profile $p"
        }
        return arg.replaceFirst("$WEB", replacement)
    }
}
