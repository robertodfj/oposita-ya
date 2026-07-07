# oposita-ya

Proyecto base Nuxt 3 con estructura `src/` y el módulo `@nuxtjs/i18n` ya configurado.

## Estructura

```
oposita-ya/
├── nuxt.config.ts
├── package.json
├── public/
└── src/
    ├── app.vue
    ├── layouts/
    │   └── default.vue
    ├── pages/
    │   └── index.vue
    ├── components/
    ├── assets/
    └── locales/
        ├── es.json
        └── en.json
```

## Instalación

```bash
npm install
```

## Desarrollo

```bash
npm run dev
```

Se abrirá en `http://localhost:3000`.

## Internacionalización (i18n)

- Idioma por defecto: `es`
- Idiomas configurados: `es`, `en`
- Archivos de traducción en `src/locales/`
- Cambiar idioma en el código con `useSwitchLocalePath()` (ver ejemplo en `src/pages/index.vue`)

Para añadir un nuevo idioma:
1. Crea el archivo `src/locales/<codigo>.json`.
2. Añádelo al array `locales` en `nuxt.config.ts`.

## Build para producción

```bash
npm run build
npm run preview
```
