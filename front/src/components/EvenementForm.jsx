import { useState, useEffect } from 'react'
import { getAll, create, getById, update, remove } from '../api/entityApi'

export default function EvenementForm({ userRole, userCode }) {
  const [records, setRecords] = useState([])
  const [categories, setCategories] = useState([])
  const [lieux, setLieux] = useState([])
  const [organisateurs, setOrganisateurs] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [editId, setEditId] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const [modStatus, setModStatus] = useState({})  // { idEvenement: 'newStatus' }
  const [form, setForm] = useState({
    titre: '', description: '', dateEvenement: '', heureEvenement: '',
    image: '', statut: 'Brouillon', codeCategorie: '', idLieu: '', codeOrganisateur: '',
  })

  const isAdmin = userRole === 'ADMINISTRATEUR'
  const isOrganisateur = userRole === 'ORGANISATEUR'
  const isClient = userRole === 'CLIENT'

  function resetForm() {
    setForm({
      titre: '', description: '', dateEvenement: '', heureEvenement: '',
      image: '', statut: 'Brouillon', codeCategorie: '', idLieu: '',
      codeOrganisateur: isOrganisateur ? userCode : '',
    })
    setEditId(null)
  }

  async function fetchAll() {
    setLoading(true)
    setError('')
    try {
      const [eRes, cRes, lRes, oRes] = await Promise.all([
        getAll('/api/evenements'),
        getAll('/api/categories'),
        getAll('/api/lieux'),
        getAll('/api/organisateurs'),
      ])
      let data = Array.isArray(eRes.data) ? eRes.data : []
      if (isOrganisateur) {
        data = data.filter(r => r.codeOrganisateur === userCode)
      }
      setRecords(data)
      setCategories(Array.isArray(cRes.data) ? cRes.data : [])
      setLieux(Array.isArray(lRes.data) ? lRes.data : [])
      setOrganisateurs(Array.isArray(oRes.data) ? oRes.data : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchAll() }, [])

  function onChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value })
    setError('')
  }

  async function handleSave(e) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const payload = {
        titre: form.titre,
        description: form.description || undefined,
        dateEvenement: form.dateEvenement || undefined,
        heureEvenement: form.heureEvenement || undefined,
        image: form.image || undefined,
        statut: form.statut,
        codeCategorie: form.codeCategorie || undefined,
        idLieu: form.idLieu ? Number(form.idLieu) : undefined,
        codeOrganisateur: form.codeOrganisateur,
      }
      if (editId) {
        await update('/api/evenements', editId, payload)
      } else {
        await create('/api/evenements', payload)
      }
      setShowForm(false)
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function startEdit(rec) {
    if (isClient) return
    setLoading(true)
    try {
      const res = await getById('/api/evenements', rec.idEvenement)
      const d = res.data || rec
      setForm({
        titre: d.titre || '', description: d.description || '',
        dateEvenement: d.dateEvenement || '', heureEvenement: d.heureEvenement || '',
        image: d.image || '', statut: d.statut || 'Brouillon',
        codeCategorie: d.codeCategorie || '',
        idLieu: d.idLieu != null ? String(d.idLieu) : '',
        codeOrganisateur: d.codeOrganisateur || '',
      })
      setEditId(rec.idEvenement)
      setShowForm(true)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function handleDelete(id) {
    if (isClient || isAdmin) return
    if (!window.confirm('Supprimer cet événement ?')) return
    setLoading(true)
    try {
      await remove('/api/evenements', id)
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function handleModerateStatus(idEvenement, newStatus) {
    setLoading(true)
    setError('')
    try {
      await update('/api/evenements', idEvenement, { statut: newStatus } )
      setModStatus(prev => ({ ...prev, [idEvenement]: undefined }))
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const statutOptions = ['Brouillon', 'Actif', 'Clôturé', 'Annulé']

  return (
    <div className="section-container">
      <div className="section-header">
        <h2>
          {isAdmin && 'Modération des Événements'}
          {isOrganisateur && 'Mes Événements'}
          {isClient && 'Catalogue des Événements'}
        </h2>
        {isOrganisateur && (
          <button className="btn-primary" onClick={() => { resetForm(); setShowForm(true) }} disabled={showForm}>
            + Nouvel événement
          </button>
        )}
      </div>

      {isAdmin && (
        <p className="form-subtitle" style={{ marginBottom: '0.5rem' }}>
          Tableau de bord de modération — Modifiez le statut des événements
        </p>
      )}

      {error && <p className="msg error">{error}</p>}

      {showForm && isOrganisateur && (
        <form className="custom-form" onSubmit={handleSave}>
          <h3>{editId ? 'Modifier' : 'Créer'} un événement</h3>

          <div className="form-row">
            <label>Titre *<input name="titre" value={form.titre} onChange={onChange} required /></label>
            <label>Statut
              <select name="statut" value={form.statut} onChange={onChange}>
                {statutOptions.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </label>
          </div>

          <label>Description<textarea name="description" value={form.description} onChange={onChange} rows={3} /></label>

          <div className="form-row">
            <label>Date *<input name="dateEvenement" type="date" value={form.dateEvenement} onChange={onChange} required /></label>
            <label>Heure<input name="heureEvenement" type="time" value={form.heureEvenement} onChange={onChange} /></label>
          </div>

          <label>Image (URL)<input name="image" type="url" value={form.image} onChange={onChange} placeholder="https://..." /></label>

          <div className="form-row">
            <label>Catégorie
              <select name="codeCategorie" value={form.codeCategorie} onChange={onChange}>
                <option value="">-- Sélectionner --</option>
                {categories.map(c => (
                  <option key={c.codeCategorie} value={c.codeCategorie}>{c.nomCategorie}</option>
                ))}
              </select>
            </label>
            <label>Lieu
              <select name="idLieu" value={form.idLieu} onChange={onChange}>
                <option value="">-- Sélectionner --</option>
                {lieux.map(l => (
                  <option key={l.idLieu} value={l.idLieu}>{l.nomLieu} — {l.ville || ''}</option>
                ))}
              </select>
            </label>
          </div>

          <label>
            Organisateur *
            <input value={`${userCode} (vous)`} disabled />
            <input type="hidden" name="codeOrganisateur" value={userCode} />
          </label>

          <div className="form-actions">
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? '...' : editId ? 'Mettre à jour' : 'Créer'}
            </button>
            <button type="button" className="btn-secondary" onClick={() => { setShowForm(false); setEditId(null) }}>Annuler</button>
          </div>
        </form>
      )}

      {!showForm && loading && <p className="loading">Chargement...</p>}

      {!showForm && !loading && records.length === 0 && <p className="empty">Aucun événement</p>}

      {!showForm && records.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>ID</th><th>Titre</th><th>Date</th><th>Statut</th>
                {!isClient && <th>Catégorie</th>}
                <th>Lieu</th>
                {!isClient && <th>Organisateur</th>}
                {isAdmin && <th>Modération</th>}
                {isOrganisateur && <th>Actions</th>}
              </tr>
            </thead>
            <tbody>
              {records.map(r => (
                <tr key={r.idEvenement}>
                  <td>{r.idEvenement}</td>
                  <td>{r.titre}</td>
                  <td>{r.dateEvenement}</td>
                  <td><span className={`badge badge-${(r.statut || '').toLowerCase()}`}>{r.statut}</span></td>
                  {!isClient && <td>{r.codeCategorie}</td>}
                  <td>{r.idLieu}</td>
                  {!isClient && <td>{r.codeOrganisateur}</td>}

                  {isAdmin && (
                    <td>
                      <select
                        className="mod-select"
                        value={modStatus[r.idEvenement] ?? r.statut}
                        onChange={e => {
                          const newVal = e.target.value
                          if (newVal !== r.statut && window.confirm(`Passer le statut à "${newVal}" ?`)) {
                            handleModerateStatus(r.idEvenement, newVal)
                          }
                        }}
                      >
                        {statutOptions.map(s => <option key={s} value={s}>{s}</option>)}
                      </select>
                    </td>
                  )}

                  {isOrganisateur && (
                    <td>
                      <button className="btn-icon" onClick={() => startEdit(r)} disabled={loading}>✎</button>
                      <button className="btn-icon danger" onClick={() => handleDelete(r.idEvenement)} disabled={loading}>✕</button>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
