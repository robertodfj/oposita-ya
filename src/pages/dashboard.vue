<template>
  <main class="dashboard">
    <div class="container">
      <header class="dashboard__head">
        <div>
          <h1 class="dashboard__title">{{ $t('dashboard.title') }}</h1>
          <p v-if="user" class="dashboard__greeting">
            {{ $t('dashboard.greeting', { email: user.email }) }}
          </p>
        </div>
        <button type="button" class="btn btn--ghost" @click="logout">
          {{ $t('dashboard.logout') }}
        </button>
      </header>
    </div>
  </main>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const localePath = useLocalePath()

async function logout() {
  await supabase.auth.signOut()
  await navigateTo(localePath('/auth'))
}
</script>

<style scoped>
.dashboard {
  padding-block: var(--space-8);
}
.dashboard__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  flex-wrap: wrap;
}
.dashboard__title {
  margin: 0;
  font-size: clamp(1.8rem, 4vw, 2.6rem);
  font-weight: 800;
  letter-spacing: -0.02em;
}
.dashboard__greeting {
  margin: var(--space-2) 0 0;
  color: var(--muted);
}
</style>
