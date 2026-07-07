<template>
  <main class="auth">
    <div class="auth__card">
      <NuxtLink to="/" class="brand auth__brand">
        <span class="brand__mark">O</span>
        <span>{{ $t('auth.brand') }}</span>
      </NuxtLink>

      <h1 class="auth__title">{{ $t('auth.welcome') }}</h1>
      <p class="auth__subtitle">{{ $t('auth.subtitle') }}</p>

      <!-- Selector login / register -->
      <div class="tabs" role="tablist">
        <button
          type="button"
          class="tabs__btn"
          role="tab"
          :aria-selected="mode === 'login'"
          @click="switchMode('login')"
        >
          {{ $t('auth.login') }}
        </button>
        <button
          type="button"
          class="tabs__btn"
          role="tab"
          :aria-selected="mode === 'register'"
          @click="switchMode('register')"
        >
          {{ $t('auth.register') }}
        </button>
      </div>

      <!-- Continuar con Google -->
      <button
        type="button"
        class="btn btn--ghost btn--lg btn--block google"
        :disabled="loading"
        @click="signInWithGoogle"
      >
        <svg class="google__icon" viewBox="0 0 48 48" aria-hidden="true">
          <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" />
          <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" />
          <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" />
          <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" />
        </svg>
        {{ $t('auth.google') }}
      </button>

      <div class="divider"><span>{{ $t('auth.divider') }}</span></div>

      <!-- Formulario email / contraseña -->
      <form class="form" @submit.prevent="onSubmit">
        <label v-if="mode === 'register'" class="field">
          <span class="field__label">{{ $t('auth.name') }}</span>
          <input v-model="name" class="field__input" type="text" :placeholder="$t('auth.namePlaceholder')" autocomplete="name" />
        </label>

        <label class="field">
          <span class="field__label">{{ $t('auth.email') }}</span>
          <input v-model="email" class="field__input" type="email" required :placeholder="$t('auth.emailPlaceholder')" autocomplete="email" />
        </label>

        <label class="field">
          <span class="field__label">{{ $t('auth.password') }}</span>
          <input v-model="password" class="field__input" type="password" required minlength="6" :placeholder="$t('auth.passwordPlaceholder')" :autocomplete="mode === 'login' ? 'current-password' : 'new-password'" />
        </label>

        <p v-if="errorMsg" class="msg msg--error">{{ errorMsg }}</p>
        <p v-if="infoMsg" class="msg msg--info">{{ infoMsg }}</p>

        <button type="submit" class="btn btn--primary btn--lg btn--block" :disabled="loading">
          {{ loading ? $t('auth.loading') : (mode === 'login' ? $t('auth.submitLogin') : $t('auth.submitRegister')) }}
        </button>
      </form>

      <NuxtLink to="/" class="auth__back">← {{ $t('auth.back') }}</NuxtLink>
    </div>
  </main>
</template>

<script setup lang="ts">
import { navigateTo } from 'nuxt/app'
import { ref } from 'vue'

type AuthMode = 'login' | 'register'

const supabase = useSupabaseClient()
const { t } = useI18n()
const localePath = useLocalePath()

const mode = ref<AuthMode>('login')
const name = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')
const infoMsg = ref('')

function switchMode(next: AuthMode) {
  mode.value = next
  errorMsg.value = ''
  infoMsg.value = ''
}

// Traduce los errores de Supabase (que vienen en inglés) a español.
function mapAuthError(e: unknown): string {
  const err = e as { code?: string; message?: string; status?: number }
  const code = err?.code || ''
  const msg = (err?.message || '').toLowerCase()

  if (code === 'user_already_exists' || msg.includes('already registered') || msg.includes('already exists')) {
    return t('auth.errors.userExists')
  }
  if (code === 'invalid_credentials' || msg.includes('invalid login credentials')) {
    return t('auth.errors.invalidCredentials')
  }
  if (code === 'email_not_confirmed' || msg.includes('email not confirmed')) {
    return t('auth.errors.emailNotConfirmed')
  }
  if (code === 'weak_password' || msg.includes('password should be') || msg.includes('weak')) {
    return t('auth.errors.weakPassword')
  }
  if (code === 'validation_failed' || msg.includes('invalid email') || msg.includes('unable to validate email')) {
    return t('auth.errors.invalidEmail')
  }
  if (code?.includes('rate') || err?.status === 429 || msg.includes('rate limit')) {
    return t('auth.errors.rateLimit')
  }
  return t('auth.errorGeneric')
}

