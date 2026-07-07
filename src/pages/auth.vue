<template>
  <div>
    <div>
      <h1>{{ $t('auth.welcome') }}</h1>

      <div role="tablist">
        <button
          role="tab"
          :aria-selected="mode === 'login'"
          @click="mode = 'login'"
        >
          {{ $t('auth.login') }}
        </button>
        <button
          role="tab"
          :aria-selected="mode === 'register'"
          @click="mode = 'register'"
        >
          {{ $t('auth.register') }}
        </button>
      </div>

      <section v-if="mode === 'login'">
        <h2>{{ $t('auth.login') }}</h2>
      </section>

      <section v-else>
        <h2>{{ $t('auth.register') }}</h2>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

type AuthMode = 'login' | 'register'

const mode = ref<AuthMode>('login')
</script>
