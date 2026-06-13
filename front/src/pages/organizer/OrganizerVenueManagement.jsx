import { useState, useEffect } from 'react'
import { getAll, getById, create, update, remove } from '../../api/entityApi'

const TABS = ['Lieux', 'Salles', 'Places']

function Modal({ show, title, onClose, children }) {
  if (!show) return null
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <h3>{title}</h3>
        {children}
      </div>
    </div>
  )
}

function LieuxTab() {
  const [lieux, setLieux] = useState([])
  const [modal, setModal] = useState(false)
  const [edit, setEdit] = useState(null)
  const [form, setForm] = useState({ nom: '', adresse: '', ville: '', capacite: '' })

  function load() { getAll('/api/organisateur/venues/lieux').then(setLieux).catch(() => {}) }
  useEffect(() => { load() }, [])

  function openCreate() { setEdit(null); setForm({ nom: '', adresse: '', ville: '', capacite: '' }); setModal(true) }
  function openEdit(l) { setEdit(l); setForm({ nom: l.nom || '', adresse: l.adresse || '', ville: l.ville || '', capacite: l.capacite || '' }); setModal(true) }

  function onChange(e) { setForm({ ...form, [e.target.name]: e.target.value }) }

  async function handleSave(e) {
    e.preventDefault()
    try {
      if (edit) {
        await update('/api/organisateur/venues/lieux', edit.idLieu || edit.id, form)
      } else {
        await create('/api/organisateur/venues/lieux', form)
      }
      setModal(false)
      load()
    } catch (err) { alert(err.message) }
  }

  async function handleDelete(l) {
    if (!window.confirm('Supprimer ce lieu ?')) return
    try {
      await remove('/api/organisateur/venues/lieux', l.idLieu || l.id)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <button onClick={openCreate}>Ajouter un Lieu</button>
      <table>
        <thead><tr><th>Nom</th><th>Adresse</th><th>Ville</th><th>Capacité</th><th>Actions</th></tr></thead>
        <tbody>
          {lieux.map(l => (
            <tr key={l.idLieu || l.id}>
              <td>{l.nom}</td>
              <td>{l.adresse}</td>
              <td>{l.ville}</td>
              <td>{l.capacite}</td>
              <td>
                <button onClick={() => openEdit(l)}>Modifier</button>
                <button onClick={() => handleDelete(l)}>Supprimer</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <Modal show={modal} title={edit ? 'Modifier Lieu' : 'Ajouter Lieu'} onClose={() => setModal(false)}>
        <form onSubmit={handleSave}>
          <label>Nom <input name="nom" value={form.nom} onChange={onChange} required /></label>
          <label>Adresse <input name="adresse" value={form.adresse} onChange={onChange} /></label>
          <label>Ville <input name="ville" value={form.ville} onChange={onChange} /></label>
          <label>Capacité <input name="capacite" type="number" value={form.capacite} onChange={onChange} /></label>
          <button type="submit">{edit ? 'Modifier' : 'Ajouter'}</button>
        </form>
      </Modal>
    </div>
  )
}

const TYPE_AGENCEMENT_OPTIONS = [
  { value: 'UNIQUEMENT_ASSIS', label: 'Uniquement assis' },
  { value: 'TABLE_ASSIS', label: 'Tables + chaises' },
  { value: 'ASSIS_DEBOUT', label: 'Assis/Debout mixte' },
  { value: 'DEBOUT_AVEC_LIMITE', label: 'Debout avec jauge' },
  { value: 'DEBOUT_SANS_LIMITE', label: 'Debout sans limite' },
]

function SallesTab() {
  const [salles, setSalles] = useState([])
  const [lieux, setLieux] = useState([])
  const [modal, setModal] = useState(false)
  const [edit, setEdit] = useState(null)
  const [form, setForm] = useState({ nom: '', capacite: '', idLieu: '', typeAgencement: 'UNIQUEMENT_ASSIS' })

  function load() {
    getAll('/api/organisateur/venues/salles').then(setSalles).catch(() => {})
    getAll('/api/organisateur/venues/lieux').then(setLieux).catch(() => {})
  }
  useEffect(() => { load() }, [])

  function openCreate() { setEdit(null); setForm({ nom: '', capacite: '', idLieu: '', typeAgencement: 'UNIQUEMENT_ASSIS' }); setModal(true) }
  function openEdit(s) { setEdit(s); setForm({ nom: s.nom || '', capacite: s.capacite || '', idLieu: s.idLieu || '', typeAgencement: s.typeAgencement || 'UNIQUEMENT_ASSIS' }); setModal(true) }

  function onChange(e) { setForm({ ...form, [e.target.name]: e.target.value }) }

  async function handleSave(e) {
    e.preventDefault()
    try {
      const payload = {
        nomSalle: form.nom,
        capacite: Number(form.capacite) || 0,
        idLieu: form.idLieu,
        typeAgencement: form.typeAgencement,
      }
      if (edit) {
        await update('/api/organisateur/venues/salles', edit.idSalle || edit.id || edit.numeroSalle, payload)
      } else {
        await create('/api/organisateur/venues/salles', payload)
      }
      setModal(false)
      load()
    } catch (err) { alert(err.message) }
  }

  async function handleDelete(s) {
    if (!window.confirm('Supprimer cette salle ?')) return
    try {
      await remove('/api/organisateur/venues/salles', s.idSalle || s.id || s.numeroSalle)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <button onClick={openCreate}>Ajouter une Salle</button>
      <table>
        <thead><tr><th>Nom</th><th>Capacité</th><th>Lieu</th><th>Type</th><th>Actions</th></tr></thead>
        <tbody>
          {salles.map(s => (
            <tr key={s.idSalle || s.id || s.numeroSalle}>
              <td>{s.nom || s.nomSalle}</td>
              <td>{s.capacite}</td>
              <td>{s.lieuNom || s.idLieu}</td>
              <td><span style={{ fontSize: '0.8rem', padding: '2px 8px', borderRadius: '8px', background: '#e8edf5', color: '#0f3460' }}>{TYPE_AGENCEMENT_OPTIONS.find(o => o.value === s.typeAgencement)?.label || s.typeAgencement || '—'}</span></td>
              <td>
                <button onClick={() => openEdit(s)}>Modifier</button>
                <button onClick={() => handleDelete(s)}>Supprimer</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <Modal show={modal} title={edit ? 'Modifier Salle' : 'Ajouter Salle'} onClose={() => setModal(false)}>
        <form onSubmit={handleSave}>
          <label>Nom <input name="nom" value={form.nom} onChange={onChange} required /></label>
          <label>Capacité <input name="capacite" type="number" value={form.capacite} onChange={onChange} /></label>
          <label>Type d'agencement
            <select name="typeAgencement" value={form.typeAgencement} onChange={onChange}>
              {TYPE_AGENCEMENT_OPTIONS.map(o => (
                <option key={o.value} value={o.value}>{o.label}</option>
              ))}
            </select>
          </label>
          <label>Lieu
            <select name="idLieu" value={form.idLieu} onChange={onChange} required>
              <option value="">Sélectionner...</option>
              {lieux.map(l => (
                <option key={l.idLieu || l.id} value={l.idLieu || l.id}>{l.nom}</option>
              ))}
            </select>
          </label>
          <button type="submit">{edit ? 'Modifier' : 'Ajouter'}</button>
        </form>
      </Modal>
    </div>
  )
}

function PlacesTab() {
  const [places, setPlaces] = useState([])
  const [modal, setModal] = useState(false)
  const [edit, setEdit] = useState(null)
  const [batch, setBatch] = useState(false)
  const [form, setForm] = useState({ numeroPlace: '', rang: '', typePlace: '', prix: '', statut: 'DISPONIBLE' })
  const [batchForm, setBatchForm] = useState({ numeroSalle: '', nombreRangees: '', placesParRangee: '', prefixeRangee: '', typePlace: '', prix: '', debutNumero: '' })

  function load() { getAll('/api/organisateur/venues/places').then(setPlaces).catch(() => {}) }
  useEffect(() => { load() }, [])

  function onChange(e) { setForm({ ...form, [e.target.name]: e.target.value }) }
  function onBatchChange(e) { setBatchForm({ ...batchForm, [e.target.name]: e.target.value }) }

  function openCreate() { setEdit(null); setBatch(false); setForm({ numeroPlace: '', rang: '', typePlace: '', prix: '', statut: 'DISPONIBLE' }); setModal(true) }
  function openEdit(p) { setEdit(p); setBatch(false); setForm({ numeroPlace: p.numeroPlace || '', rang: p.rang || '', typePlace: p.typePlace || '', prix: p.prix || '', statut: p.statut || 'DISPONIBLE' }); setModal(true) }
  function openBatch() { setBatch(true); setEdit(null); setBatchForm({ numeroSalle: '', nombreRangees: '', placesParRangee: '', prefixeRangee: '', typePlace: '', prix: '', debutNumero: '' }); setModal(true) }

  async function handleSave(e) {
    e.preventDefault()
    try {
      if (edit) {
        await update('/api/organisateur/venues/places', edit.numeroPlace, { ...form, numeroPlace: edit.numeroPlace })
      } else {
        await create('/api/organisateur/venues/places', form)
      }
      setModal(false)
      load()
    } catch (err) { alert(err.message) }
  }

  async function handleBatchSave(e) {
    e.preventDefault()
    try {
      await create('/api/organisateur/venues/places/batch', {
        numeroSalle: batchForm.numeroSalle,
        nombreRangees: Number(batchForm.nombreRangees),
        placesParRangee: Number(batchForm.placesParRangee),
        prefixeRangee: batchForm.prefixeRangee,
        typePlace: batchForm.typePlace,
        prix: Number(batchForm.prix),
        debutNumero: Number(batchForm.debutNumero) || 1,
      })
      setModal(false)
      load()
    } catch (err) { alert(err.message) }
  }

  async function handleDelete(p) {
    if (!window.confirm('Supprimer cette place ?')) return
    try {
      await remove('/api/organisateur/venues/places', p.numeroPlace)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <button onClick={openCreate}>Ajouter une Place</button>
      <button onClick={openBatch}>Génération par Lot</button>
      <table>
        <thead><tr><th>Numéro</th><th>Rang</th><th>Type</th><th>Prix</th><th>Statut</th><th>Actions</th></tr></thead>
        <tbody>
          {places.map(p => (
            <tr key={p.numeroPlace}>
              <td>{p.numeroPlace}</td>
              <td>{p.rang}</td>
              <td>{p.typePlace}</td>
              <td>{p.prix}</td>
              <td>{p.statut}</td>
              <td>
                <button onClick={() => openEdit(p)}>Modifier</button>
                <button onClick={() => handleDelete(p)}>Supprimer</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <Modal show={modal} title={batch ? 'Génération par Lot' : edit ? 'Modifier Place' : 'Ajouter Place'} onClose={() => setModal(false)}>
        {batch ? (
          <form onSubmit={handleBatchSave}>
            <label>Numéro Salle <input name="numeroSalle" value={batchForm.numeroSalle} onChange={onBatchChange} required /></label>
            <label>Nombre de Rangées <input name="nombreRangees" type="number" value={batchForm.nombreRangees} onChange={onBatchChange} required /></label>
            <label>Places par Rangée <input name="placesParRangee" type="number" value={batchForm.placesParRangee} onChange={onBatchChange} required /></label>
            <label>Préfixe Rangée <input name="prefixeRangee" value={batchForm.prefixeRangee} onChange={onBatchChange} /></label>
            <label>Type de Place <input name="typePlace" value={batchForm.typePlace} onChange={onBatchChange} /></label>
            <label>Prix <input name="prix" type="number" step="0.01" value={batchForm.prix} onChange={onBatchChange} required /></label>
            <label>Numéro de Début <input name="debutNumero" type="number" value={batchForm.debutNumero} onChange={onBatchChange} /></label>
            <button type="submit">Générer</button>
          </form>
        ) : (
          <form onSubmit={handleSave}>
            <label>Numéro Place <input name="numeroPlace" value={form.numeroPlace} onChange={onChange} required disabled={!!edit} /></label>
            <label>Rang <input name="rang" value={form.rang} onChange={onChange} /></label>
            <label>Type de Place <input name="typePlace" value={form.typePlace} onChange={onChange} /></label>
            <label>Prix <input name="prix" type="number" step="0.01" value={form.prix} onChange={onChange} /></label>
            <label>Statut
              <select name="statut" value={form.statut} onChange={onChange}>
                <option value="DISPONIBLE">Disponible</option>
                <option value="RESERVEE">Réservée</option>
                <option value="INDISPONIBLE">Indisponible</option>
                <option value="EN_ATTENTE">En attente</option>
              </select>
            </label>
            <button type="submit">{edit ? 'Modifier' : 'Ajouter'}</button>
          </form>
        )}
      </Modal>
    </div>
  )
}

export default function OrganizerVenueManagement() {
  const [tab, setTab] = useState(0)

  return (
    <div className="venue-mgmt">
      <h1>Gestion des Lieux</h1>
      <div className="tabs">
        {TABS.map((t, i) => (
          <button key={i} className={i === tab ? 'active' : ''} onClick={() => setTab(i)}>{t}</button>
        ))}
      </div>
      {tab === 0 && <LieuxTab />}
      {tab === 1 && <SallesTab />}
      {tab === 2 && <PlacesTab />}
    </div>
  )
}
