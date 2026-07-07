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
        <div class="cards cards--tests">
          <article v-for="t in tests" :key="t.id" class="test">
            <div class="test__head">
              <span class="test__topic">{{ t.topic }}</span>
              <span v-if="t.recommended" class="tag tag--reco">★ {{ $t('dashboard.tests.recommended') }}</span>
            </div>
            <h3 class="test__title">{{ t.title }}</h3>
            <p class="test__meta">{{ $t('dashboard.tests.questions', { n: t.questions }) }}</p>
            <div class="test__track"><span class="test__fill" :style="{ width: t.progress + '%' }" /></div>
            <div class="test__foot">
              <span class="test__pct">{{ t.progress }}%</span>
              <button type="button" class="btn btn--primary test__btn">
                {{ t.progress === 0 ? $t('dashboard.tests.start') : (t.progress === 100 ? $t('dashboard.tests.review') : $t('dashboard.tests.continue')) }}
              </button>
            </div>
          </article>
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
          <button type="button" class="btn btn--accent">＋ {{ $t('dashboard.community.new') }}</button>
        </div>

        <ul class="feed">
          <template v-for="(p, idx) in posts" :key="p.id">
            <li class="post">
              <div class="post__votes">
                <button type="button" class="vote" aria-label="Votar">▲</button>
                <strong>{{ p.votes }}</strong>
              </div>
              <div class="post__body">
                <div class="post__meta">
                  <span class="post__opo">{{ p.opo }}</span>
                  <span class="post__author">· {{ p.author }}</span>
                  <span v-if="p.hot" class="tag tag--hot">🔥 {{ $t('dashboard.community.hot') }}</span>
                </div>
                <h3 class="post__title">{{ p.title }}</h3>
                <p class="post__snippet">{{ p.snippet }}</p>
                <div class="post__foot">
                  <span>💬 {{ $t('dashboard.community.comments', { n: p.comments }) }}</span>
                </div>
              </div>
            </li>
            <!-- Anuncio nativo intercalado en el feed -->
            <li v-if="idx === 1" class="feed__ad">
              <AdSlot format="infeed" />
            </li>
          </template>
        </ul>
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

/* ---------------- Datos mockeados ---------------- */
const general = 68
const average = 7.4
const streakDays = 12
const examDays = 87
const goalDone = 20
const goalTotal = 30

const blocks = [
  { name: 'Bloque I · Constitución', pct: 82 },
  { name: 'Bloque II · Ley 39/2015', pct: 64 },
  { name: 'Bloque III · Ley 40/2015', pct: 51 },
  { name: 'Bloque IV · UE', pct: 38 }
]
const weakTopics = ['Recursos administrativos', 'Cómputo de plazos', 'Órganos de la UE']
const grades = [6.2, 6.8, 6.5, 7.1, 7.9, 7.4]
const week = [1, 0.7, 1, 0.4, 1, 0.9, 0.3]

const tests = [
  { id: 1, topic: 'Ley 39/2015', title: 'Procedimiento administrativo común', questions: 40, progress: 45, recommended: true },
  { id: 2, topic: 'Constitución', title: 'Título I · Derechos y deberes', questions: 30, progress: 100, recommended: false },
  { id: 3, topic: 'Ley 40/2015', title: 'Régimen jurídico del sector público', questions: 25, progress: 0, recommended: false },
  { id: 4, topic: 'Unión Europea', title: 'Instituciones de la UE', questions: 20, progress: 70, recommended: false }
]

const posts = [
  { id: 1, votes: 128, opo: 'Administrativo del Estado', author: 'laura_88', title: '¿Cómo memorizáis los plazos de la 39/2015?', snippet: 'Llevo un mes y se me mezclan los plazos de recursos. ¿Algún truco que os funcione?', comments: 34, hot: true },
  { id: 2, votes: 76, opo: 'Auxiliar Administrativo', author: 'carlosG', title: 'Mi rutina de estudio de 3h al día', snippet: 'Comparto cómo organizo las sesiones para no quemarme. Bloques de 50/10...', comments: 21, hot: false },
  { id: 3, votes: 52, opo: 'Gestión Procesal', author: 'martaruiz', title: '¡Aprobada la primera! Gracias a la comunidad 🎉', snippet: 'Después de dos convocatorias por fin saqué plaza. Os cuento qué cambié...', comments: 47, hot: true }
]

/* ---------------- Expandibles ---------------- */
const open = ref<Record<string, boolean>>({})
const toggle = (k: string) => { open.value[k] = !open.value[k] }
const isOpen = (k: string) => !!open.value[k]

/* Sparkline de notas */
const sparkCoords = computed(() => {
  const max = 10, min = 0
  return grades.map((g, i) => ({
    x: (i / (grades.length - 1)) * 240,
    y: 70 - ((g - min) / (max - min)) * 70
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
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.test:hover { transform: translateY(-4px); box-shadow: var(--shadow); }
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
  border: none;
  background: var(--bg-warm);
  color: var(--muted);
  width: 34px;
  height: 34px;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background 0.15s ease, color 0.15s ease;
}
.vote:hover { background: var(--brand-soft); color: var(--brand); }
.post__meta { display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; font-size: 0.82rem; color: var(--muted); margin-bottom: var(--space-1); }
.post__opo { font-weight: 700; color: var(--brand-700); }
.post__title { margin: 0 0 var(--space-1); font-size: 1.05rem; font-weight: 700; }
.post__snippet { margin: 0 0 var(--space-3); color: var(--muted); font-size: 0.92rem; }
.post__foot { font-size: 0.82rem; color: var(--muted); font-weight: 600; }

/* Anuncios */
.dash__ad { margin-bottom: var(--space-8); }
.feed__ad { list-style: none; }

@media (max-width: 560px) {
  .card__top { flex-direction: column; text-align: center; align-items: center; }
  .dash__meta { width: 100%; }
}
</style>
