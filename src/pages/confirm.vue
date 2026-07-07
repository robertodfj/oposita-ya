<template>
  <main class="confirm">
    <p class="confirm__text">{{ $t('auth.loading') }}</p>
  </main>
</template>

<script setup lang="ts">
const user = useSupabaseUser()
const localePath = useLocalePath()

// Cuando la sesión queda establecida (tras Google o confirmar email),
// redirigimos al dashboard.
watch(
  user,
  () => {
    if (user.value) {
      navigateTo(localePath('/dashboard'))
    }
  },
  { immediate: true }
)
</script>

<style scoped>
.confirm {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: var(--space-6);
}
.confirm__text {
  color: var(--muted);
  font-weight: 600;
}
</style>
