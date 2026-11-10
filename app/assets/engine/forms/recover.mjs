// Runs before DSH loads any work plugins, only when a restore journal exists.
import { join } from 'node:path'
import { homedir } from 'node:os'
import { ProjectStore } from './mobile-core.mjs'
import { WorkReleases } from './releases.mjs'
try {
  const store=new ProjectStore(join(process.env.DSH_HOME || join(homedir(),'.dsh'),'wish'))
  await new WorkReleases(store).recover(process.argv[2])
} catch (_) {
  // Do not log filenames, source or user records from a damaged journal.
  process.stderr.write('anyapp-release-recovery-required\n')
  process.exitCode=1
}
