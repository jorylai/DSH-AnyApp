/**
 * Host half of the 比价雷达 bundle.
 *
 * Every capability is owned by the shared Android DSH host: real phone
 * automation (agent + mcp__phone__*), the logged-in model, camera/OCR,
 * system reminders, file export and the work-scoped data store. This half
 * keeps no Host service of its own, so it never reads credentials, never
 * installs another accessibility service and never duplicates the scheduler.
 */
export const name = 'dsh-wish-price-radar'

export function apply() {
  // No Host-side resources: the comparison runs through the shared host bridge.
}
