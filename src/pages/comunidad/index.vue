<template>
  <main class="comu">
    <div class="container">
      <header class="comu__head">
        <div>
          <h1 class="comu__title">{{ $t('comunidad.title') }}</h1>
          <p class="comu__sub">{{ $t('comunidad.subtitle') }}</p>
        </div>
        <NuxtLink :to="localePath('/dashboard')" class="btn btn--ghost">← Dashboard</NuxtLink>
      </header>

      <!-- Crear post -->
      <section class="composer">
        <p class="composer__as">{{ $t('comunidad.loginToPost') }} <strong>{{ myName }}</strong></p>
        <input v-model="title" class="composer__title" type="text" :placeholder="$t('comunidad.titlePh')" maxlength="140" />
        <textarea v-model="body" class="composer__body" rows="3" :placeholder="$t('comunidad.bodyPh')" />
        <p v-if="errorMsg" class="composer__error">{{ errorMsg }}</p>
        <div class="composer__actions">
          <button type="button" class="btn btn--accent" :disabled="!title.trim() || sending" @click="createPost">
            {{ sending ? $t('comunidad.loading') : $t('comunidad.publish') }}
          </button>
        </div>
      </section>

      <!-- Feed -->
      <p v-if="loading" class="state">{{ $t('comunidad.loading') }}</p>
      <p v-else-if="!posts.length" class="state">{{ $t('comunidad.empty') }}</p>

      <ul v-else class="feed">
        <li v-for="p in posts" :key="p.id" class="post">
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
              <span class="post__time">· {{ timeAgo(p.created_at) }}</span>
            </div>
            <h3 class="post__title">{{ p.titulo }}</h3>
            <p v-if="p.cuerpo" class="post__snippet">{{ p.cuerpo }}</p>
            <div class="post__foot">💬 {{ $t('comunidad.comments', { n: p.comentarios }) }}</div>
          </NuxtLink>
        </li>
      </ul>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const localePath = useLocalePath()
const { t } = useI18n()

const title = ref('')
const body = ref('')
const sending = ref(false)
const errorMsg = ref('')

const myName = computed(() => {
  const m = user.value?.user_metadata as { full_name?: string, name?: string } | undefined
  return m?.full_name || m?.name || user.value?.email?.split('@')[0] || t('comunidad.anon')
})

function nameOf(prof: { full_name?: string, username?: string } | undefined) {
  return prof?.full_name || prof?.username || t('comunidad.anon')
}

function timeAgo(iso: string) {
  const s = Math.floor((Date.now() - new Date(iso).getTime()) / 1000)
  if (s < 60) return 'ahora'
  if (s < 3600) return `hace ${Math.floor(s / 60)} min`
  if (s < 86400) return `hace ${Math.floor(s / 3600)} h`
  return `hace ${Math.floor(s / 86400)} d`
}

async function fetchPosts() {
  const { data: rows } = await supabase
    .from('posts')
    .select('id,titulo,cuerpo,created_at,user_id,comentarios(count),votos(count)')
    .order('created_at', { ascending: false })

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
    author: nameOf(map[p.user_id]),
    comentarios: p.comentarios?.[0]?.count ?? 0,
    votos: p.votos?.[0]?.count ?? 0,
    voted: voted.has(p.id)
  }))
}

const { data: posts, refresh, status } = await useAsyncData('comu-feed', fetchPosts, { default: () => [] as any[] })
const loading = computed(() => status.value === 'pending')

async function createPost() {
  if (!title.value.trim()) return
  sending.value = true
  errorMsg.value = ''
  const { error } = await supabase.from('posts').insert({ titulo: title.value.trim(), cuerpo: body.value.trim() || null })
  sending.value = false
  if (error) { errorMsg.value = error.message; return }
  title.value = ''
  body.value = ''
  await refresh()
}

async function toggleVote(p: any) {
  if (!user.value) return
  if (p.voted) {
    await supabase.from('votos').delete().eq('post_id', p.id).eq('user_id', user.value.id)
  } else {
    await supabase.from('votos').upsert({ post_id: p.id, user_id: user.value.id, valor: 1 })
  }
  await refresh()
}
</script>

<style scoped>
.comu { padding-block: var(--space-7) var(--space-10); background: var(--bg-warm); min-height: 100vh; }
.comu__head {
  display: flex; align-items: flex-start; justify-content: space-between;
  gap: var(--space-4); flex-wrap: wrap; margin-bottom: var(--space-6);
}
.comu__title { margin: 0; font-size: clamp(1.7rem, 4vw, 2.4rem); font-weight: 800; letter-spacing: -0.02em; }
.comu__sub { margin: var(--space-1) 0 0; color: var(--muted); }

/* Composer */
.composer {
  background: var(--white); border: 1px solid var(--line); border-radius: var(--radius);
  box-shadow: var(--shadow-sm); padding: var(--space-5); margin-bottom: var(--space-6);
}
.composer__as { margin: 0 0 var(--space-3); font-size: 0.85rem; color: var(--muted); }
.composer__as strong { color: var(--brand-700); }
.composer__title, .composer__body {
  width: 100%; border: 1.5px solid var(--line); border-radius: var(--radius-sm);
  padding: var(--space-3) var(--space-4); font-family: inherit; font-size: 0.97rem;
  color: var(--ink); background: var(--white); margin-bottom: var(--space-3);
}
.composer__title { font-weight: 700; }
.composer__body { resize: vertical; }
.composer__title:focus, .composer__body:focus {
  outline: none; border-color: var(--brand); box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.15);
}
.composer__actions { display: flex; justify-content: flex-end; }
.composer__error { margin: 0 0 var(--space-3); color: #b91c1c; background: #fef2f2; border: 1px solid #fecaca; border-radius: var(--radius-sm); padding: var(--space-3); font-size: 0.88rem; font-weight: 600; }

.state { color: var(--muted); text-align: center; padding: var(--space-8) 0; }

/* Feed */
.feed { list-style: none; margin: 0; padding: 0; display: grid; gap: var(--space-3); }
.post {
  display: flex; gap: var(--space-4); background: var(--white); border: 1px solid var(--line);
  border-radius: var(--radius); padding: var(--space-5); box-shadow: var(--shadow-sm);
}
.post__votes { display: flex; flex-direction: column; align-items: center; gap: 0.2rem; min-width: 44px; }
.post__votes strong { font-size: 0.95rem; font-weight: 800; }
.vote {
  display: grid; place-items: center;
  border: none; background: var(--bg-warm); color: var(--muted); width: 36px; height: 36px;
  border-radius: 10px; cursor: pointer; font-size: 0.8rem; line-height: 1; transition: background 0.15s ease, color 0.15s ease;
}
.vote:hover { background: var(--brand-soft); color: var(--brand); }
.vote--on { background: var(--brand); color: #fff; }
.post__body { flex: 1; text-decoration: none; color: inherit; display: block; }
.post__meta { display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; font-size: 0.82rem; color: var(--muted); margin-bottom: var(--space-1); }
.post__author { font-weight: 700; color: var(--brand-700); }
.post__title { margin: 0 0 var(--space-1); font-size: 1.05rem; font-weight: 700; color: var(--ink); }
.post__snippet {
  margin: 0 0 var(--space-3); color: var(--muted); font-size: 0.92rem;
  display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.post__foot { font-size: 0.82rem; color: var(--muted); font-weight: 600; }

@media (max-width: 480px) {
  .comu__head .btn { display: none; }
}
</style>
