<template>
  <div class="donut" :style="{ width: size + 'px', height: size + 'px' }" role="img" :aria-label="`${value}%`">
    <svg viewBox="0 0 120 120">
      <defs>
        <linearGradient :id="gradId" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stop-color="var(--brand)" />
          <stop offset="100%" stop-color="#34d399" />
        </linearGradient>
      </defs>
      <circle class="donut__track" cx="60" cy="60" :r="radius" :stroke-width="stroke" fill="none" />
      <circle
        class="donut__value"
        cx="60"
        cy="60"
        :r="radius"
        :stroke-width="stroke"
        fill="none"
        :stroke="`url(#${gradId})`"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="offset"
        stroke-linecap="round"
        transform="rotate(-90 60 60)"
      />
    </svg>
    <div class="donut__center">
      <slot>
        <strong class="donut__num">{{ value }}<span class="donut__unit">%</span></strong>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  value: number
  size?: number
  stroke?: number
}>(), {
  size: 120,
  stroke: 12
})

const radius = computed(() => 60 - props.stroke / 2 - 2)
const circumference = computed(() => 2 * Math.PI * radius.value)
const offset = computed(() => circumference.value * (1 - Math.min(100, Math.max(0, props.value)) / 100))
const gradId = `donutGrad${Math.random().toString(36).slice(2, 8)}`
</script>

<style scoped>
.donut {
  position: relative;
  display: grid;
  place-items: center;
  flex-shrink: 0;
}
.donut svg {
  width: 100%;
  height: 100%;
}
.donut__track {
  stroke: var(--brand-soft);
}
.donut__value {
  transition: stroke-dashoffset 0.6s ease;
}
.donut__center {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  text-align: center;
}
.donut__num {
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--ink);
  line-height: 1;
}
.donut__unit {
  font-size: 0.9rem;
  color: var(--muted);
  margin-left: 1px;
}
</style>
