<template>
  <main class="comu">
    <div class="container container--narrow">
      <NuxtLink :to="localePath('/comunidad')" class="back">← {{ $t('comunidad.back') }}</NuxtLink>

      <p v-if="loading" class="state">{{ $t('comunidad.loading') }}</p>

      <template v-else-if="post">
        <!-- Post -->
        <article class="detail">
          <div class="detail__meta">
            <span class="detail__author">{{ post.author }}</span>
            <span class="detail__time">· {{ timeAgo(post.created_at) }}</span>
          </div>
          <h1 class="detail__title">{{ post.titulo }}</h1>
          <p v-if="post.cuerpo" class="detail__body">{{ post.cuerpo }}</p>
        </article>

        <!-- Responder -->
        <section class="reply">
          <p class="reply__as">{{ $t('comunidad.loginToPost') }} <strong>{{ myName }}</strong></p>
          <textarea v-model="commentBody" class="reply__input" rows="3" :placeholder="$t('comunidad.commentPh')" />
          <div class="reply__actions">
            <button type="button" class="btn btn--primary" :disabled="!commentBody.trim() || sending" @click="addComment">
              {{ sending ? $t('comunidad.loading') : $t('comunidad.send') }}
            </button>
          </div>
        </section>

        <!-- Comentarios -->
        <h2 class="comments__title">{{ $t('comunidad.comments', { n: comments.length }) }}</h2>
        <p v-if="!comments.length" class="state">{{ $t('comunidad.noComments') }}</p>
        <ul v-else class="comments">
          <li v-for="c in comments" :key="c.id" class="comment">
            <div class="comment__meta">
              <span class="comment__author">{{ c.author }}</span>
              <span class="comment__time">· {{ timeAgo(c.created_at) }}</span>
            </div>
            <p class="comment__body">{{ c.cuerpo }}</p>
          </li>
        </ul>
      </template>

      <p v-else class="state">Post no encontrado.</p>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()
const localePath = useLocalePath()
const { t } = useI18n()

const postId = route.params.id as string

const commentBody = ref('')
const sending = ref(false)

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

async function fetchPost() {
  const { data: p } = await supabase.from('posts').select('*').eq('id', postId).maybeSingle()
  if (!p) return null
  const { data: prof } = await supabase.from('profiles').select('full_name,username').eq('id', p.user_id).maybeSingle()
  return { ...p, author: nameOf(prof || undefined) }
}

async function fetchComments() {
  const { data: rows } = await supabase
    .from('comentarios')
    .select('id,cuerpo,created_at,user_id')
    .eq('post_id', postId)
    .order('created_at', { ascending: true })
  const list = rows || []
  const ids = [...new Set(list.map((c: any) => c.user_id))]
  const { data: profs } = ids.length
    ? await supabase.from('profiles').select('id,full_name,username').in('id', ids)
    : { data: [] as any[] }
  const map = Object.fromEntries((profs || []).map((p: any) => [p.id, p]))
  return list.map((c: any) => ({ ...c, author: nameOf(map[c.user_id]) }))
}

const { data: post, status } = await useAsyncData(`post-${postId}`, fetchPost)
const { data: comments, refresh: refreshComments } = await useAsyncData(`comments-${postId}`, fetchComments, { default: () => [] as any[] })
const loading = computed(() => status.value === 'pending')

async function addComment() {
  if (!commentBody.value.trim()) return
  sending.value = true
  await supabase.from('comentarios').insert({ post_id: postId, cuerpo: commentBody.value.trim() })
  commentBody.value = ''
  sending.value = false
  await refreshComments()
}
</script>

<style scoped>
.comu { padding-block: var(--space-7) var(--space-10); background: var(--bg-warm); min-height: 100vh; }
.container--narrow { max-width: 760px; }
.back { display: inline-block; margin-bottom: var(--space-5); color: var(--muted); text-decoration: none; font-weight: 600; }
.back:hover { color: var(--brand); }
.state { color: var(--muted); text-align: center; padding: var(--space-6) 0; }

.detail {
  background: var(--white); border: 1px solid var(--line); border-radius: var(--radius);
  box-shadow: var(--shadow-sm); padding: var(--space-6); margin-bottom: var(--space-5);
}
.detail__meta { display: flex; gap: 0.4rem; font-size: 0.85rem; color: var(--muted); margin-bottom: var(--space-2); }
.detail__author { font-weight: 700; color: var(--brand-700); }
.detail__title { margin: 0 0 var(--space-3); font-size: clamp(1.4rem, 3vw, 1.9rem); font-weight: 800; letter-spacing: -0.01em; }
.detail__body { margin: 0; color: var(--ink); line-height: 1.6; white-space: pre-wrap; }

.reply {
  background: var(--white); border: 1px solid var(--line); border-radius: var(--radius);
  box-shadow: var(--shadow-sm); padding: var(--space-5); margin-bottom: var(--space-6);
}
.reply__as { margin: 0 0 var(--space-3); font-size: 0.85rem; color: var(--muted); }
.reply__as strong { color: var(--brand-700); }
.reply__input {
  width: 100%; border: 1.5px solid var(--line); border-radius: var(--radius-sm);
  padding: var(--space-3) var(--space-4); font-family: inherit; font-size: 0.97rem;
  color: var(--ink); resize: vertical; margin-bottom: var(--space-3);
}
.reply__input:focus { outline: none; border-color: var(--brand); box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.15); }
.reply__actions { display: flex; justify-content: flex-end; }

.comments__title { font-size: 1.1rem; font-weight: 800; margin: 0 0 var(--space-4); }
.comments { list-style: none; margin: 0; padding: 0; display: grid; gap: var(--space-3); }
.comment {
  background: var(--white); border: 1px solid var(--line); border-radius: var(--radius-sm);
  padding: var(--space-4);
}
.comment__meta { display: flex; gap: 0.4rem; font-size: 0.8rem; color: var(--muted); margin-bottom: var(--space-1); }
.comment__author { font-weight: 700; color: var(--brand-700); }
.comment__body { margin: 0; color: var(--ink); line-height: 1.55; white-space: pre-wrap; }
</style>
