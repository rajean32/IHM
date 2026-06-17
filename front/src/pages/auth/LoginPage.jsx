import { useState } from 'react'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { loginAdmin, setAuthToken, setUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from?.pathname || '/'
  const { t } = useLanguage()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await loginAdmin(email, password)
      const data = res.data
      setAuthToken(data.token)
      setUserInfo(data)
      if (data.isFirstLogin) {
        navigate('/first-login')
      } else {
        navigate(from, { replace: true })
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-page">
      <form onSubmit={handleSubmit}>
        <h2>{t('auth.login.title')}</h2>
        <label>
          {t('auth.login.email')}
          <input
            type="email"
            value={email}
            onChange={(e) => { setEmail(e.target.value); setError('') }}
            required
          />
        </label>
        <label>
          {t('auth.login.password')}
          <input
            type="password"
            value={password}
            onChange={(e) => { setPassword(e.target.value); setError('') }}
            required
          />
        </label>
        {error && <p className="error-msg">{error}</p>}
        <button type="submit" disabled={loading} className="btn-primary">
          {loading ? t('auth.login.loading') : t('auth.login.submit')}
        </button>
        <p className="auth-link">
          {t('auth.login.noAccount')} <Link to="/register">{t('auth.login.registerLink')}</Link>
        </p>
      </form>
    </div>
  )
}
