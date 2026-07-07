<template>
  <div class="landing">
    <!-- Navbar -->
    <header class="nav">
      <div class="container nav__inner">
        <NuxtLink to="/" class="brand">
          <span class="brand__mark">O</span>
          <span class="brand__name">{{ $t('landing.brand') }}</span>
        </NuxtLink>

        <nav class="nav__links">
          <a href="#features">{{ $t('landing.nav.features') }}</a>
          <a href="#community">{{ $t('landing.nav.community') }}</a>
        </nav>

        <div class="nav__actions">
          <NuxtLink to="/auth" class="btn btn--ghost">{{ $t('landing.nav.login') }}</NuxtLink>
          <NuxtLink to="/auth" class="btn btn--primary">{{ $t('landing.nav.cta') }}</NuxtLink>
        </div>
      </div>
    </header>

    <!-- Hero -->
    <section class="hero">
      <div class="container hero__inner">
        <div class="hero__content">
          <span class="badge"><span class="badge__dot"></span>{{ $t('landing.hero.badge') }}</span>

          <h1 class="hero__title">
            {{ $t('landing.hero.title') }}
            <mark class="hl">{{ $t('landing.hero.titleAccent') }}</mark>
          </h1>

          <p class="hero__subtitle">{{ $t('landing.hero.subtitle') }}</p>

          <div class="hero__actions">
            <NuxtLink to="/auth" class="btn btn--accent btn--lg">{{ $t('landing.hero.cta') }}</NuxtLink>
            <div class="rating">
              <span class="rating__stars" aria-hidden="true">★★★★★</span>
              <span class="rating__text">{{ $t('landing.hero.rating') }}</span>
            </div>
          </div>

          <p class="hero__note">✓ {{ $t('landing.hero.note') }}</p>
        </div>

        <!-- Mock quiz card -->
        <div class="hero__visual">
          <div class="quiz">
            <div class="quiz__head">
              <span class="quiz__label">{{ $t('landing.hero.card.label') }}</span>
              <span class="quiz__timer">02:14</span>
            </div>
            <p class="quiz__question">{{ $t('landing.hero.card.question') }}</p>
            <ul class="quiz__options">
              <li class="quiz__option">{{ $t('landing.hero.card.option1') }}</li>
              <li class="quiz__option quiz__option--correct">
                {{ $t('landing.hero.card.option2') }}
                <span class="quiz__tick" aria-hidden="true">✓</span>
              </li>
              <li class="quiz__option">{{ $t('landing.hero.card.option3') }}</li>
            </ul>
            <p class="quiz__result">{{ $t('landing.hero.card.correct') }}</p>
          </div>

          <div class="chip chip--progress">
            <span class="chip__label">{{ $t('landing.hero.card.progress') }}</span>
            <div class="chip__bar"><span :style="{ width: '78%' }"></span></div>
            <strong class="chip__value">78%</strong>
          </div>
        </div>
      </div>
    </section>

    <!-- Stats -->
    <section class="stats-band">
      <div class="container">
        <dl class="stats">
          <div class="stats__item">
            <dt>+2.000</dt>
            <dd>{{ $t('landing.stats.questions') }}</dd>
          </div>
          <div class="stats__item">
            <dt>+10.000</dt>
            <dd>{{ $t('landing.stats.students') }}</dd>
          </div>
          <div class="stats__item">
            <dt>100%</dt>
            <dd>{{ $t('landing.stats.topics') }}</dd>
          </div>
        </dl>
      </div>
    </section>

    <!-- Features -->
    <section id="features" class="features">
      <div class="container">
        <div class="section-head">
          <h2 class="section-head__title">{{ $t('landing.features.title') }}</h2>
          <p class="section-head__subtitle">{{ $t('landing.features.subtitle') }}</p>
        </div>

        <div class="cards">
          <article
            v-for="f in features"
            :key="f.key"
            class="card"
            :style="{ '--chip': f.chip, '--chip-ink': f.ink }"
          >
            <span class="card__icon" aria-hidden="true">{{ f.icon }}</span>
            <h3 class="card__title">{{ $t(`landing.features.${f.key}.title`) }}</h3>
            <p class="card__text">{{ $t(`landing.features.${f.key}.text`) }}</p>
          </article>
        </div>
      </div>
    </section>

    <!-- Community -->
    <section id="community" class="community">
      <div class="container community__inner">
        <div class="community__content">
          <h2 class="community__title">{{ $t('landing.community.title') }}</h2>
          <p class="community__subtitle">{{ $t('landing.community.subtitle') }}</p>
          <NuxtLink to="/auth" class="btn btn--light btn--lg">{{ $t('landing.community.cta') }}</NuxtLink>
        </div>
      </div>
    </section>

    <!-- Final CTA -->
    <section class="cta">
      <div class="container cta__inner">
        <h2 class="cta__title">{{ $t('landing.final.title') }}</h2>
        <p class="cta__subtitle">{{ $t('landing.final.subtitle') }}</p>
        <NuxtLink to="/auth" class="btn btn--accent btn--lg">{{ $t('landing.final.cta') }}</NuxtLink>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="container footer__inner">
        <div class="brand">
          <span class="brand__mark">O</span>
          <span class="brand__name">{{ $t('landing.brand') }}</span>
        </div>
        <p class="footer__tagline">{{ $t('landing.footer.tagline') }}</p>
        <p class="footer__rights">© {{ year }} {{ $t('landing.brand') }}. {{ $t('landing.footer.rights') }}</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
