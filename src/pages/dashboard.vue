<template>
  <main class="dash">
    <div class="container">
      <!-- Header -->
      <header class="dash__head">
        <div>
          <h1 class="dash__title">{{ $t('dashboard.title') }}</h1>
          <p class="dash__hello">{{ $t('dashboard.greeting', { name: displayName }) }}</p>
        </div>
        <div class="dash__meta">
          <span class="pill pill--fire">🔥 {{ $t('dashboard.streak', { days: streakDays }) }}</span>
          <span class="pill pill--exam">📅 {{ $t('dashboard.exam', { days: examDays }) }}</span>
          <button type="button" class="btn btn--ghost" @click="logout">{{ $t('dashboard.logout') }}</button>
        </div>
      </header>

      <!-- Sección: Progreso -->
      <section class="section">
        <h2 class="section__title">{{ $t('dashboard.sections.progress') }}</h2>

        <div class="cards cards--progress">
          <!-- Progreso general -->
          <article class="card">
            <div class="card__top">
              <DonutProgress :value="general" :size="132" />
              <div>
                <h3 class="card__title">{{ $t('dashboard.cards.general') }}</h3>
                <p class="card__hint">{{ $t('dashboard.cards.generalHint') }}</p>
              </div>
            </div>

            <button type="button" class="card__toggle" @click="toggle('general')">
              {{ isOpen('general') ? $t('dashboard.seeLess') : $t('dashboard.seeMore') }}
              <span :class="['chev', { 'chev--up': isOpen('general') }]">▾</span>
            </button>

            <div v-if="isOpen('general')" class="card__expand">
              <p class="mini-label">{{ $t('dashboard.cards.byBlock') }}</p>
              <ul class="bars">
                <li v-for="b in blocks" :key="b.name">
                  <span class="bars__name">{{ b.name }}</span>
                  <span class="bars__track"><span class="bars__fill" :style="{ width: b.pct + '%' }" /></span>
                  <span class="bars__pct">{{ b.pct }}%</span>
                </li>
              </ul>
              <p class="mini-label mini-label--warn">{{ $t('dashboard.cards.weakTopics') }}</p>
              <div class="tags">
                <span v-for="w in weakTopics" :key="w" class="tag tag--warn">{{ w }}</span>
              </div>
            </div>
          </article>

          <!-- Nota media -->
          <article class="card">
            <div class="card__top">
              <div class="bignum">
                <strong>{{ average.toFixed(1) }}</strong>
                <span class="bignum__max">/10</span>
              </div>
              <div>
                <h3 class="card__title">{{ $t('dashboard.cards.average') }}</h3>
                <p class="card__hint">{{ $t('dashboard.cards.averageHint') }}</p>
              </div>
            </div>

            <button type="button" class="card__toggle" @click="toggle('average')">
              {{ isOpen('average') ? $t('dashboard.seeLess') : $t('dashboard.seeMore') }}
              <span :class="['chev', { 'chev--up': isOpen('average') }]">▾</span>
            </button>

            <div v-if="isOpen('average')" class="card__expand">
              <p class="mini-label">{{ $t('dashboard.cards.gradeHistory') }}</p>
              <svg class="spark" viewBox="0 0 240 70" preserveAspectRatio="none" aria-hidden="true">
                <polyline :points="sparkPoints" fill="none" stroke="var(--brand)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
                <circle v-for="(p, i) in sparkCoords" :key="i" :cx="p.x" :cy="p.y" r="3.5" fill="var(--brand)" />
              </svg>
              <div class="spark__labels">
                <span v-for="(g, i) in grades" :key="i">{{ g.toFixed(1) }}</span>
              </div>
            </div>
          </article>

          <!-- Objetivo de hoy -->
          <article class="card card--goal">
            <div class="card__top">
              <DonutProgress :value="Math.round((goalDone / goalTotal) * 100)" :size="132">
                <div class="goal-center">
                  <strong>{{ goalDone }}</strong>
                  <span>/ {{ goalTotal }}</span>
                </div>
              </DonutProgress>
              <div>
                <h3 class="card__title">{{ $t('dashboard.cards.goal') }}</h3>
                <p class="card__hint">{{ $t('dashboard.cards.goalHint', { total: goalTotal }) }}</p>
              </div>
            </div>
          </article>

          <!-- Racha -->
          <article class="card">
            <div class="card__top">
              <div class="fire">🔥<strong>{{ streakDays }}</strong></div>
              <div>
                <h3 class="card__title">{{ $t('dashboard.cards.streakTitle') }}</h3>
                <p class="card__hint">{{ $t('dashboard.cards.streakHint') }}</p>
              </div>
            </div>
            <div class="heatmap">
              <span
                v-for="(d, i) in week"
                :key="i"
                class="heatmap__cell"
                :style="{ opacity: 0.2 + d * 0.8 }"
                :title="`Día ${i + 1}`"
              />
            </div>
          </article>
        </div>
      </section>

      <!-- Sección: Tests -->
      <section class="section">
        <h2 class="section__title">{{ $t('dashboard.sections.tests') }}</h2>
        <p v-if="!dashTests.length" class="community-empty">{{ $t('test.noTests') }}</p>
        <div v-else class="cards cards--tests">
          <NuxtLink
            v-for="t in dashTests"
            :key="t.id"
            :to="localePath(`/test/${t.id}`)"
            class="test"
          >
            <div class="test__head">
              <span class="test__topic">{{ t.es_simulacro ? '⏱ ' + $t('test.simulacro') : 'Test' }}</span>
            </div>
            <h3 class="test__title">{{ t.titulo }}</h3>
            <p class="test__meta">{{ $t('test.questions', { n: t.num_preguntas }) }}</p>
            <div class="test__foot">
              <span class="test__go">{{ $t('test.start') }} →</span>
            </div>
          </NuxtLink>
        </div>
        <div class="community-more">
          <NuxtLink :to="localePath('/tests')" class="btn btn--ghost">Ver todos los tests</NuxtLink>
        </div>
      </section>

      <!-- Anuncio (banner entre secciones) -->
      <AdSlot format="banner" class="dash__ad" />

      <!-- Sección: Comunidad -->
      <section class="section">
        <div class="section__headrow">
          <div>
            <h2 class="section__title">{{ $t('dashboard.sections.community') }}</h2>
            <p class="section__sub">{{ $t('dashboard.community.subtitle') }}</p>
          </div>
          <NuxtLink :to="localePath('/comunidad')" class="btn btn--accent">＋ {{ $t('dashboard.community.new') }}</NuxtLink>
        </div>

        <p v-if="!recentPosts.length" class="community-empty">{{ $t('comunidad.empty') }}</p>

        <ul v-else class="feed">
          <template v-for="(p, idx) in recentPosts" :key="p.id">
            <li class="post">
              <div class="post__votes">
                <button
                  type="button"
                  class="vote"
                  :class="{ 'vote--on': p.voted }"
                  :aria-pressed="p.voted"
                  aria-label="Votar"
                  @click="toggleVote(p)"
                >▲</button>
                <strong>{{ p.votos }}</strong>
              </div>
              <NuxtLink :to="localePath(`/comunidad/${p.id}`)" class="post__body">
                <div class="post__meta">
                  <span class="post__author">{{ p.author }}</span>
                </div>
                <h3 class="post__title">{{ p.titulo }}</h3>
                <p v-if="p.cuerpo" class="post__snippet">{{ p.cuerpo }}</p>
                <div class="post__foot">
                  <span>💬 {{ $t('dashboard.community.comments', { n: p.comentarios }) }}</span>
                </div>
              </NuxtLink>
            </li>
            <li v-if="idx === 1" class="feed__ad">
              <AdSlot format="infeed" />
            </li>
          </template>
        </ul>

        <div class="community-more">
          <NuxtLink :to="localePath('/comunidad')" class="btn btn--ghost">{{ $t('comunidad.seeAll') }}</NuxtLink>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const localePath = useLocalePath()

