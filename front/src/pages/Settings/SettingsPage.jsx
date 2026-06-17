import { useNavigate } from 'react-router-dom'
import { useLanguage } from '../../contexts/LanguageContext'
import { useTheme } from '../../contexts/ThemeContext'

export default function SettingsPage() {
  const navigate = useNavigate()
  const { lang, setLang, t, languages } = useLanguage()
  const { themeMode, setTheme } = useTheme()

  const themeOptions = [
    { value: 'light', label: t('settings.theme.light') },
    { value: 'dark', label: t('settings.theme.dark') },
    { value: 'system', label: t('settings.theme.system') },
  ]

  return (
    <div className="settings-page">
      <div className="settings-header">
        <button className="btn-icon" onClick={() => navigate(-1)}>
          &larr;
        </button>
        <h1>{t('settings.title')}</h1>
      </div>

      <div className="settings-section">
        <h2 className="settings-section-title">{t('settings.language')}</h2>
        <div className="settings-options">
          {languages.map(l => (
            <button
              key={l.code}
              className={`settings-option ${lang === l.code ? 'active' : ''}`}
              onClick={() => setLang(l.code)}
            >
              <span className="settings-option-label">{l.nativeLabel}</span>
              <span className="settings-option-sub">{l.label}</span>
              {lang === l.code && <span className="settings-check">✓</span>}
            </button>
          ))}
        </div>
      </div>

      <div className="settings-section">
        <h2 className="settings-section-title">{t('settings.appearance')}</h2>
        <div className="settings-options">
          {themeOptions.map(o => (
            <button
              key={o.value}
              className={`settings-option ${themeMode === o.value ? 'active' : ''}`}
              onClick={() => setTheme(o.value)}
            >
              <span className="settings-option-label">{o.label}</span>
              {themeMode === o.value && <span className="settings-check">✓</span>}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
