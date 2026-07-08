<template>
  <main class="tests">
    <div class="container">
      <header class="tests__head">
        <div>
          <h1 class="tests__title">{{ $t('test.listTitle') }}</h1>
          <p class="tests__sub">{{ $t('test.listSubtitle') }}</p>
        </div>
        <NuxtLink :to="localePath('/dashboard')" class="btn btn--ghost">← Dashboard</NuxtLink>
      </header>

      <p v-if="loading" class="state">{{ $t('test.loading') }}</p>
      <p v-else-if="!tests.length" class="state">{{ $t('test.noTests') }}</p>

      <div v-else class="grid">
        <NuxtLink
          v-for="t in tests"
          :key="t.id"
          :to="localePath(`/test/${t.id}`)"
          class="tcard"
        >
          <span v-if="t.es_simulacro" class="tag tag--sim">⏱ {{ $t('test.simulacro') }}</span>
          <h3 class="tcard__title">{{ t.titulo }}</h3>
          <p v-if="t.descripcion" class="tcard__desc">{{ t.descripcion }}</p>
          <div class="tcard__foot">
            <span class="tcard__q">{{ $t('test.questions', { n: t.num_preguntas }) }}</span>
            <span class="tcard__go">{{ $t('test.start') }} →</span>
          </div>
        </NuxtLink>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const supabase = useSupabaseClient()
const localePath = useLocalePath()

async function fetchTests() {
  const { data } = await supabase
    .from('tests')
    .select('id,titulo,descripcion,num_preguntas,es_simulacro,created_at')
    .order('es_simulacro', { ascending: true })
    .order('created_at', { ascending: true })
  return data || []
}

const { data: tests, status } = await useAsyncData('tests-list', fetchTests, { default: () => [] as any[] })
const loading = computed(() => status.value === 'pending')
</script>

<style scoped>
.tests { padding-block: var(--space-7) var(--space-10); background: var(--bg-warm); min-height: 100vh; }
.tests__head { display: flex; align-items: flex-start; justify-content: space-between; gap: var(--space-4); flex-wrap: wrap; margin-bottom: var(--space-6); }
.tests__title { margin: 0; font-size: clamp(1.7rem, 4vw, 2.4rem); font-weight: 800; letter-spacing: -0.02em; }
.tests__sub { margin: var(--space-1) 0 0; color: var(--muted); }
.state { color: var(--muted); text-align: center; padding: var(--space-8) 0; }

.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: var(--space-4); }
.tcard {
  display: flex; flex-direction: column; text-decoration: none; color: inherit;
  background: var(--white); border: 1px solid var(--line); border-radius: var(--radius);
  padding: var(--space-5); box-shadow: var(--shadow-sm);
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.tcard:hover { transform: translateY(-4px); box-shadow: var(--shadow); }
.tag--sim { align-self: flex-start; margin-bottom: var(--space-2); font-size: 0.75rem; font-weight: 700; padding: 0.2rem 0.55rem; border-radius: var(--radius-pill); background: var(--accent-soft); color: var(--accent-600); }
.tcard__title { margin: 0 0 var(--space-1); font-size: 1.1rem; font-weight: 700; }
.tcard__desc { margin: 0 0 var(--space-4); color: var(--muted); font-size: 0.92rem; flex: 1; }
.tcard__foot { display: flex; align-items: center; justify-content: space-between; margin-top: auto; }
.tcard__q { font-size: 0.85rem; color: var(--muted); font-weight: 600; }
.tcard__go { font-weight: 700; color: var(--brand-700); font-size: 0.9rem; }
</style>
