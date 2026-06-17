import fr from './fr.json'
import en from './en.json'

export const languages = [
  { code: 'fr', label: 'Français', nativeLabel: 'Français' },
  { code: 'en', label: 'English', nativeLabel: 'English' },
]

const resources = { fr, en }

export function translate(lang, key) {
  if (key == null) return ''
  const keys = key.split('.')
  let value = resources[lang]
  for (const k of keys) {
    if (value == null) return key
    value = value[k]
  }
  return value ?? key
}
