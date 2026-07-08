// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  srcDir: 'src/',
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },

  css: ['~/assets/css/main.css'],

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
    '@nuxtjs/i18n',
    '@nuxtjs/supabase'
  ],

  supabase: {
    // Las claves se leen de SUPABASE_URL y SUPABASE_KEY (.env)
    redirectOptions: {
      login: '/auth',
      callback: '/confirm',
      // Rutas protegidas (requieren sesión)
      include: ['/dashboard(/*)?', '/comunidad(/*)?'],
      exclude: []
    }
  },

  i18n: {
    // v9: los archivos viven en <srcDir>/i18n/locales/
    locales: [
      { code: 'es', name: 'Español', file: 'es.json' }
    ],
    langDir: 'locales',
    defaultLocale: 'es',
    strategy: 'prefix_except_default'
  }
})
