<template>
  <aside class="ad" :class="`ad--${format}`" role="complementary" aria-label="Publicidad">
    <span class="ad__tag">Publicidad</span>
    <div class="ad__body">
      <span class="ad__logo" aria-hidden="true">
        <b style="color:#4285F4">G</b><b style="color:#EA4335">o</b><b style="color:#FBBC05">o</b><b style="color:#4285F4">g</b><b style="color:#34A853">l</b><b style="color:#EA4335">e</b>
        <span class="ad__ads">Ads</span>
      </span>
      <span class="ad__size">{{ sizeLabel }}</span>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  format?: 'banner' | 'infeed' | 'rectangle'
}>(), {
  format: 'banner'
})

const sizeLabel = computed(() => {
  switch (props.format) {
    case 'infeed': return 'Anuncio nativo · in-feed'
    case 'rectangle': return 'Rectángulo · 300×250'
    default: return 'Banner responsive · 728×90'
  }
})
</script>

<style scoped>
.ad {
  position: relative;
  display: grid;
  place-items: center;
  border: 1.5px dashed var(--line);
  border-radius: var(--radius);
  background:
    repeating-linear-gradient(45deg, transparent, transparent 12px, rgba(100, 116, 139, 0.04) 12px, rgba(100, 116, 139, 0.04) 24px),
    var(--bg-warm);
  color: var(--muted);
  overflow: hidden;
}
.ad--banner { min-height: 100px; }
.ad--infeed { min-height: 110px; }
.ad--rectangle { min-height: 250px; max-width: 300px; margin-inline: auto; }

.ad__tag {
  position: absolute;
  top: 0;
  left: 0;
  font-size: 0.66rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--muted);
  background: var(--white);
  border: 1px solid var(--line);
  border-top: none;
  border-left: none;
  border-radius: 0 0 8px 0;
  padding: 0.2rem 0.5rem;
}
.ad__body {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
}
.ad__logo {
  font-size: 1.1rem;
  font-weight: 800;
  letter-spacing: -0.5px;
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
}
.ad__ads {
  color: var(--muted);
  font-weight: 700;
  font-size: 0.9rem;
}
.ad__size {
  font-size: 0.78rem;
  font-weight: 600;
}
</style>
