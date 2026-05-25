import { useState } from 'react'
import { loginAdmin, setAuthToken, setUserInfo } from '../api/entityApi'

export default function LoginForm({ onAuth }) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [code, setCode] = useState('')
  const [password, setPassword] = useState('')

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await loginAdmin(code, password)
      const t = res.data?.token || res.token
      if (t) {
        setAuthToken(t)
        const info = { code, role: res.data?.role || 'ADMINISTRATEUR' }
        setUserInfo(info)
        onAuth(t, info)
      } else {
        setError('Identifiants invalides')
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form className="custom-form" onSubmit={handleSubmit}>
      <h2>Connexion Administrateur</h2>
      <p className="form-subtitle">Accès à la gestion des événements</p>

      <label>
        Code Administrateur *
        <input
          name="codeAdministrateur"
          value={code}
          onChange={(e) => { setCode(e.target.value); setError('') }}
          placeholder="ex: ADM001"
          required
        />
      </label>

      <label>
        Mot de passe *
        <input
          name="motdepasseAdministrateur"
          type="password"
          value={password}
          onChange={(e) => { setPassword(e.target.value); setError('') }}
          required
        />
      </label>

      {error && <p className="msg error">{error}</p>}

      <button type="submit" disabled={loading}>
        {loading ? 'Connexion...' : 'Se connecter'}
      </button>
    </form>
  )
}
