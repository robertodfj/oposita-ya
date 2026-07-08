// Asegura que el usuario logueado tenga su fila en `profiles` con su nombre.
// Evita que aparezca "Opositor" por perfiles vacíos o creados antes del trigger.
export default defineNuxtPlugin(() => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  watch(
    user,
    async (u) => {
      if (!u) return
      const meta = (u.user_metadata || {}) as { full_name?: string, name?: string }
      const name = meta.full_name || meta.name
      if (!name) return
      await supabase
        .from('profiles')
        .upsert({ id: u.id, full_name: name }, { onConflict: 'id' })
    },
    { immediate: true }
  )
})
