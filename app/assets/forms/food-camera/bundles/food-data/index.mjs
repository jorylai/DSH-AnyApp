import { randomUUID } from 'node:crypto'
export const name = 'dsh-wish-food-data'
export function normalizeItems(items) {
  if (!Array.isArray(items) || !items.length || items.length > 60) throw new Error('invalid-food-items')
  return items.map(i => {
    if (typeof i.name !== 'string' || !i.name.trim() || !Number.isFinite(i.kcal) || i.kcal < 0 || i.kcal > 5000) throw new Error('invalid-food-item')
    return { name: i.name.trim().slice(0, 120), kcal: Math.round(i.kcal), amount: Number.isFinite(i.amount) && i.amount >= 0 ? i.amount : 1, unit: typeof i.unit === 'string' ? i.unit.slice(0, 20) : '份', staple: i.staple === true, confidence: Math.max(0, Math.min(1, Number(i.confidence) || 0)) }
  })
}
export function foodActions(api, now = () => new Date()) {
  const day = args => {
    if (typeof args.today !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(args.today)) throw new Error('invalid-local-date')
    return args.today
  }
  const today = async args => {
    const records = await api.read('todayFood', [])
    const todayFood = records.filter(r => r.date === day(args))
    return { todayFood, todayKcal: todayFood.reduce((sum, r) => sum + r.items.reduce((n, i) => n + i.kcal, 0), 0) }
  }
  return {
    'food.today': today,
    'food.save': async args => {
      const kcal = Number(args.kcal)
      if (!Number.isFinite(kcal) || kcal < 1 || kcal > 5000) throw new Error('invalid-calories')
      let items = args.items?.length ? normalizeItems(args.items) : null
      const manual = !items || Math.round(kcal) !== items.reduce((n, i) => n + i.kcal, 0) || args.name !== items.map(i => i.name).join(' + ')
      if (manual) items = normalizeItems([{ name: args.name || '这一餐', kcal, amount: 1, unit: '份' }])
      const records = await api.read('todayFood', [])
      const totalKcal = items.reduce((n, i) => n + i.kcal, 0)
      records.push({ id: randomUUID(), date: day(args), createdAt: now().toISOString(), name: args.name || items.map(i => i.name).join(' + '), items, totalKcal, source: manual ? 'manual' : 'ai', staple: items.filter(i => i.staple).map(i => i.name), stapleText: items.filter(i => i.staple).map(i => i.name).join('、') })
      await api.write('todayFood', records)
      return { ...await today(args), name: '', kcal: '', items: [], notes: '已保存。', photo: null }
    },
    'food.delete': async args => {
      if (typeof args.id !== 'string') throw new Error('invalid-record-id')
      await api.write('todayFood', (await api.read('todayFood', [])).filter(r => r.id !== args.id))
      return today(args)
    },
  }
}
export function apply(ctx) {
  ctx.inject(['appForm'], ctx => {
    const api = ctx.get('appForm')
    ctx.effect(() => api.register('local-food-camera', foodActions(api)))
  })
}
