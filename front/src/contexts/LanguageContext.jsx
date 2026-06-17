import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { loadPreferences, savePreferences } from '../services/preferencesService'
import { translate, languages } from '../localization'

const LanguageContext = createContext()

export function LanguageProvider({ children }) {
  const [lang, setLangState] = useState(() => {
    const prefs = loadPreferences()
    return prefs.language
  })

  useEffect(() => {
    document.documentElement.lang = lang
  }, [lang])

  const setLang = useCallback((newLang) => {
    setLangState(newLang)
    const prefs = loadPreferences()
    savePreferences({ ...prefs, language: newLang })
  }, [])

  const t = useCallback((key) => translate(lang, key), [lang])

  return (
    <LanguageContext.Provider value={{ lang, setLang, t, languages }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const ctx = useContext(LanguageContext)
  if (!ctx) throw new Error('useLanguage must be used within LanguageProvider')
  return ctx
}