const displayName = computed(() => {
  const u = user.value
  const meta = (u?.user_metadata as { full_name?: string } | undefined)
  return meta?.full_name || u?.email?.split('@')[0] || 'opositor'
})

async function logout() {
  await supabase.auth.signOut()
  await navigateTo(localePath('/auth'))
}

/* ---------------- Progreso real ---------------- */
const examDays = 87 // TODO: fecha de examen real por oposición
const goalTotal = 30

async function fetchStats() {
  if (!user.value) return { intentos: [] as any[], resp: [] as any[] }
  const { data: intentos } = await supabase
    .from('intentos')
    .select('aciertos,fallos,total,started_at')
    .eq('user_id', user.value.id)
    .order('started_at', { ascending: true })
  const { data: resp } = await supabase
    .from('respuestas')
    .select('es_correcta,preguntas(temas(titulo,bloques(nombre)))')
  return { intentos: intentos || [], resp: resp || [] }
}
const { data: stats } = await useAsyncData('dash-stats', fetchStats, { default: () => ({ intentos: [], resp: [] }) })

const intentos = computed<any[]>(() => stats.value?.intentos || [])
const resp = computed<any[]>(() => stats.value?.resp || [])

const totalPreg = computed(() => intentos.value.reduce((s, i) => s + (i.total || 0), 0))
const totalAciertos = computed(() => intentos.value.reduce((s, i) => s + (i.aciertos || 0), 0))
const general = computed(() => totalPreg.value ? Math.round((totalAciertos.value / totalPreg.value) * 100) : 0)
const average = computed(() => {
  const w = intentos.value.filter((i) => i.total > 0)
  return w.length ? w.reduce((s, i) => s + (i.aciertos / i.total) * 10, 0) / w.length : 0
})
const grades = computed<number[]>(() =>
  intentos.value.filter((i) => i.total > 0).slice(-6).map((i) => +((i.aciertos / i.total) * 10).toFixed(1))
)

