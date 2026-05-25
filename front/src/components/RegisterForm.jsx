import { useState } from 'react'
import { register, setAuthToken, setUserInfo } from '../api/entityApi'

export default function RegisterForm({ onAuth }) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
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
    setSuccess('')
  }

  async function handleSubmit(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const res = await register({
        ...form,
        dateDeNaissance: form.dateDeNaissance || undefined,
      })
      const t = res.data?.token || res.token
      if (t) {
        setAuthToken(t)
        const info = {
          code: form.codeUtilisateur,
          email: form.email,
          role: form.type === 'organisateur' ? 'ORGANISATEUR' : 'CLIENT',
        }
        setUserInfo(info)
        onAuth(t, info)
      } else {
        setSuccess(`Compte ${form.codeUtilisateur} créé. Veuillez vous connecter.`)
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form className="custom-form" onSubmit={handleSubmit}>
      <h2>Inscription</h2>
      <p className="form-subtitle">Créer un compte Client ou Organisateur</p>

      <div className="form-row">
        <label>
          Code utilisateur *
          <input name="codeUtilisateur" value={form.codeUtilisateur} onChange={onChange} required />
        </label>
        <label>
          Rôle *
          <select name="type" value={form.type} onChange={onChange}>
            <option value="client">Client</option>
            <option value="organisateur">Organisateur</option>
          </select>
        </label>
      </div>

      <div className="form-row">
        <label>
          Nom *
          <input name="nom" value={form.nom} onChange={onChange} required />
        </label>
        <label>
          Prénoms *
          <input name="prenoms" value={form.prenoms} onChange={onChange} required />
        </label>
      </div>

      <div className="form-row">
        <label>
          Sexe *
          <select name="sexe" value={form.sexe} onChange={onChange}>
            <option value="M">Masculin</option>
            <option value="F">Féminin</option>
          </select>
        </label>
        <label>
          Date de naissance *
          <input name="dateDeNaissance" type="date" value={form.dateDeNaissance} onChange={onChange} required />
        </label>
      </div>

      <div className="form-row">
        <label>
          Email *
          <input name="email" type="email" value={form.email} onChange={onChange} required />
        </label>
        <label>
          Téléphone *
          <input name="tel" type="tel" value={form.tel} onChange={onChange} required />
        </label>
      </div>

      <div className="form-row">
        <label>
          Mot de passe *
          <input name="motDePasse" type="password" value={form.motDePasse} onChange={onChange} required minLength={4} />
        </label>
      </div>

      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      <button type="submit" disabled={loading}>
        {loading ? 'Inscription...' : "S'inscrire"}
      </button>
    </form>
  )
}
