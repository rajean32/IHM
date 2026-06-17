import { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react'
import { loadPreferences, savePreferences } from '../services/preferencesService'
import { lightTheme, darkTheme } from '../theme/lightTheme'

const ThemeContext = createContext()

function getSystemTheme() {
  if (typeof window === 'undefined') return 'light'
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

export function ThemeProvider({ children }) {
  const [themeMode, setThemeModeState] = useState(() => {
    const prefs = loadPreferences()
    return prefs.theme
  })

  const resolvedTheme = useMemo(() => {
    if (themeMode === 'system') return getSystemTheme()
    return themeMode
  }, [themeMode])

  const theme = useMemo(() => {
    return resolvedTheme === 'dark' ? darkTheme : lightTheme
  }, [resolvedTheme])

  const setTheme = useCallback((newTheme) => {
    setThemeModeState(newTheme)
    const prefs = loadPreferences()
    savePreferences({ ...prefs, theme: newTheme })
  }, [])

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', resolvedTheme)
  }, [resolvedTheme])

  useEffect(() => {
    if (themeMode !== 'system') return
    const mq = window.matchMedia('(prefers-color-scheme: dark)')
    const handler = () => {
      document.documentElement.setAttribute('data-theme', getSystemTheme())
    }
    mq.addEventListener('change', handler)
    return () => mq.removeEventListener('change', handler)
  }, [themeMode])

  return (
    <ThemeContext.Provider value={{ themeMode, resolvedTheme, theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  const ctx = useContext(ThemeContext)
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider')
  return ctx
}
