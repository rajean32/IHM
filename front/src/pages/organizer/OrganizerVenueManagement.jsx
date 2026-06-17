import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAll, getById, create, update, remove } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

const TABS = ['Lieux', 'Salles', 'Places']

const TYPE_AGENCEMENT_OPTIONS = [
  { value: 'UNIQUEMENT_ASSIS', labelKey: 'layout.UNIQUEMENT_ASSIS' },
  { value: 'TABLE_ASSIS', labelKey: 'layout.TABLE_ASSIS' },
  { value: 'ASSIS_DEBOUT', labelKey: 'layout.ASSIS_DEBOUT' },
  { value: 'DEBOUT_AVEC_LIMITE', labelKey: 'layout.DEBOUT_AVEC_LIMITE' },
  { value: 'DEBOUT_SANS_LIMITE', labelKey: 'layout.DEBOUT_SANS_LIMITE' },
]

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

function LieuxTab({ t }) {
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
    if (!window.confirm(t('organizer.venues.deleteConfirm'))) return
    try {
      await remove('/api/organisateur/venues/lieux', l.idLieu || l.id)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <button className="btn-primary" onClick={openCreate}>{t('organizer.venues.addVenue')}</button>
      <div className="table-wrap" style={{ marginTop: '1rem' }}>
        <table>
          <thead><tr><th>{t('organizer.venues.name')}</th><th>{t('organizer.venues.address')}</th><th>{t('organizer.venues.city')}</th><th>{t('organizer.venues.capacity')}</th><th>{t('organizer.venues.actions')}</th></tr></thead>
          <tbody>
            {lieux.map(l => (
              <tr key={l.idLieu || l.id}>
                <td>{l.nom}</td>
                <td>{l.adresse}</td>
                <td>{l.ville}</td>
                <td>{l.capacite}</td>
                <td>
                  <button className="btn-icon" onClick={() => openEdit(l)}>{t('organizer.venues.edit')}</button>
                  <button className="btn-icon danger" onClick={() => handleDelete(l)}>{t('organizer.venues.delete')}</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Modal show={modal} title={edit ? t('organizer.venues.editVenue') : t('organizer.venues.createVenue')} onClose={() => setModal(false)}>
        <form onSubmit={handleSave}>
          <label>{t('organizer.venues.name')} <input name="nom" value={form.nom} onChange={onChange} required /></label>
          <label>{t('organizer.venues.address')} <input name="adresse" value={form.adresse} onChange={onChange} /></label>
          <label>{t('organizer.venues.city')} <input name="ville" value={form.ville} onChange={onChange} /></label>
          <label>{t('organizer.venues.capacity')} <input name="capacite" type="number" value={form.capacite} onChange={onChange} /></label>
          <button type="submit" className="btn-primary">{edit ? t('organizer.venues.edit') : t('organizer.venues.addVenue')}</button>
        </form>
      </Modal>
    </div>
  )
}

function SallesTab({ t }) {
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
    if (!window.confirm(t('organizer.venues.deleteRoomConfirm'))) return
    try {
      await remove('/api/organisateur/venues/salles', s.idSalle || s.id || s.numeroSalle)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <button className="btn-primary" onClick={openCreate}>{t('organizer.venues.addRoom')}</button>
      <div className="table-wrap" style={{ marginTop: '1rem' }}>
        <table>
          <thead><tr><th>{t('organizer.venues.roomName')}</th><th>{t('organizer.venues.roomCapacity')}</th><th>{t('organizer.venues.venue')}</th><th>{t('organizer.venues.layoutType')}</th><th>{t('organizer.venues.actions')}</th></tr></thead>
          <tbody>
            {salles.map(s => (
              <tr key={s.idSalle || s.id || s.numeroSalle}>
                <td>{s.nom || s.nomSalle}</td>
                <td>{s.capacite}</td>
                <td>{s.lieuNom || s.idLieu}</td>
                <td><span style={{ fontSize: '0.8rem', padding: '2px 8px', borderRadius: '8px', background: 'var(--primary-light)', color: 'var(--primary)' }}>{t(TYPE_AGENCEMENT_OPTIONS.find(o => o.value === s.typeAgencement)?.labelKey || 'common.unknown') || s.typeAgencement || '—'}</span></td>
                <td>
                  <button className="btn-icon" onClick={() => openEdit(s)}>{t('organizer.venues.edit')}</button>
                  <button className="btn-icon danger" onClick={() => handleDelete(s)}>{t('organizer.venues.delete')}</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Modal show={modal} title={edit ? t('organizer.venues.editRoom') : t('organizer.venues.createRoom')} onClose={() => setModal(false)}>
        <form onSubmit={handleSave}>
          <label>{t('organizer.venues.roomName')} <input name="nom" value={form.nom} onChange={onChange} required /></label>
          <label>{t('organizer.venues.roomCapacity')} <input name="capacite" type="number" value={form.capacite} onChange={onChange} /></label>
          <label>{t('organizer.venues.layoutType')}
            <select name="typeAgencement" value={form.typeAgencement} onChange={onChange}>
              {TYPE_AGENCEMENT_OPTIONS.map(o => (
                <option key={o.value} value={o.value}>{t(o.labelKey)}</option>
              ))}
            </select>
          </label>
          <label>{t('organizer.venues.venue')}
            <select name="idLieu" value={form.idLieu} onChange={onChange} required>
              <option value="">{t('organizer.venues.select')}</option>
              {lieux.map(l => (
                <option key={l.idLieu || l.id} value={l.idLieu || l.id}>{l.nom}</option>
              ))}
            </select>
          </label>
          <button type="submit" className="btn-primary">{edit ? t('organizer.venues.edit') : t('organizer.venues.addRoom')}</button>
        </form>
      </Modal>
    </div>
  )
}

function PlacesTab({ t }) {
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
    if (!window.confirm(t('organizer.venues.deletePlaceConfirm'))) return
    try {
      await remove('/api/organisateur/venues/places', p.numeroPlace)
      load()
    } catch (err) { alert(err.message) }
  }

  return (
    <div className="tab-content">
      <div style={{ display: 'flex', gap: '8px', marginBottom: '1rem' }}>
        <button className="btn-primary" onClick={openCreate}>{t('organizer.venues.addPlace')}</button>
        <button className="btn-secondary" onClick={openBatch}>{t('organizer.venues.batchGenerate')}</button>
      </div>
      <div className="table-wrap">
        <table>
          <thead><tr><th>{t('organizer.venues.placeNumber')}</th><th>{t('organizer.venues.placeRow')}</th><th>{t('organizer.venues.placeType')}</th><th>{t('organizer.venues.placePrice')}</th><th>{t('organizer.venues.placeStatus')}</th><th>{t('organizer.venues.actions')}</th></tr></thead>
          <tbody>
            {places.map(p => (
              <tr key={p.numeroPlace}>
                <td>{p.numeroPlace}</td>
                <td>{p.rang}</td>
                <td>{p.typePlace}</td>
                <td>{p.prix}</td>
                <td>{p.statut}</td>
                <td>
                  <button className="btn-icon" onClick={() => openEdit(p)}>{t('organizer.venues.edit')}</button>
                  <button className="btn-icon danger" onClick={() => handleDelete(p)}>{t('organizer.venues.delete')}</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Modal show={modal} title={batch ? t('organizer.venues.batchTitle') : edit ? t('organizer.venues.editPlace') : t('organizer.venues.createPlace')} onClose={() => setModal(false)}>
        {batch ? (
          <form onSubmit={handleBatchSave}>
            <label>{t('organizer.venues.batchRoom')} <input name="numeroSalle" value={batchForm.numeroSalle} onChange={onBatchChange} required /></label>
            <label>{t('organizer.venues.batchRows')} <input name="nombreRangees" type="number" value={batchForm.nombreRangees} onChange={onBatchChange} required /></label>
            <label>{t('organizer.venues.batchPerRow')} <input name="placesParRangee" type="number" value={batchForm.placesParRangee} onChange={onBatchChange} required /></label>
            <label>{t('organizer.venues.batchPrefix')} <input name="prefixeRangee" value={batchForm.prefixeRangee} onChange={onBatchChange} /></label>
            <label>{t('organizer.venues.batchType')} <input name="typePlace" value={batchForm.typePlace} onChange={onBatchChange} /></label>
            <label>{t('organizer.venues.batchPrice')} <input name="prix" type="number" step="0.01" value={batchForm.prix} onChange={onBatchChange} required /></label>
            <label>{t('organizer.venues.batchStart')} <input name="debutNumero" type="number" value={batchForm.debutNumero} onChange={onBatchChange} /></label>
            <button type="submit" className="btn-primary">{t('organizer.venues.batchSubmit')}</button>
          </form>
        ) : (
          <form onSubmit={handleSave}>
            <label>{t('organizer.venues.placeNumber')} <input name="numeroPlace" value={form.numeroPlace} onChange={onChange} required disabled={!!edit} /></label>
            <label>{t('organizer.venues.placeRow')} <input name="rang" value={form.rang} onChange={onChange} /></label>
            <label>{t('organizer.venues.placeType')} <input name="typePlace" value={form.typePlace} onChange={onChange} /></label>
            <label>{t('organizer.venues.placePrice')} <input name="prix" type="number" step="0.01" value={form.prix} onChange={onChange} /></label>
            <label>{t('organizer.venues.placeStatus')}
              <select name="statut" value={form.statut} onChange={onChange}>
                <option value="DISPONIBLE">{t('organizer.venues.available')}</option>
                <option value="RESERVEE">{t('organizer.venues.reserved')}</option>
                <option value="INDISPONIBLE">{t('organizer.venues.unavailable')}</option>
                <option value="EN_ATTENTE">{t('organizer.venues.pending')}</option>
              </select>
            </label>
            <button type="submit" className="btn-primary">{edit ? t('organizer.venues.edit') : t('organizer.venues.addPlace')}</button>
          </form>
        )}
      </Modal>
    </div>
  )
}

export default function OrganizerVenueManagement() {
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [tab, setTab] = useState(0)

  return (
    <div className="venue-mgmt">
      <div className="section-header">
        <button className="btn-secondary" onClick={() => navigate('/organizer')}>
          {t('organizer.venues.back')}
        </button>
        <h1>{t('organizer.venues.title')}</h1>
      </div>
      <div className="tabs">
        {TABS.map((tabLabel, i) => (
          <button key={i} className={i === tab ? 'active' : ''} onClick={() => setTab(i)}>{tabLabel}</button>
        ))}
      </div>
      {tab === 0 && <LieuxTab t={t} />}
      {tab === 1 && <SallesTab t={t} />}
      {tab === 2 && <PlacesTab t={t} />}
    </div>
  )
}