interface Feature {
  key: string
  icon: string
  chip: string
  ink: string
}

const features: Feature[] = [
  { key: 'questions', icon: '📚', chip: '#ecfdf5', ink: '#059669' },
  { key: 'mocks', icon: '⏱️', chip: '#fef3c7', ink: '#d97706' },
  { key: 'stats', icon: '📊', chip: '#e0f2fe', ink: '#0284c7' },
  { key: 'progress', icon: '📈', chip: '#ede9fe', ink: '#7c3aed' },
  { key: 'devices', icon: '📱', chip: '#ffe4e6', ink: '#e11d48' }
]

const year = new Date().getFullYear()
</script>

<style scoped>
.landing {
  --brand: #059669;
  --brand-600: #047857;
  --brand-700: #065f46;
  --brand-soft: #ecfdf5;
  --accent: #f59e0b;
  --accent-600: #d97706;
  --accent-soft: #fef3c7;
  --ink: #0b1f19;
  --muted: #5b6b64;
  --line: #e4ede9;
  --bg: #ffffff;
  --bg-warm: #f5faf8;
  --radius: 20px;
  --shadow-sm: 0 4px 14px -6px rgba(6, 95, 70, 0.18);
  --shadow: 0 22px 50px -24px rgba(6, 95, 70, 0.35);
  --container: 1160px;

  color: var(--ink);
  background: var(--bg);
  font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}

.container {
  width: 100%;
  max-width: var(--container);
  margin: 0 auto;
  padding-inline: clamp(1.15rem, 4vw, 2.5rem);
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.72rem 1.4rem;
  border-radius: 999px;
  font-weight: 700;
  font-size: 0.95rem;
  text-decoration: none;
  border: 2px solid transparent;
  cursor: pointer;
  transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
  white-space: nowrap;
}
.btn--primary {
  background: var(--brand);
  color: #fff;
}
.btn--primary:hover { background: var(--brand-600); transform: translateY(-2px); }
.btn--ghost {
  background: transparent;
  color: var(--ink);
  border-color: var(--line);
}
.btn--ghost:hover { border-color: var(--brand); color: var(--brand); }
.btn--accent {
  background: var(--accent);
  color: #3d2600;
  box-shadow: 0 12px 26px -10px rgba(245, 158, 11, 0.75);
}
.btn--accent:hover { background: var(--accent-600); transform: translateY(-2px); color: #fff; }
.btn--light {
  background: #fff;
  color: var(--brand-700);
}
.btn--light:hover { transform: translateY(-2px); }
.btn--lg {
  padding: 0.95rem 2rem;
  font-size: 1.05rem;
}

/* Navbar */
.nav {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: saturate(180%) blur(12px);
  border-bottom: 1px solid var(--line);
}
.nav__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  height: 70px;
}
.brand {
  display: inline-flex;
  align-items: center;
  gap: 0.55rem;
  text-decoration: none;
  color: var(--ink);
  font-weight: 800;
  font-size: 1.2rem;
}
.brand__mark {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: linear-gradient(135deg, var(--brand) 0%, var(--brand-700) 100%);
  color: #fff;
  font-weight: 800;
}
.nav__links {
  display: flex;
  gap: 1.75rem;
}
.nav__links a {
  color: var(--muted);
  text-decoration: none;
  font-weight: 600;
  transition: color 0.15s ease;
}
.nav__links a:hover { color: var(--ink); }
.nav__actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

