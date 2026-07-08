<template>
  <main class="test">
    <div class="container container--narrow">
      <NuxtLink :to="localePath('/tests')" class="back">← {{ $t('test.backToTests') }}</NuxtLink>

      <p v-if="loading" class="state">{{ $t('test.loading') }}</p>

      <template v-else-if="test">
        <header class="test__head">
          <span v-if="test.es_simulacro" class="tag tag--sim">⏱ {{ $t('test.simulacro') }}</span>
          <h1 class="test__title">{{ test.titulo }}</h1>
          <p v-if="test.descripcion" class="test__desc">{{ test.descripcion }}</p>
        </header>

        <p v-if="!questions.length" class="state">{{ $t('test.empty') }}</p>

        <!-- Resultados -->
        <section v-else-if="submitted" class="results">
          <div class="results__score">
            <DonutProgress :value="Math.round(aciertos / questions.length * 100)" :size="150">
              <div class="results__num">
                <strong>{{ score.toFixed(1) }}</strong><span>/10</span>
              </div>
            </DonutProgress>
            <div class="results__stats">
              <p><span class="dot dot--ok" />{{ $t('test.correct') }}: <strong>{{ aciertos }}</strong></p>
              <p><span class="dot dot--ko" />{{ $t('test.wrong') }}: <strong>{{ answeredCount - aciertos }}</strong></p>
              <p><span class="dot dot--na" />{{ $t('test.unanswered') }}: <strong>{{ questions.length - answeredCount }}</strong></p>
            </div>
          </div>

          <ol class="review">
            <li v-for="q in questions" :key="q.id" class="review__q">
              <p class="review__enun">{{ q.enunciado }}</p>
              <ul class="review__opts">
                <li
                  v-for="(opt, i) in q.opciones"
                  :key="i"
                  class="ropt"
                  :class="{
                    'ropt--correct': i === q.indice_correcta,
                    'ropt--wrong': answers[q.id] === i && i !== q.indice_correcta
                  }"
                >
                  <span class="ropt__mark">{{ i === q.indice_correcta ? '✓' : (answers[q.id] === i ? '✗' : '') }}</span>
                  {{ opt }}
                </li>
              </ul>
              <p v-if="q.explicacion" class="review__exp"><strong>{{ $t('test.explanation') }}:</strong> {{ q.explicacion }}</p>
            </li>
          </ol>

          <div class="results__actions">
            <button type="button" class="btn btn--ghost" @click="retry">{{ $t('test.retry') }}</button>
            <NuxtLink :to="localePath('/dashboard')" class="btn btn--primary">{{ $t('test.backToDash') }}</NuxtLink>
          </div>
        </section>

        <!-- Cuestionario -->
        <section v-else class="quiz">
          <ol class="qlist">
            <li v-for="(q, qi) in questions" :key="q.id" class="qitem">
              <p class="qitem__num">{{ $t('test.question', { n: qi + 1, total: questions.length }) }}</p>
              <p class="qitem__enun">{{ q.enunciado }}</p>
              <div class="qitem__opts">
                <button
                  v-for="(opt, i) in q.opciones"
                  :key="i"
                  type="button"
                  class="opt"
                  :class="{ 'opt--sel': answers[q.id] === i }"
                  @click="answers[q.id] = i"
                >
                  <span class="opt__letter">{{ letters[i] }}</span>
                  {{ opt }}
                </button>
              </div>
            </li>
          </ol>

          <div class="quiz__foot">
            <span class="quiz__count">{{ $t('test.answered', { n: answeredCount, total: questions.length }) }}</span>
            <button type="button" class="btn btn--accent btn--lg" :disabled="saving" @click="submit">
              {{ saving ? $t('test.saving') : $t('test.submit') }}
            </button>
          </div>
        </section>
      </template>

      <p v-else class="state">{{ $t('test.empty') }}</p>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()
const localePath = useLocalePath()

const testId = route.params.id as string
const letters = ['A', 'B', 'C', 'D', 'E', 'F']

const answers = ref<Record<string, number>>({})
const submitted = ref(false)
const saving = ref(false)

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

async function fetchTest() {
  const { data: t } = await supabase.from('tests').select('*').eq('id', testId).maybeSingle()
  if (!t) return { test: null, questions: [] as any[] }

  let query = supabase.from('preguntas').select('id,enunciado,opciones,indice_correcta,explicacion,tema_id')
  query = t.tema_id ? query.eq('tema_id', t.tema_id) : query.eq('oposicion_id', t.oposicion_id)
  const { data: qs } = await query
  const questions = shuffle(qs || []).slice(0, t.num_preguntas || 20)
  return { test: t, questions }
}

const { data, status } = await useAsyncData(`test-${testId}`, fetchTest)
const loading = computed(() => status.value === 'pending')
const test = computed(() => data.value?.test || null)
const questions = computed(() => data.value?.questions || [])

const answeredCount = computed(() => questions.value.filter((q: any) => answers.value[q.id] != null).length)
const aciertos = computed(() => questions.value.filter((q: any) => answers.value[q.id] === q.indice_correcta).length)
const score = computed(() => questions.value.length ? (aciertos.value / questions.value.length) * 10 : 0)

