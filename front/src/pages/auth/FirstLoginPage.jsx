import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { firstLoginUpdate, setUserInfo, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function FirstLoginPage() {
  const navigate = useNavigate()
  const { t } = useLanguage()
  const user = getUserInfo()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [newEmail, setNewEmail] = useState('')
  const [newPassword, setNewPassword] = useState('')

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await firstLoginUpdate({
        codeUtilisateur: user.codeUtilisateur,
        newEmail,
        newPassword,
      })
      setUserInfo(res.data)
      navigate('/')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-page">
      <form onSubmit={handleSubmit}>
        <h2>{t('auth.firstLogin.title')}</h2>
        <p>{t('auth.firstLogin.description')}</p>
        <label>
          {t('auth.firstLogin.newEmail')}
          <input
            type="email"
            value={newEmail}
            onChange={(e) => { setNewEmail(e.target.value); setError('') }}
            required
          />
        </label>
        <label>
          {t('auth.firstLogin.newPassword')}
          <input
            type="password"
            value={newPassword}
            onChange={(e) => { setNewPassword(e.target.value); setError('') }}
            required
          />
        </label>
        {error && <p className="error-msg">{error}</p>}
        <button type="submit" disabled={loading} className="btn-primary">
          {loading ? t('auth.firstLogin.loading') : t('auth.firstLogin.submit')}
        </button>
      </form>
    </div>
  )
}
