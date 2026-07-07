<template>
  <div v-if="visible" class="cookies" role="dialog" aria-live="polite" aria-label="Aviso de cookies">
    <div class="cookies__card">
      <div class="cookies__main">
        <h2 class="cookies__title">{{ $t('cookies.title') }}</h2>
        <p class="cookies__text">
          {{ $t('cookies.text') }}
          <NuxtLink to="/" class="cookies__link">{{ $t('cookies.policy') }}</NuxtLink>
        </p>
      </div>

      <!-- Panel de configuración -->
      <div v-if="showConfig" class="prefs">
        <label class="pref pref--locked">
          <span>
            <strong>{{ $t('cookies.necessary') }}</strong>
            <small>{{ $t('cookies.necessaryHint') }}</small>
          </span>
          <span class="pref__always">{{ $t('cookies.always') }}</span>
        </label>

        <label class="pref">
          <span>
            <strong>{{ $t('cookies.analytics') }}</strong>
            <small>{{ $t('cookies.analyticsHint') }}</small>
          </span>
          <input v-model="prefs.analytics" type="checkbox" class="switch" />
        </label>

        <label class="pref">
          <span>
            <strong>{{ $t('cookies.marketing') }}</strong>
            <small>{{ $t('cookies.marketingHint') }}</small>
          </span>
          <input v-model="prefs.marketing" type="checkbox" class="switch" />
        </label>
      </div>

      <div class="cookies__actions">
        <button v-if="!showConfig" type="button" class="btn btn--ghost" @click="showConfig = true">
          {{ $t('cookies.configure') }}
        </button>
        <button type="button" class="btn btn--ghost" @click="reject">
          {{ $t('cookies.reject') }}
        </button>
        <button v-if="showConfig" type="button" class="btn btn--primary" @click="savePrefs">
          {{ $t('cookies.save') }}
        </button>
        <button type="button" class="btn btn--primary" @click="acceptAll">
          {{ $t('cookies.accept') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'

const STORAGE_KEY = 'oy-cookie-consent'

const visible = ref(false)
const showConfig = ref(false)
const prefs = reactive({ analytics: true, marketing: true })

onMounted(() => {
  // Solo mostramos el banner si el usuario aún no ha elegido
  if (!localStorage.getItem(STORAGE_KEY)) {
    visible.value = true
  }
})

function persist(consent: { necessary: boolean; analytics: boolean; marketing: boolean }) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...consent, ts: Date.now() }))
  visible.value = false
  // Aquí, en real, se activarían/desactivarían los scripts según el consentimiento
  // y se pasaría al CMP la cadena de consentimiento.
}

const acceptAll = () => persist({ necessary: true, analytics: true, marketing: true })
const reject = () => persist({ necessary: true, analytics: false, marketing: false })
const savePrefs = () => persist({ necessary: true, analytics: prefs.analytics, marketing: prefs.marketing })
</script>

<style scoped>
.cookies {
  position: fixed;
  inset: auto 0 0 0;
  z-index: 100;
  display: flex;
  justify-content: center;
  padding: var(--space-4);
  pointer-events: none;
}
.cookies__card {
  pointer-events: auto;
  width: 100%;
  max-width: 640px;
  background: var(--white);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: var(--space-5);
}
.cookies__title {
  margin: 0 0 var(--space-2);
  font-size: 1.1rem;
  font-weight: 800;
}
.cookies__text {
  margin: 0;
  color: var(--muted);
  font-size: 0.92rem;
  line-height: 1.5;
}
.cookies__link {
  color: var(--brand-700);
  font-weight: 700;
  text-decoration: underline;
}

/* Preferencias */
.prefs {
  margin-top: var(--space-4);
  display: grid;
  gap: var(--space-2);
}
.pref {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-3);
  border: 1px solid var(--line);
  border-radius: var(--radius-sm);
  background: var(--bg-warm);
}
.pref strong { display: block; font-size: 0.92rem; }
.pref small { color: var(--muted); font-size: 0.8rem; }
.pref__always {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--brand-700);
  white-space: nowrap;
}
.switch { width: 20px; height: 20px; accent-color: var(--brand); cursor: pointer; flex-shrink: 0; }

.cookies__actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
  margin-top: var(--space-4);
}
.cookies__actions .btn { flex: 1; min-width: 120px; }

@media (max-width: 480px) {
  .cookies__actions .btn { flex-basis: 100%; }
}
</style>