const goalDone = computed(() => {
  const today = new Date().toDateString()
  return intentos.value
    .filter((i) => new Date(i.started_at).toDateString() === today)
    .reduce((s, i) => s + (i.total || 0), 0)
})

const streakDays = computed(() => {
  const days = new Set(intentos.value.map((i) => new Date(i.started_at).toDateString()))
  const d = new Date()
  if (!days.has(d.toDateString())) d.setDate(d.getDate() - 1)
  let s = 0
  while (days.has(d.toDateString())) { s++; d.setDate(d.getDate() - 1) }
  return s
})

function aggByKey(keyFn: (r: any) => string | undefined) {
  const map: Record<string, { ok: number, total: number }> = {}
  for (const r of resp.value) {
    const k = keyFn(r)
    if (!k) continue
    map[k] = map[k] || { ok: 0, total: 0 }
    map[k].total++
    if (r.es_correcta) map[k].ok++
  }
  return map
}

const blocks = computed(() => {
  const m = aggByKey((r) => r.preguntas?.temas?.bloques?.nombre)
  return Object.entries(m)
    .map(([name, v]) => ({ name, pct: v.total ? Math.round((v.ok / v.total) * 100) : 0 }))
    .sort((a, b) => b.pct - a.pct)
})

const weakTopics = computed(() => {
  const m = aggByKey((r) => r.preguntas?.temas?.titulo)
  return Object.entries(m)
    .map(([titulo, v]) => ({ titulo, acc: v.ok / v.total }))
    .sort((a, b) => a.acc - b.acc)
    .slice(0, 3)
    .map((x) => x.titulo)
})

const week = computed(() => {
  const out: number[] = []
  for (let i = 6; i >= 0; i--) {
    const d = new Date(); d.setDate(d.getDate() - i)
    const key = d.toDateString()
    const cnt = intentos.value
      .filter((x) => new Date(x.started_at).toDateString() === key)
      .reduce((s, x) => s + (x.total || 0), 0)
    out.push(cnt > 0 ? Math.min(1, 0.3 + cnt / 30) : 0.12)
  }
  return out
})

// Tests reales (top 4)
async function fetchDashTests() {
  const { data } = await supabase
    .from('tests')
    .select('id,titulo,num_preguntas,es_simulacro,created_at')
    .order('created_at', { ascending: true })
    .limit(4)
  return data || []
}
const { data: dashTests } = await useAsyncData('dash-tests', fetchDashTests, { default: () => [] as any[] })

// Comunidad: posts reales recientes (top 3)
function authorName(prof: any) {
  return prof?.full_name || prof?.username || 'Opositor'
}
async function fetchRecentPosts() {
  const { data: rows } = await supabase
    .from('posts')
    .select('id,titulo,cuerpo,created_at,user_id,comentarios(count),votos(count)')
    .order('created_at', { ascending: false })
    .limit(3)
  const list = rows || []
  const ids = [...new Set(list.map((p: any) => p.user_id))]
  const { data: profs } = ids.length
    ? await supabase.from('profiles').select('id,full_name,username').in('id', ids)
    : { data: [] as any[] }
  const map = Object.fromEntries((profs || []).map((p: any) => [p.id, p]))

  const { data: mine } = user.value
    ? await supabase.from('votos').select('post_id').eq('user_id', user.value.id)
    : { data: [] as any[] }
  const voted = new Set((mine || []).map((v: any) => v.post_id))

  return list.map((p: any) => ({
    ...p,
    author: authorName(map[p.user_id]),
    comentarios: p.comentarios?.[0]?.count ?? 0,
    votos: p.votos?.[0]?.count ?? 0,
    voted: voted.has(p.id)
  }))
}
const { data: recentPosts, refresh: refreshPosts } = await useAsyncData('dash-recent-posts', fetchRecentPosts, { default: () => [] as any[] })

