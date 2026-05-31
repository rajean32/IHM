import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { register, setAuthToken, setUserInfo } from '../../api/entityApi'

export default function RegisterPage() {
  const navigate = useNavigate()
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
        <h2>Inscription</h2>
        <label>
          Code utilisateur
          <input name="codeUtilisateur" value={form.codeUtilisateur} onChange={onChange} required />
        </label>
        <label>
          Nom
          <input name="nom" value={form.nom} onChange={onChange} required />
        </label>
        <label>
          Prénoms
          <input name="prenoms" value={form.prenoms} onChange={onChange} required />
        </label>
        <label>
          Sexe
          <select name="sexe" value={form.sexe} onChange={onChange}>
            <option value="M">Masculin</option>
            <option value="F">Féminin</option>
          </select>
        </label>
        <label>
          Date de naissance
          <input name="dateDeNaissance" type="date" value={form.dateDeNaissance} onChange={onChange} required />
        </label>
        <label>
          Email
          <input name="email" type="email" value={form.email} onChange={onChange} required />
        </label>
        <label>
          Téléphone
          <input name="tel" type="tel" value={form.tel} onChange={onChange} required />
        </label>
        <label>
          Mot de passe
          <input name="motDePasse" type="password" value={form.motDePasse} onChange={onChange} required />
        </label>
        <label>
          Type
          <select name="type" value={form.type} onChange={onChange}>
            <option value="client">Client</option>
            <option value="organisateur">Organisateur</option>
          </select>
        </label>
        {error && <p className="error">{error}</p>}
        <button type="submit" disabled={loading}>
          {loading ? 'Inscription...' : "S'inscrire"}
        </button>
        <p className="auth-link">
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
      </form>
    </div>
  )
}