async function onSubmit() {
  loading.value = true
  errorMsg.value = ''
  infoMsg.value = ''

  try {
    if (mode.value === 'login') {
      const { error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
      })
      if (error) throw error
      await navigateTo(localePath('/dashboard'))
    } else {
      const { data, error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
        options: {
          data: { full_name: name.value },
          emailRedirectTo: `${window.location.origin}/confirm`
        }
      })
      if (error) throw error

      // Si Supabase exige confirmación por email, no hay sesión todavía
      if (data.session) {
        await navigateTo(localePath('/dashboard'))
      } else {
        infoMsg.value = t('auth.checkEmail')
      }
    }
  } catch (e: unknown) {
    errorMsg.value = mapAuthError(e)
  } finally {
    loading.value = false
  }
}

async function signInWithGoogle() {
  loading.value = true
  errorMsg.value = ''
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo: `${window.location.origin}/confirm` }
  })
  if (error) {
    errorMsg.value = mapAuthError(error)
    loading.value = false
  }
  // Si va bien, el navegador redirige a Google; no hace falta más.
}
</script>

<style scoped>
.auth {
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: var(--space-6) var(--space-4);
  background:
    radial-gradient(48% 55% at 82% 8%, var(--accent-soft) 0%, transparent 60%),
    radial-gradient(55% 60% at 8% 20%, var(--brand-soft) 0%, transparent 62%),
    var(--bg);
}

.auth__card {
  width: 100%;
  max-width: 440px;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: clamp(var(--space-6), 5vw, var(--space-8));
}

.auth__brand {
  margin-bottom: var(--space-5);
}

.auth__title {
  margin: 0;
  font-size: 1.6rem;
  font-weight: 800;
  letter-spacing: -0.02em;
}
.auth__subtitle {
  margin: var(--space-2) 0 var(--space-6);
  color: var(--muted);
  font-size: 0.97rem;
}

/* Tabs */
.tabs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-1);
  padding: var(--space-1);
  background: var(--bg-warm);
  border: 1px solid var(--line);
  border-radius: var(--radius-pill);
  margin-bottom: var(--space-6);
}
.tabs__btn {
  border: none;
  background: transparent;
  padding: var(--space-3);
  border-radius: var(--radius-pill);
  font-family: inherit;
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--muted);
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease;
}
.tabs__btn[aria-selected='true'] {
  background: var(--white);
  color: var(--brand-700);
  box-shadow: var(--shadow-sm);
}

/* Google */
.google {
  gap: var(--space-3);
}
.google__icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

/* Divider */
.divider {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin: var(--space-5) 0;
  color: var(--muted);
  font-size: 0.85rem;
}
.divider::before,
.divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--line);
}

/* Form */
.form {
  display: grid;
  gap: var(--space-4);
}
.field {
  display: grid;
  gap: var(--space-2);
}
.field__label {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--ink);
}
.field__input {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  border: 1.5px solid var(--line);
  border-radius: var(--radius-sm);
  font-family: inherit;
  font-size: 0.97rem;
  color: var(--ink);
  background: var(--white);
  transition: border-color 0.15s ease, box-shadow 0.15s ease;
}
.field__input::placeholder { color: #9aa8a2; }
.field__input:focus {
  outline: none;
  border-color: var(--brand);
  box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.15);
}

/* Mensajes */
.msg {
  margin: 0;
  font-size: 0.88rem;
  font-weight: 600;
  padding: var(--space-3);
  border-radius: var(--radius-sm);
}
.msg--error {
  color: #b91c1c;
  background: #fef2f2;
  border: 1px solid #fecaca;
}
.msg--info {
  color: var(--brand-700);
  background: var(--brand-soft);
  border: 1px solid #a7f3d0;
}

.auth__back {
  display: block;
  text-align: center;
  margin-top: var(--space-5);
  color: var(--muted);
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 600;
}
.auth__back:hover { color: var(--brand); }
</style>
