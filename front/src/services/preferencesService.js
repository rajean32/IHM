const STORAGE_KEY = 'ihm_preferences'

const defaults = {
  language: 'fr',
  theme: 'system',
}

export function loadPreferences() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) {
      const parsed = JSON.parse(raw)
      return { ...defaults, ...parsed }
    }
  } catch {}
  return { ...defaults }
}

export function savePreferences(prefs) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
  } catch {}
}
