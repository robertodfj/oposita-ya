<template>
  <div>
    <h1>{{ $t('welcome') }}</h1>
    <p>{{ $t('description') }}</p>

    <div class="lang-switcher">
      <NuxtLink :to="switchLocalePath('es')">Español</NuxtLink>
      |
      <NuxtLink :to="switchLocalePath('en')">English</NuxtLink>
    </div>
  </div>
</template>

<script setup>
const { locale } = useI18n()
const switchLocalePath = useSwitchLocalePath()
</script>
