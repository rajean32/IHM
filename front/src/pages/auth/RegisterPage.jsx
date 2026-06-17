import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { register, setAuthToken, setUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function RegisterPage() {
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [form, setForm] = useState({
    codeUtilisateur: '',
    nom: '',
    prenoms: '',
    sexe: 'M',
    dateDeNaissance: '',
    email: '',
    tel: '',
    motDePasse: '',
    type: 'client',
  })

  function onChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value })
    setError('')
  }

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await register({
        ...form,
        dateDeNaissance: form.dateDeNaissance || undefined,
      })
      const data = res.data
      setAuthToken(data.token)
      setUserInfo(data)
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
        <h2>{t('auth.register.title')}</h2>
        <label>
          {t('auth.register.code')}
          <input name="codeUtilisateur" value={form.codeUtilisateur} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.lastName')}
          <input name="nom" value={form.nom} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.firstName')}
          <input name="prenoms" value={form.prenoms} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.sexe')}
          <select name="sexe" value={form.sexe} onChange={onChange}>
            <option value="M">{t('auth.register.male')}</option>
            <option value="F">{t('auth.register.female')}</option>
          </select>
        </label>
        <label>
          {t('auth.register.birthDate')}
          <input name="dateDeNaissance" type="date" value={form.dateDeNaissance} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.email')}
          <input name="email" type="email" value={form.email} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.phone')}
          <input name="tel" type="tel" value={form.tel} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.password')}
          <input name="motDePasse" type="password" value={form.motDePasse} onChange={onChange} required />
        </label>
        <label>
          {t('auth.register.type')}
          <select name="type" value={form.type} onChange={onChange}>
            <option value="client">{t('auth.register.client')}</option>
            <option value="organisateur">{t('auth.register.organizer')}</option>
          </select>
        </label>
        {error && <p className="error-msg">{error}</p>}
        <button type="submit" disabled={loading} className="btn-primary">
          {loading ? t('auth.register.loading') : t('auth.register.submit')}
        </button>
        <p className="auth-link">
          {t('auth.register.hasAccount')} <Link to="/login">{t('auth.register.loginLink')}</Link>
        </p>
      </form>
    </div>
  )
}
