package io.github.ccch1mneyyy.dsh_app.runtime
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class ProfileGuestTest {
    @get:Rule val temp = TemporaryFolder()
    private val command = "exec /usr/local/bin/dsh web --patch /etc/dsh-app/dsh-web.patch.yml"
    @Test fun profileKeepsAccountSearchAndSpeechBridges() {
        val auth = AppAuthGuest.launchArg(command)!!
        val search = SessionSearchGuest.launchArg(auth)!!
        val speech = SpeechGuest.launchArg(search)!!
        val work = ProfileGuest.launchArg(speech, "app-local-test", temp.newFolder())!!
        assertTrue(work.contains("--patch ${AppAuthGuest.PATCH}"))
        assertTrue(work.contains("--patch ${SessionSearchGuest.PATCH}"))
        assertTrue(work.contains("--patch ${SpeechGuest.PATCH}"))
        assertTrue(work.contains("--profile app-local-test"))
    }
    @Test fun createsOnlyMissingProfile() {
        val root = temp.newFolder()
        val first = ProfileGuest.launchArg(command, "app-local-food-camera", root)!!
        assertFalse(first.contains("dsh web --profile"))
        assertTrue(first.contains("--profile app-local-food-camera --from-default-profile web"))
        java.io.File(root, "root/.dsh/profiles/app-local-food-camera").mkdirs()
        val next = ProfileGuest.launchArg(command, "app-local-food-camera", root)!!
        assertFalse(next.contains("--from-default-profile"))
    }
    @Test fun rejectsUnsafeNamesAndKeepsWebDefault() {
        val root = temp.newFolder()
        assertNull(ProfileGuest.launchArg(command, "../web;exit", root))
        assertNull(ProfileGuest.launchArg(command, "web", root))
    }
    @Test fun appFormOverlayWorksForWebAndCustomProfiles() {
        assertTrue(AppFormGuest.launchArg(command)!!.contains("--patch ${AppFormGuest.PATCH}"))
        val custom = ProfileGuest.launchArg(command, "app-local-test", temp.newFolder())!!
        val patched = AppFormGuest.launchArg(custom)!!
        assertTrue(patched.contains("--profile app-local-test"))
        assertTrue(patched.contains("--patch ${AppFormGuest.PATCH}"))
        assertNull(AppFormGuest.launchArg("--unrelated"))
    }
    @Test fun interruptedRestoreRecoversBeforeThePluginCanLoad() {
        val root=temp.newFolder()
        val profiled=ProfileGuest.launchArg(command,"app-local-test",root)!!
        assertFalse(AppFormGuest.launchArg(profiled,"app-local-test",root)!!.contains("recover.mjs"))
        val journal=java.io.File(root,"root/.dsh/wish/work-versions/local-test/pending.json")
        journal.parentFile.mkdirs();journal.writeText("{}")
        val patched=AppFormGuest.launchArg(profiled,"app-local-test",root)!!
        assertTrue(patched.contains("/usr/local/bin/node /opt/dsh-app/forms/recover.mjs local-test && exec /usr/local/bin/dsh "))
        assertFalse(AppFormGuest.launchArg(profiled,"app-local-other",root)!!.contains("recover.mjs"))
    }
}