/* Hero */
.hero {
  position: relative;
  overflow: hidden;
  background:
    radial-gradient(48% 55% at 82% 8%, var(--accent-soft) 0%, transparent 60%),
    radial-gradient(55% 60% at 8% 20%, var(--brand-soft) 0%, transparent 62%),
    var(--bg);
  padding-block: clamp(2.75rem, 7vw, 5.5rem);
}
.hero__inner {
  display: grid;
  grid-template-columns: 1.05fr 0.95fr;
  align-items: center;
  gap: clamp(2rem, 5vw, 4rem);
}
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.42rem 0.95rem;
  border-radius: 999px;
  background: #fff;
  border: 1px solid var(--line);
  color: var(--brand-700);
  font-weight: 700;
  font-size: 0.85rem;
  box-shadow: var(--shadow-sm);
}
.badge__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--brand);
  box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.18);
}
.hero__title {
  margin: 1.3rem 0 0;
  font-size: clamp(2.2rem, 5.2vw, 3.7rem);
  line-height: 1.08;
  font-weight: 800;
  letter-spacing: -0.025em;
}
.hl {
  background: linear-gradient(120deg, var(--accent-soft) 0%, #fde68a 100%);
  color: var(--ink);
  padding: 0 0.15em;
  border-radius: 6px;
  box-decoration-break: clone;
  -webkit-box-decoration-break: clone;
}
.hero__subtitle {
  margin: 1.1rem 0 0;
  max-width: 46ch;
  font-size: clamp(1.02rem, 2vw, 1.22rem);
  color: var(--muted);
}
.hero__actions {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 1.1rem;
  margin-top: 1.9rem;
}
.rating {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}
.rating__stars {
  color: var(--accent);
  letter-spacing: 2px;
  font-size: 1.05rem;
}
.rating__text {
  font-size: 0.82rem;
  color: var(--muted);
  font-weight: 600;
}
.hero__note {
  margin: 1.1rem 0 0;
  font-size: 0.9rem;
  color: var(--brand-700);
  font-weight: 600;
}

/* Hero visual: quiz card */
.hero__visual {
  position: relative;
  justify-self: center;
  width: 100%;
  max-width: min(420px, 100%);
}
.quiz {
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 24px;
  padding: 1.5rem;
  box-shadow: var(--shadow);
  transform: rotate(-1.5deg);
}
.quiz__head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.9rem;
}
.quiz__label {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--muted);
}
.quiz__timer {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--accent-600);
  background: var(--accent-soft);
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
}
.quiz__question {
  margin: 0 0 1rem;
  font-weight: 700;
  font-size: 1.02rem;
  line-height: 1.35;
}
.quiz__options {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 0.6rem;
}
.quiz__option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.8rem 1rem;
  border: 1.5px solid var(--line);
  border-radius: 12px;
  font-weight: 600;
  font-size: 0.95rem;
  color: var(--ink);
}
.quiz__option--correct {
  border-color: var(--brand);
  background: var(--brand-soft);
  color: var(--brand-700);
}
.quiz__tick {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: var(--brand);
  color: #fff;
  font-size: 0.8rem;
}
.quiz__result {
  margin: 1rem 0 0;
  text-align: center;
  font-weight: 700;
  font-size: 0.9rem;
  color: var(--brand);
}
.chip--progress {
  position: absolute;
  bottom: -22px;
  right: -14px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 16px;
  padding: 0.85rem 1rem;
  box-shadow: var(--shadow);
  width: 190px;
  transform: rotate(2deg);
}
.chip__label {
  display: block;
  font-size: 0.72rem;
  font-weight: 700;
  color: var(--muted);
  margin-bottom: 0.45rem;
}
.chip__bar {
  height: 8px;
  border-radius: 999px;
  background: var(--brand-soft);
  overflow: hidden;
}
.chip__bar span {
  display: block;
  height: 100%;
  border-radius: 999px;
  background: linear-gradient(90deg, var(--brand) 0%, #34d399 100%);
}
.chip__value {
  position: absolute;
  top: 0.7rem;
  right: 0.9rem;
  font-size: 0.85rem;
  color: var(--brand-700);
}

/* Stats band */
.stats-band {
  background: var(--brand-700);
  color: #fff;
  padding-block: clamp(1.75rem, 4vw, 2.5rem);
}
.stats {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  gap: 1.5rem 2rem;
  margin: 0;
  padding: 0;
}
.stats__item { text-align: center; flex: 1 1 140px; }
.stats__item dt {
  font-size: clamp(1.7rem, 4vw, 2.4rem);
  font-weight: 800;
  color: #fff;
}
.stats__item dd {
  margin: 0.15rem 0 0;
  color: #a7f3d0;
  font-size: 0.9rem;
  font-weight: 600;
}

/* Section head */
.section-head {
  text-align: center;
  max-width: 42ch;
  margin: 0 auto 3rem;
}
.section-head__title {
  font-size: clamp(1.8rem, 4vw, 2.6rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  margin: 0;
}
.section-head__subtitle {
  margin: 0.8rem 0 0;
  color: var(--muted);
  font-size: 1.06rem;
}

/* Features */
.features {
  background: var(--bg-warm);
  padding-block: clamp(3.25rem, 8vw, 6rem);
}
.cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
  gap: 1.25rem;
}
.card {
  background: #fff;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 1.75rem;
  box-shadow: var(--shadow-sm);
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}
.card:hover {
  transform: translateY(-6px);
  box-shadow: var(--shadow);
}
.card__icon {
  display: grid;
  place-items: center;
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: var(--chip);
  color: var(--chip-ink);
  font-size: 1.55rem;
  margin-bottom: 1.1rem;
}
.card__title {
  margin: 0 0 0.4rem;
  font-size: 1.18rem;
  font-weight: 700;
}
.card__text {
  margin: 0;
  color: var(--muted);
  font-size: 0.97rem;
}

/* Community */
.community {
  padding-block: clamp(3.25rem, 8vw, 6rem);
}
.community__inner {
  display: flex;
  justify-content: center;
}
.community__content {
  position: relative;
  overflow: hidden;
  text-align: center;
  max-width: 60ch;
  background:
    radial-gradient(60% 80% at 90% 0%, rgba(245, 158, 11, 0.35) 0%, transparent 55%),
    linear-gradient(135deg, var(--brand) 0%, var(--brand-700) 100%);
  color: #fff;
  padding: clamp(2.5rem, 6vw, 4rem);
  border-radius: 30px;
  box-shadow: 0 34px 70px -30px rgba(6, 95, 70, 0.7);
}
.community__title {
  margin: 0;
  font-size: clamp(1.8rem, 4vw, 2.5rem);
  font-weight: 800;
}
.community__subtitle {
  margin: 1rem auto 2rem;
  max-width: 48ch;
  font-size: 1.06rem;
  opacity: 0.95;
}

/* Final CTA */
.cta {
  background: var(--ink);
  color: #fff;
  padding-block: clamp(3.25rem, 8vw, 5.5rem);
}
.cta__inner { text-align: center; }
.cta__title {
  margin: 0;
  font-size: clamp(1.8rem, 4vw, 2.7rem);
  font-weight: 800;
}
.cta__subtitle {
  margin: 0.9rem 0 2rem;
  color: #b9c9c3;
  font-size: 1.06rem;
}

/* Footer */
.footer {
  background: var(--bg-warm);
  border-top: 1px solid var(--line);
  padding-block: 2.5rem;
}
.footer__inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.6rem;
  text-align: center;
}
.footer__tagline { margin: 0; color: var(--muted); }
.footer__rights { margin: 0; color: var(--muted); font-size: 0.85rem; }

/* ---------- Responsive ---------- */

/* Tablet / iPad: stack the hero into one column */
@media (max-width: 900px) {
  .hero__inner {
    grid-template-columns: 1fr;
    text-align: center;
  }
  .hero__content { max-width: 42rem; margin: 0 auto; }
  .hero__subtitle { margin-inline: auto; }
  .hero__actions { justify-content: center; }
  .hero__visual { margin-top: 2.75rem; max-width: min(380px, 100%); }
  .nav__links { display: none; }
}

/* Phones */
@media (max-width: 560px) {
  .nav__actions .btn--ghost { display: none; }
  .hero__actions { flex-direction: column; align-items: stretch; }
  .hero__actions .btn { width: 100%; }
  .rating { align-items: center; }
  .quiz { transform: none; }
  .chip--progress {
    right: 50%;
    transform: translateX(50%);
    bottom: -26px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .btn, .card { transition: none; }
  .btn:hover, .card:hover { transform: none; }
}
</style>