async function toggleVote(p: any) {
  if (!user.value) return
  if (p.voted) {
    await supabase.from('votos').delete().eq('post_id', p.id).eq('user_id', user.value.id)
  } else {
    await supabase.from('votos').upsert({ post_id: p.id, user_id: user.value.id, valor: 1 })
  }
  await refreshPosts()
}

/* ---------------- Expandibles ---------------- */
const open = ref<Record<string, boolean>>({})
const toggle = (k: string) => { open.value[k] = !open.value[k] }
const isOpen = (k: string) => !!open.value[k]

/* Sparkline de notas */
const sparkCoords = computed(() => {
  const g = grades.value
  const max = 10, min = 0
  const denom = g.length > 1 ? g.length - 1 : 1
  return g.map((val, i) => ({
    x: (i / denom) * 240,
    y: 70 - ((val - min) / (max - min)) * 70
  }))
})
const sparkPoints = computed(() => sparkCoords.value.map(p => `${p.x},${p.y}`).join(' '))
</script>

<style scoped>
.dash {
  padding-block: var(--space-7) var(--space-10);
  background: var(--bg-warm);
  min-height: 100vh;
}

/* Header */
.dash__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
  margin-bottom: var(--space-8);
}
.dash__title {
  margin: 0;
  font-size: clamp(1.7rem, 4vw, 2.4rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}
.dash__hello {
  margin: var(--space-1) 0 0;
  color: var(--muted);
}
.dash__meta {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  flex-wrap: wrap;
}
.pill {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.45rem 0.85rem;
  border-radius: var(--radius-pill);
  font-weight: 700;
  font-size: 0.85rem;
  border: 1px solid var(--line);
  background: var(--white);
}
.pill--fire { color: #c2410c; }
.pill--exam { color: var(--brand-700); }

/* Secciones */
.section { margin-bottom: var(--space-8); }
.section__title {
  margin: 0 0 var(--space-5);
  font-size: 1.3rem;
  font-weight: 800;
  letter-spacing: -0.01em;
}
.section__headrow {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
  margin-bottom: var(--space-5);
}
.section__headrow .section__title { margin-bottom: var(--space-1); }
.section__sub { margin: 0; color: var(--muted); font-size: 0.95rem; }

/* Cards genéricas */
.cards { display: grid; gap: var(--space-4); }
.cards--progress { grid-template-columns: repeat(auto-fit, minmax(270px, 1fr)); }
.cards--tests { grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); }

.card {
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: var(--space-5);
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
}
.card__top {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}
.card__title { margin: 0; font-size: 1.05rem; font-weight: 700; }
.card__hint { margin: var(--space-1) 0 0; color: var(--muted); font-size: 0.88rem; }

.card__toggle {
  margin-top: var(--space-4);
  align-self: flex-start;
  background: none;
  border: none;
  padding: 0;
  color: var(--brand-700);
  font-weight: 700;
  font-size: 0.88rem;
  font-family: inherit;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}
.chev { transition: transform 0.2s ease; }
.chev--up { transform: rotate(180deg); }
.card__expand {
  margin-top: var(--space-4);
  padding-top: var(--space-4);
  border-top: 1px dashed var(--line);
}

.bignum {
  display: flex;
  align-items: baseline;
  width: 132px;
  justify-content: center;
}
.bignum strong { font-size: 3rem; font-weight: 800; color: var(--brand); line-height: 1; }
.bignum__max { color: var(--muted); font-weight: 700; margin-left: 2px; }

.goal-center { text-align: center; line-height: 1.1; }
.goal-center strong { font-size: 1.6rem; font-weight: 800; color: var(--ink); }
.goal-center span { display: block; font-size: 0.8rem; color: var(--muted); }

.fire {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  font-size: 1.6rem;
  width: 132px;
  justify-content: center;
}
.fire strong { font-size: 2.4rem; font-weight: 800; color: #c2410c; }

/* Expand: barras por bloque */
.mini-label {
  margin: 0 0 var(--space-3);
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--muted);
}
.mini-label--warn { margin-top: var(--space-5); color: #b45309; }
.bars { list-style: none; margin: 0; padding: 0; display: grid; gap: var(--space-3); }
.bars li { display: grid; grid-template-columns: 1fr auto; align-items: center; gap: 0.5rem 0.75rem; }
.bars__name { font-size: 0.85rem; font-weight: 600; }
.bars__pct { font-size: 0.8rem; font-weight: 700; color: var(--brand-700); }
.bars__track {
  grid-column: 1 / -1;
  height: 8px;
  border-radius: var(--radius-pill);
  background: var(--brand-soft);
  overflow: hidden;
  order: 3;
}
.bars li { grid-template-areas: 'name pct' 'track track'; }
.bars__name { grid-area: name; }
.bars__pct { grid-area: pct; text-align: right; }
.bars__track { grid-area: track; }
.bars__fill {
  display: block;
  height: 100%;
  border-radius: var(--radius-pill);
  background: linear-gradient(90deg, var(--brand), #34d399);
}

.tags { display: flex; flex-wrap: wrap; gap: 0.4rem; }
.tag {
  font-size: 0.78rem;
  font-weight: 700;
  padding: 0.25rem 0.6rem;
  border-radius: var(--radius-pill);
}
.tag--warn { background: #fef3c7; color: #b45309; }
.tag--reco { background: var(--accent-soft); color: var(--accent-600); }
.tag--hot { background: #ffe4e6; color: #e11d48; }

/* Sparkline */
.spark { width: 100%; height: 70px; }
.spark__labels {
  display: flex;
  justify-content: space-between;
  margin-top: var(--space-2);
  font-size: 0.72rem;
  color: var(--muted);
  font-weight: 600;
}

/* Heatmap racha */
.heatmap { display: flex; gap: 6px; margin-top: var(--space-5); }
.heatmap__cell {
  flex: 1;
  height: 26px;
  border-radius: 6px;
  background: var(--brand);
}

/* Tests */
.test {
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: var(--space-5);
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  text-decoration: none;
  color: inherit;
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.test:hover { transform: translateY(-4px); box-shadow: var(--shadow); }
.test__go { font-weight: 700; color: var(--brand-700); font-size: 0.9rem; margin-top: auto; }
.test__head { display: flex; align-items: center; justify-content: space-between; gap: 0.5rem; margin-bottom: var(--space-2); }
.test__topic { font-size: 0.78rem; font-weight: 700; color: var(--brand-700); background: var(--brand-soft); padding: 0.2rem 0.55rem; border-radius: var(--radius-pill); }
.test__title { margin: 0 0 var(--space-1); font-size: 1.05rem; font-weight: 700; }
.test__meta { margin: 0 0 var(--space-4); color: var(--muted); font-size: 0.85rem; }
.test__track { height: 8px; border-radius: var(--radius-pill); background: var(--brand-soft); overflow: hidden; margin-bottom: var(--space-3); }
.test__fill { display: block; height: 100%; border-radius: var(--radius-pill); background: linear-gradient(90deg, var(--brand), #34d399); }
.test__foot { display: flex; align-items: center; justify-content: space-between; margin-top: auto; }
.test__pct { font-weight: 800; color: var(--brand-700); }
.test__btn { padding: 0.5rem 1.1rem; font-size: 0.9rem; }

/* Comunidad estilo Reddit */
.feed { list-style: none; margin: 0; padding: 0; display: grid; gap: var(--space-3); }
.post {
  display: flex;
  gap: var(--space-4);
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: var(--space-5);
  box-shadow: var(--shadow-sm);
}
.post__votes {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.2rem;
  min-width: 42px;
}
.post__votes strong { font-size: 0.95rem; font-weight: 800; }
.vote {
  display: grid;
  place-items: center;
  border: none;
  background: var(--bg-warm);
  color: var(--muted);
  width: 34px;
  height: 34px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: background 0.15s ease, color 0.15s ease;
}
.vote:hover { background: var(--brand-soft); color: var(--brand); }
.vote--on { background: var(--brand); color: #fff; }
.post__meta { display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; font-size: 0.82rem; color: var(--muted); margin-bottom: var(--space-1); }
.post__opo { font-weight: 700; color: var(--brand-700); }
.post__title { margin: 0 0 var(--space-1); font-size: 1.05rem; font-weight: 700; }
.post__snippet { margin: 0 0 var(--space-3); color: var(--muted); font-size: 0.92rem; }
.post__foot { font-size: 0.82rem; color: var(--muted); font-weight: 600; }

.post__body { flex: 1; text-decoration: none; color: inherit; display: block; }
.community-empty { color: var(--muted); background: var(--white); border: 1px dashed var(--line); border-radius: var(--radius); padding: var(--space-6); text-align: center; }
.community-more { margin-top: var(--space-4); text-align: center; }

/* Anuncios */
.dash__ad { margin-bottom: var(--space-8); }
.feed__ad { list-style: none; }

@media (max-width: 560px) {
  .card__top { flex-direction: column; text-align: center; align-items: center; }
  .dash__meta { width: 100%; }
}
</style>
