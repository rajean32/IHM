import { useState, useEffect } from 'react'
import { getAll, create, remove } from '../api/entityApi'

export default function LieuSallePlaceForm({ userRole }) {
  const [step, setStep] = useState(1)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState('')

  const [lieux, setLieux] = useState([])
  const [salles, setSalles] = useState([])
  const [places, setPlaces] = useState([])

  const [lieuForm, setLieuForm] = useState({ nomLieu: '', adresse: '', ville: '' })
  const [salleForm, setSalleForm] = useState({ numeroSalle: '', nomSalle: '', idLieu: '' })
  const [placeForm, setPlaceForm] = useState({ numeroPlace: '', range: '', typePlace: '', numeroSalle: '' })

  const isAdmin = userRole === 'ADMINISTRATEUR'
  const isReadOnly = !isAdmin

  useEffect(() => { setError(''); setSuccess('') }, [step])

  async function loadLieux() {
    try { const r = await getAll('/api/lieux'); setLieux(Array.isArray(r.data) ? r.data : []) } catch { }
  }
  async function loadSalles() {
    try { const r = await getAll('/api/salles'); setSalles(Array.isArray(r.data) ? r.data : []) } catch { }
  }
  async function loadPlaces() {
    try { const r = await getAll('/api/places'); setPlaces(Array.isArray(r.data) ? r.data : []) } catch { }
  }

  function onChange(setter) {
    return (e) => {
      setter(prev => ({ ...prev, [e.target.name]: e.target.value }))
      setError(''); setSuccess('')
    }
  }

  async function handleCreateLieu(e) {
    e.preventDefault()
    if (!isAdmin) return
    setLoading(true); setError(''); setSuccess('')
    try {
      const res = await create('/api/lieux', lieuForm)
      setSuccess(`Lieu "${res.data.nomLieu}" créé (ID: ${res.data.idLieu})`)
      setLieuForm({ nomLieu: '', adresse: '', ville: '' })
      await loadLieux()
    } catch (err) { setError(err.message) } finally { setLoading(false) }
  }

  async function handleCreateSalle(e) {
    e.preventDefault()
    if (!isAdmin) return
    setLoading(true); setError(''); setSuccess('')
    try {
      const res = await create('/api/salles', {
        numeroSalle: salleForm.numeroSalle,
        nomSalle: salleForm.nomSalle || undefined,
        idLieu: Number(salleForm.idLieu),
      })
      setSuccess(`Salle "${res.data.numeroSalle}" créée`)
      setSalleForm({ numeroSalle: '', nomSalle: '', idLieu: '' })
      await loadSalles()
    } catch (err) { setError(err.message) } finally { setLoading(false) }
  }

  async function handleCreatePlace(e) {
    e.preventDefault()
    if (!isAdmin) return
    setLoading(true); setError(''); setSuccess('')
    try {
      const res = await create('/api/places', {
        numeroPlace: placeForm.numeroPlace,
        range: placeForm.range || undefined,
        typePlace: placeForm.typePlace || undefined,
        numeroSalle: placeForm.numeroSalle,
      })
      setSuccess(`Place "${res.data.numeroPlace}" créée`)
      setPlaceForm({ numeroPlace: '', range: '', typePlace: '', numeroSalle: '' })
      await loadPlaces()
    } catch (err) { setError(err.message) } finally { setLoading(false) }
  }

  async function handleDeleteLieu(id) {
    if (!isAdmin || !window.confirm('Supprimer ce lieu ?')) return
    try { await remove('/api/lieux', id); loadLieux() } catch (err) { setError(err.message) }
  }
  async function handleDeleteSalle(id) {
    if (!isAdmin || !window.confirm('Supprimer cette salle ?')) return
    try { await remove('/api/salles', id); loadSalles() } catch (err) { setError(err.message) }
  }
  async function handleDeletePlace(id) {
    if (!isAdmin || !window.confirm('Supprimer cette place ?')) return
    try { await remove('/api/places', id); loadPlaces() } catch (err) { setError(err.message) }
  }

  useEffect(() => { loadLieux(); loadSalles(); loadPlaces() }, [])

  const colSpan = { lieu: 5, salle: 4, place: 5 }

  function renderTable(entity, items, columns, delFn) {
    if (items.length === 0) return <p className="empty">Aucun(e) {entity}</p>
    return (
      <div className="table-wrap">
        <table>
          <thead><tr>{columns.map(c => <th key={c.key}>{c.label}</th>)}</tr></thead>
          <tbody>
            {items.map(item => (
              <tr key={item[columns[0].key]}>
                {columns.map(c => <td key={c.key}>{String(item[c.key] ?? '')}</td>)}
                {isAdmin && (
                  <td><button className="btn-icon danger" onClick={() => delFn(item[columns[0].key])}>✕</button></td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    )
  }

  return (
    <div className="section-container">
      <h2>Configuration Lieu & Salles & Places</h2>

      {isReadOnly && (
        <p className="msg info" style={{ margin: '0.5rem 0' }}>
          Consultation uniquement — seuls les administrateurs peuvent modifier
        </p>
      )}

      <div className="steps-nav">
        {[1, 2, 3].map(s => (
          <button key={s} className={`step-btn ${step === s ? 'active' : ''}`} onClick={() => setStep(s)}>
            {s === 1 ? '1. Lieu' : s === 2 ? '2. Salle' : '3. Place'}
          </button>
        ))}
      </div>

      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      {step === 1 && (
        <>
          {isAdmin && (
            <form className="custom-form compact" onSubmit={handleCreateLieu}>
              <h3>Créer un lieu</h3>
              <div className="form-row">
                <label>Nom *<input name="nomLieu" value={lieuForm.nomLieu} onChange={onChange(setLieuForm)} required /></label>
                <label>Adresse <input name="adresse" value={lieuForm.adresse} onChange={onChange(setLieuForm)} /></label>
                <label>Ville <input name="ville" value={lieuForm.ville} onChange={onChange(setLieuForm)} /></label>
              </div>
              <button type="submit" className="btn-primary" disabled={loading}>{loading ? '...' : 'Créer le lieu'}</button>
            </form>
          )}
          <h4 style={{ marginTop: '1.5rem' }}>Lieux existants</h4>
          {renderTable('lieu', lieux, [
            { key: 'idLieu', label: 'ID' },
            { key: 'nomLieu', label: 'Nom' },
            { key: 'adresse', label: 'Adresse' },
            { key: 'ville', label: 'Ville' },
          ], handleDeleteLieu)}
        </>
      )}

      {step === 2 && (
        <>
          {isAdmin && (
            <form className="custom-form compact" onSubmit={handleCreateSalle}>
              <h3>Créer une salle</h3>
              <div className="form-row">
                <label>Numéro *<input name="numeroSalle" value={salleForm.numeroSalle} onChange={onChange(setSalleForm)} required /></label>
                <label>Nom <input name="nomSalle" value={salleForm.nomSalle} onChange={onChange(setSalleForm)} /></label>
                <label>Lieu *<select name="idLieu" value={salleForm.idLieu} onChange={onChange(setSalleForm)} required>
                  <option value="">-- Sélectionner --</option>
                  {lieux.map(l => <option key={l.idLieu} value={l.idLieu}>{l.nomLieu}</option>)}
                </select></label>
              </div>
              <button type="submit" className="btn-primary" disabled={loading}>{loading ? '...' : 'Créer la salle'}</button>
            </form>
          )}
          <h4 style={{ marginTop: '1.5rem' }}>Salles existantes</h4>
          {renderTable('salle', salles, [
            { key: 'numeroSalle', label: 'Numéro' },
            { key: 'nomSalle', label: 'Nom' },
            { key: 'idLieu', label: 'Lieu' },
          ], handleDeleteSalle)}
        </>
      )}

      {step === 3 && (
        <>
          {isAdmin && (
            <form className="custom-form compact" onSubmit={handleCreatePlace}>
              <h3>Créer une place</h3>
              <div className="form-row">
                <label>Numéro *<input name="numeroPlace" value={placeForm.numeroPlace} onChange={onChange(setPlaceForm)} required /></label>
                <label>Rangée <input name="range" value={placeForm.range} onChange={onChange(setPlaceForm)} /></label>
                <label>Type <input name="typePlace" value={placeForm.typePlace} onChange={onChange(setPlaceForm)} /></label>
                <label>Salle *<select name="numeroSalle" value={placeForm.numeroSalle} onChange={onChange(setPlaceForm)} required>
                  <option value="">-- Sélectionner --</option>
                  {salles.map(s => <option key={s.numeroSalle} value={s.numeroSalle}>{s.numeroSalle} — {s.nomSalle || ''}</option>)}
                </select></label>
              </div>
              <button type="submit" className="btn-primary" disabled={loading}>{loading ? '...' : 'Créer la place'}</button>
            </form>
          )}
          <h4 style={{ marginTop: '1.5rem' }}>Places existantes</h4>
          {renderTable('place', places, [
            { key: 'numeroPlace', label: 'Numéro' },
            { key: 'range', label: 'Rangée' },
            { key: 'typePlace', label: 'Type' },
            { key: 'numeroSalle', label: 'Salle' },
          ], handleDeletePlace)}
        </>
      )}
    </div>
  )
}
