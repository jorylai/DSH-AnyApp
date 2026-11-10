import test from 'node:test'
import assert from 'node:assert/strict'
import { mkdtemp, cp, readFile, writeFile, mkdir, rm, symlink, access } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { FormStore, validate } from '../../app/assets/engine/forms/store.mjs'
import { foodActions, normalizeItems } from '../../app/assets/forms/food-camera/bundles/food-data/index.mjs'
import { foodAiActions } from '../../app/assets/forms/food-camera/bundles/food-ai/index.mjs'
const sample = fileURLToPath(new URL('../../app/assets/forms/food-camera/', import.meta.url))
async function setup(t) {
  const base = await mkdtemp(join(tmpdir(), 'wish-test-'))
  t.after(() => rm(base, { recursive: true, force: true }))
  const store = new FormStore(join(base, 'wish'))
  await store.begin('local-food-camera')
  await cp(sample, store.workspace('local-food-camera'), { recursive: true })
  return store
}
test('an empty creator workspace reports a missing artifact instead of a generic identity error', async t => {
  const store = await setup(t)
  await store.begin('local-empty')
  await assert.rejects(store.prepare('local-empty'), /missing-artifact/)
  assert.deepEqual(await store.list(), [])
})
test('real template prepares a content-addressed release without publishing', async t => {
  const store = await setup(t)
  const a = await store.prepare('local-food-camera')
  const b = await store.prepare('local-food-camera')
  assert.equal(a.hash, b.hash)
  assert.equal(a.specs.length, 2)
  assert.deepEqual(await store.list(), [])
  assert.equal(a.manifest.runtime.profile, 'app-local-food-camera')
  for (const spec of a.specs) await access(join(spec, 'index.mjs'))
})
test('reject malformed identity, unsupported components, missing input bindings and undeclared actions', async t => {
  const store = await setup(t)
  const original = await store.prepare('local-food-camera')
  const mutate = f => { const x = structuredClone(original); f(x); assert.throws(() => validate(x.manifest, x.view, 'local-food-camera')) }
  mutate(x => x.manifest.runtime.profile = 'web')
  mutate(x => x.manifest.data.namespace = 'another-app')
  mutate(x => x.view.components.push({ type: 'webview', url: 'https://example.org' }))
  mutate(x => x.view.components.push({ type: 'input', label: 'missing' }))
  mutate(x => x.view.components.push({ type: 'button', action: 'host.deleteAll' }))
  await assert.rejects(store.begin('../escape'))
})
test('does not follow symlinked artifacts or install dependency scripts', async t => {
  const store = await setup(t)
  const workspace = store.workspace('local-food-camera')
  await symlink('/etc/passwd', join(workspace, 'outside.txt'))
  await assert.rejects(store.prepare('local-food-camera'), /symlink/)
  await rm(join(workspace, 'outside.txt'))
  const path = join(workspace, 'bundles/food-data/package.json')
  const pkg = JSON.parse(await readFile(path, 'utf8')); pkg.scripts = { postinstall: 'exit 1' }
  await writeFile(path, JSON.stringify(pkg))
  await assert.rejects(store.prepare('local-food-camera'), /self-contained/)
})
test('accept binds the reviewed digest; clone preserves original data and uninstall touches only its form', async t => {
  const store = await setup(t)
  const form = await store.prepare('local-food-camera')
  await assert.rejects(store.accept('local-food-camera', 'bad'), /changed/)
  await store.accept('local-food-camera', form.hash)
  await store.write('local-food-camera', 'todayFood', [{ name: 'original' }])
  await store.clone('local-copy', 'local-food-camera')
  const clone = await store.prepare('local-copy')
  assert.equal(clone.manifest.runtime.profile, 'app-local-copy')
  await store.write('local-copy', 'todayFood', [{ name: 'changed' }])
  assert.deepEqual(await store.read('local-food-camera', 'todayFood'), [{ name: 'original' }])
  await store.accept('local-copy', clone.hash)
  await assert.rejects(store.prepare('local-food-camera'), /clone-before-editing/)
  await store.remove('local-copy')
  assert.deepEqual((await store.list()).map(f => f.manifest.id), ['local-food-camera'])
  assert.deepEqual(await store.read('local-food-camera', 'todayFood'), [{ name: 'original' }])
})
test('food data starts empty, sums items, persists structured food and separates local days', async t => {
  const store = await setup(t)
  const api = { read: (c, fallback) => store.read('local-food-camera', c, fallback), write: (c, data) => store.write('local-food-camera', c, data) }
  const actions = foodActions(api, () => new Date('2026-11-05T23:30:00Z'))
  assert.equal((await actions['food.today']({ today: '2026-11-06' })).todayKcal, 0)
  const result = await actions['food.save']({ today: '2026-11-06', name: '米饭 + 鸡蛋', kcal: '254', items: [{ name: '米饭', kcal: 174, staple: true }, { name: '鸡蛋', kcal: 80 }] })
  assert.equal(result.todayKcal, 254)
  assert.equal(result.todayFood[0].items.length, 2)
  assert.deepEqual(result.todayFood[0].staple, ['米饭'])
  assert.equal((await actions['food.today']({ today: '2026-11-05' })).todayKcal, 0)
  const reopened = foodActions(api)
  assert.equal((await reopened['food.today']({ today: '2026-11-06' })).todayKcal, 254)
  await reopened['food.delete']({ today: '2026-11-06', id: result.todayFood[0].id })
  assert.equal((await reopened['food.today']({ today: '2026-11-06' })).todayKcal, 0)
  assert.throws(() => normalizeItems([{ name: 'bad', kcal: -2 }]))
})
test('manual correction remains consistent and concurrent saves do not lose records', async t => {
  const store = await setup(t)
  const actions = foodActions({ read: (c, d) => store.read('local-food-camera', c, d), write: (c, d) => store.write('local-food-camera', c, d) })
  await Promise.all(Array.from({ length: 12 }, (_, i) => store.serial(() => actions['food.save']({ today: '2026-11-06', kcal: 100, name: `meal ${i}`, items: [{ name: 'estimate', kcal: 999 }] }))))
  const result = await actions['food.today']({ today: '2026-11-06' })
  assert.equal(result.todayFood.length, 12)
  assert.equal(result.todayKcal, 1200)
  assert.ok(result.todayFood.every(r => r.source === 'manual' && r.items[0].kcal === 100))
})
test('AI plugin requests host consent path and low confidence stays visibly uncertain', () => {
  const actions = foodAiActions()
  assert.deepEqual(actions['food.recognize'](), { effects: [{ type: 'ai.food', then: 'food.recognized' }] })
  const result = actions['food.recognized']({ result: { items: [{ name: 'rice', kcal: 174 }], totalKcal: 10000, confidence: 0.1 } })
  assert.equal(result.kcal, '174')
  assert.match(result.notes, /不确定/)
})
