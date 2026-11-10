/**
 * Host half of the 热量教练 bundle.
 *
 * The feature UI, camera, AI, reminders and health-app reading all run in the
 * Client half against the Android DSH host bridge. This half intentionally
 * keeps no Host service of its own: it must not read credentials, install a
 * second accessibility service, or duplicate the host's reminder scheduler.
 * It exists so the bundle is a normal Loader entry with a disposable lifecycle.
 */
export const name = 'dsh-wish-calorie-coach'

export function apply() {
  // No Host-side resources: every capability this work uses belongs to the
  // shared Android host bridge, which the Client half calls directly.
}
