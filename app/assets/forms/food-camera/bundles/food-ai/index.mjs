export const name = 'dsh-wish-food-ai'
export function foodAiActions() {
  return {
    'food.recognize': () => ({ effects: [{ type: 'ai.food', then: 'food.recognized' }] }),
    'food.recognized': args => {
      const result = args.result
      if (!result || !Array.isArray(result.items)) throw new Error('invalid-recognition')
      const items = result.items
      if (items.some(i => !Number.isFinite(i.kcal) || i.kcal < 0 || i.kcal > 5000)) throw new Error('invalid-recognition')
      return { items, name: items.map(i => i.name).join(' + '), kcal: String(items.reduce((n, i) => n + i.kcal, 0)), notes: result.needsManual || result.confidence < 0.6 ? '识别不确定，请检查食物和热量后再保存。' : result.notes || '识别结果可修改。' }
    },
  }
}
export function apply(ctx) {
  ctx.inject(['appForm'], ctx => {
    const api = ctx.get('appForm')
    ctx.effect(() => api.register('local-food-camera', foodAiActions()))
  })
}
