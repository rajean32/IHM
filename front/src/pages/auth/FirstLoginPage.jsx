import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { firstLoginUpdate, setUserInfo, getUserInfo } from '../../api/entityApi'

export default function FirstLoginPage() {
  const navigate = useNavigate()
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
        <h2>Première connexion</h2>
        <p>Veuillez mettre à jour votre email et mot de passe.</p>
        <label>
          Nouvel email
          <input
            type="email"
            value={newEmail}
            onChange={(e) => { setNewEmail(e.target.value); setError('') }}
            required
          />
        </label>
        <label>
          Nouveau mot de passe
          <input
            type="password"
            value={newPassword}
            onChange={(e) => { setNewPassword(e.target.value); setError('') }}
            required
          />
        </label>
        {error && <p className="error">{error}</p>}
        <button type="submit" disabled={loading}>
          {loading ? 'Mise à jour...' : 'Mettre à jour'}
        </button>
      </form>
    </div>
  )
}
