import { createRequire } from 'node:module'
import { pathToFileURL } from 'node:url'

export async function hostImport(specifier) {
  for (const anchor of [process.argv[1], '/opt/dsh/node_modules/@deepseek-ai/dsh/lib/bin.js']) {
    try { return await import(pathToFileURL(createRequire(anchor).resolve(specifier)).href) } catch (_) {}
  }
  throw new Error('wish-host-dependency-unavailable')
}