async function submit() {
  if (submitted.value) return
  saving.value = true
  const total = questions.value.length
  const ac = aciertos.value
  const fa = answeredCount.value - ac

  if (user.value) {
    const { data: intento } = await supabase
      .from('intentos')
      .insert({ test_id: testId, aciertos: ac, fallos: fa, total, finished_at: new Date().toISOString() })
      .select('id')
      .single()

    if (intento) {
      const rows = questions.value.map((q: any) => ({
        intento_id: intento.id,
        pregunta_id: q.id,
        opcion_elegida: answers.value[q.id] ?? null,
        es_correcta: answers.value[q.id] === q.indice_correcta
      }))
      await supabase.from('respuestas').insert(rows)
    }
  }

  saving.value = false
  submitted.value = true
  if (import.meta.client) window.scrollTo({ top: 0, behavior: 'smooth' })
}

function retry() {
  answers.value = {}
  submitted.value = false
  if (data.value) data.value.questions = shuffle(data.value.questions)
}
</script>

<style scoped>
.test { padding-block: var(--space-7) var(--space-10); background: var(--bg-warm); min-height: 100vh; }
.container--narrow { max-width: 760px; }
.back { display: inline-block; margin-bottom: var(--space-5); color: var(--muted); text-decoration: none; font-weight: 600; }
.back:hover { color: var(--brand); }
.state { color: var(--muted); text-align: center; padding: var(--space-8) 0; }

.test__head { margin-bottom: var(--space-6); }
.tag--sim { display: inline-block; margin-bottom: var(--space-2); font-size: 0.78rem; font-weight: 700; padding: 0.25rem 0.6rem; border-radius: var(--radius-pill); background: var(--accent-soft); color: var(--accent-600); }
.test__title { margin: 0; font-size: clamp(1.5rem, 3.5vw, 2.1rem); font-weight: 800; letter-spacing: -0.02em; }
.test__desc { margin: var(--space-2) 0 0; color: var(--muted); }

/* Cuestionario */
.qlist { list-style: none; margin: 0 0 var(--space-6); padding: 0; display: grid; gap: var(--space-4); }
.qitem { background: var(--white); border: 1px solid var(--line); border-radius: var(--radius); padding: var(--space-5); box-shadow: var(--shadow-sm); }
.qitem__num { margin: 0 0 var(--space-2); font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; color: var(--muted); }
.qitem__enun { margin: 0 0 var(--space-4); font-weight: 700; font-size: 1.05rem; line-height: 1.4; }
.qitem__opts { display: grid; gap: var(--space-2); }
.opt {
  display: flex; align-items: center; gap: var(--space-3); text-align: left;
  padding: var(--space-3) var(--space-4); border: 1.5px solid var(--line); border-radius: var(--radius-sm);
  background: var(--white); font-family: inherit; font-size: 0.97rem; color: var(--ink); cursor: pointer;
  transition: border-color 0.12s ease, background 0.12s ease;
}
.opt:hover { border-color: var(--brand); }
.opt--sel { border-color: var(--brand); background: var(--brand-soft); }
.opt__letter { display: grid; place-items: center; width: 26px; height: 26px; flex-shrink: 0; border-radius: 8px; background: var(--bg-warm); font-weight: 800; font-size: 0.85rem; color: var(--muted); }
.opt--sel .opt__letter { background: var(--brand); color: #fff; }

.quiz__foot { display: flex; align-items: center; justify-content: space-between; gap: var(--space-4); flex-wrap: wrap; position: sticky; bottom: var(--space-4); background: var(--white); border: 1px solid var(--line); border-radius: var(--radius); padding: var(--space-3) var(--space-4); box-shadow: var(--shadow); }
.quiz__count { font-weight: 700; color: var(--muted); }

/* Resultados */
.results__score { display: flex; align-items: center; gap: var(--space-6); flex-wrap: wrap; justify-content: center; background: var(--white); border: 1px solid var(--line); border-radius: var(--radius); padding: var(--space-6); box-shadow: var(--shadow-sm); margin-bottom: var(--space-5); }
.results__num { text-align: center; }
.results__num strong { font-size: 2rem; font-weight: 800; color: var(--brand); }
.results__num span { color: var(--muted); font-weight: 700; }
.results__stats p { margin: 0 0 var(--space-2); display: flex; align-items: center; gap: var(--space-2); font-size: 1rem; }
.dot { width: 12px; height: 12px; border-radius: 50%; display: inline-block; }
.dot--ok { background: var(--brand); }
.dot--ko { background: #ef4444; }
.dot--na { background: #cbd5e1; }

.review { list-style: none; margin: 0 0 var(--space-6); padding: 0; display: grid; gap: var(--space-3); }
.review__q { background: var(--white); border: 1px solid var(--line); border-radius: var(--radius); padding: var(--space-5); }
.review__enun { margin: 0 0 var(--space-3); font-weight: 700; }
.review__opts { list-style: none; margin: 0 0 var(--space-3); padding: 0; display: grid; gap: var(--space-2); }
.ropt { display: flex; align-items: center; gap: var(--space-2); padding: var(--space-2) var(--space-3); border: 1.5px solid var(--line); border-radius: var(--radius-sm); font-size: 0.95rem; }
.ropt--correct { border-color: var(--brand); background: var(--brand-soft); color: var(--brand-700); font-weight: 600; }
.ropt--wrong { border-color: #fecaca; background: #fef2f2; color: #b91c1c; }
.ropt__mark { width: 16px; font-weight: 800; }
.review__exp { margin: 0; font-size: 0.9rem; color: var(--muted); background: var(--bg-warm); border-radius: var(--radius-sm); padding: var(--space-3); }

.results__actions { display: flex; gap: var(--space-3); justify-content: center; }

.tag { border-radius: var(--radius-pill); }
</style>
