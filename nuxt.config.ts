// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  srcDir: 'src/',
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },

  runtimeConfig: {
    // Solo servidor (mapea NUXT_API_SECRET)
    apiSecret: '',
    public: {
      // Expuesto al cliente (mapea NUXT_PUBLIC_*)
      siteUrl: '',
      apiBase: ''
    }
  },

  modules: [
    '@nuxtjs/i18n'
  ],

  i18n: {
    locales: [
      { code: 'es', name: 'Español', file: 'es.json' }
    ],
    langDir: 'locales/',
    defaultLocale: 'es',
    strategy: 'prefix_except_default'
  }
})
