import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getAll, getById, create, update, getUserInfo } from '../../api/entityApi'

const STEPS = ['Informations', 'Média', 'Lieu & Salle', 'Tarification', 'Récapitulatif']

const TYPE_AGENCEMENT_LABELS = {
  UNIQUEMENT_ASSIS: 'Uniquement assis',
  TABLE_ASSIS: 'Tables + chaises',
  ASSIS_DEBOUT: 'Assis/Debout mixte',
  DEBOUT_AVEC_LIMITE: 'Debout avec jauge',
  DEBOUT_SANS_LIMITE: 'Debout sans limite',
}

const TYPE_AGENCEMENT_OPTIONS = Object.entries(TYPE_AGENCEMENT_LABELS).map(([k, v]) => ({ value: k, label: v }))

export default function EventCreationWizard() {
  const navigate = useNavigate()
  const { id } = useParams()
  const isEdit = Boolean(id)
  const user = getUserInfo()

  const [step, setStep] = useState(0)
  const [categories, setCategories] = useState([])
  const [lieux, setLieux] = useState([])
  const [salles, setSalles] = useState([])
  const [selectedSallePlaces, setSelectedSallePlaces] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const [form, setForm] = useState({
    titre: '',
    description: '',
    codeCategorie: '',
    dateEvenement: '',
    heureEvenement: '',
    statut: 'planifie',
    image: '',
    idLieu: '',
    numeroSalle: '',
    typeAgencement: '',
  })

  const [placePricing, setPlacePricing] = useState({})
  const [standingZones, setStandingZones] = useState([])
  const [caracteristiques, setCaracteristiques] = useState([])
  const [caracteristiqueValues, setCaracteristiqueValues] = useState({})
  const [caracteristiquesLoading, setCaracteristiquesLoading] = useState(false)

  useEffect(() => {
    Promise.all([
      getAll('/api/categories').catch(() => ({ data: [] })),
      getAll('/api/lieux').catch(() => ({ data: [] })),
    ]).then(([cats, lieuxData]) => {
      setCategories(cats?.data || cats || [])
      setLieux(lieuxData?.data || lieuxData || [])
    })
  }, [])

  useEffect(() => {
    if (!form.codeCategorie) { setCaracteristiques([]); setCaracteristiquesLoading(false); return }
    setCaracteristiquesLoading(true)
    setCaracteristiqueValues({})
    getAll(`/api/caracteristiques/by-categorie/${form.codeCategorie}`)
      .then(resp => {
        const list = resp?.data || resp || []
        setCaracteristiques(list)
        setCaracteristiquesLoading(false)
      })
      .catch(() => { setCaracteristiques([]); setCaracteristiquesLoading(false) })
  }, [form.codeCategorie])

  useEffect(() => {
    if (!form.idLieu) { setSalles([]); return }
    getAll(`/api/lieux/${form.idLieu}`)
      .then(l => {
        const s = l?.salles || l?.data?.salles || []
        setSalles(s)
      })
      .catch(() => setSalles([]))
  }, [form.idLieu])

  useEffect(() => {
    if (!form.numeroSalle) { setSelectedSallePlaces([]); return }
    getAll(`/api/organisateur/venues/places?salle=${form.numeroSalle}`)
      .then(p => {
        const list = p?.data || p || []
        setSelectedSallePlaces(list)
        const pricing = {}
        for (const place of list) {
          const type = place.typePlace || 'Standard'
          if (!pricing[type]) pricing[type] = place.prix || 0
        }
        setPlacePricing(prev => ({ ...prev, ...pricing }))
      })
      .catch(() => setSelectedSallePlaces([]))
  }, [form.numeroSalle])

  useEffect(() => {
    if (!form.numeroSalle) return
    const salle = salles.find(s => (s.numeroSalle || s.id) === form.numeroSalle)
    if (salle?.typeAgencement && !form.typeAgencement) {
      setForm(prev => ({ ...prev, typeAgencement: salle.typeAgencement }))
    }
  }, [form.numeroSalle, salles, form.typeAgencement])

  useEffect(() => {
    if (!isEdit) return
    getById('/api/evenements', id)
      .then(ev => {
        const d = ev?.data || ev
        setForm({
          titre: d.titre || '',
          description: d.description || '',
          codeCategorie: d.codeCategorie || '',
          dateEvenement: d.dateEvenement || '',
          heureEvenement: d.heureEvenement || '',
          statut: d.statut || 'planifie',
          image: d.image || '',
          idLieu: d.idLieu || '',
          numeroSalle: '',
          typeAgencement: d.typeAgencement || '',
        })
      })
      .catch(err => setError(err.message))
  }, [id, isEdit])

  function set(field) {
    return e => setForm({ ...form, [field]: e.target.value })
  }

  function addStandingZone() {
    setStandingZones([...standingZones, { nom: '', capacite: '', prix: '' }])
  }

  function updateStandingZone(index, field, value) {
    const updated = [...standingZones]
    updated[index] = { ...updated[index], [field]: value }
    setStandingZones(updated)
  }

  function removeStandingZone(index) {
    setStandingZones(standingZones.filter((_, i) => i !== index))
  }

  function setCaracValue(id, value) {
    setCaracteristiqueValues(prev => ({ ...prev, [id]: value }))
  }

  function renderCaracteristiques() {
    if (caracteristiques.length === 0) return null
    const isRequiredEmpty = c => {
      const id = c.idCaracteristique || c.id
      const val = caracteristiqueValues[id]
      if (!c.obligatoire) return false
      if (c.typeDonnee === 'boolean') return val === undefined
      return val === undefined || String(val).trim() === ''
    }
    return (
      <div style={{ marginTop: '1rem' }}>
        <h4>Caractéristiques</h4>
        {caracteristiques.map(c => {
          const id = c.idCaracteristique || c.id
          const empty = isRequiredEmpty(c)
          const label = `${c.nom}${c.obligatoire ? ' *' : ''}`
          const val = caracteristiqueValues[id] || ''
          const inputStyle = { width: '100%', marginTop: '4px', ...(empty ? { borderColor: '#e94560', borderWidth: '2px' } : {}) }
          switch (c.typeDonnee) {
            case 'boolean':
              return (
                <div key={id} style={{ margin: '8px 0' }}>
                  <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <input type="checkbox" checked={val === 'true'} onChange={e => setCaracValue(id, e.target.checked ? 'true' : 'false')} />
                    {label}
                  </label>
                  {empty && <span style={{ fontSize: '0.75rem', color: '#e94560' }}>Requis</span>}
                </div>
              )
            case 'select': {
              const options = (c.options || '').split(',').map(s => s.trim()).filter(Boolean)
              return (
                <label key={id} style={{ display: 'block', margin: '8px 0' }}>
                  {label}
                  <select value={val} onChange={e => setCaracValue(id, e.target.value)} style={inputStyle}>
                    <option value="">Sélectionner...</option>
                    {options.map(o => <option key={o} value={o}>{o}</option>)}
                  </select>
                  {empty && <span style={{ fontSize: '0.75rem', color: '#e94560' }}>Ce champ est requis</span>}
                </label>
              )
            }
            case 'number':
              return (
                <label key={id} style={{ display: 'block', margin: '8px 0' }}>
                  {label}
                  <input type="number" value={val} onChange={e => setCaracValue(id, e.target.value)} style={inputStyle} />
                  {empty && <span style={{ fontSize: '0.75rem', color: '#e94560' }}>Ce champ est requis</span>}
                </label>
              )
            case 'date':
              return (
                <label key={id} style={{ display: 'block', margin: '8px 0' }}>
                  {label}
                  <input type="date" value={val} onChange={e => setCaracValue(id, e.target.value)} style={inputStyle} />
                  {empty && <span style={{ fontSize: '0.75rem', color: '#e94560' }}>Ce champ est requis</span>}
                </label>
              )
            default:
              return (
                <label key={id} style={{ display: 'block', margin: '8px 0' }}>
                  {label}
                  <input type="text" value={val} onChange={e => setCaracValue(id, e.target.value)} style={inputStyle} />
                  {empty && <span style={{ fontSize: '0.75rem', color: '#e94560' }}>Ce champ est requis</span>}
                </label>
              )
          }
        })}
      </div>
    )
  }

  function canUseStandingZones() {
    const t = form.typeAgencement
    return t === 'ASSIS_DEBOUT' || t === 'DEBOUT_AVEC_LIMITE' || t === 'DEBOUT_SANS_LIMITE'
  }

  async function handleSave() {
    setLoading(true)
    setError('')
    try {
      const caracteristiqueValeurs = Object.entries(caracteristiqueValues)
        .filter(([, v]) => v !== '' && v !== undefined)
        .map(([k, v]) => ({ idCaracteristique: Number(k), valeur: String(v) }))

      const payload = {
        titre: form.titre,
        description: form.description || undefined,
        codeCategorie: form.codeCategorie,
        dateEvenement: form.dateEvenement,
        heureEvenement: form.heureEvenement || undefined,
        statut: form.statut,
        image: form.image || undefined,
        codeLieu: form.idLieu,
        codeOrganisateur: user?.codeUtilisateur,
        typeAgencement: form.typeAgencement || undefined,
        caracteristiqueValeurs: caracteristiqueValeurs.length > 0 ? caracteristiqueValeurs : undefined,
      }
      if (form.numeroSalle) {
        payload.numeroSalle = form.numeroSalle
      }
      let eventId
      if (isEdit) {
        await update('/api/evenements', id, payload)
        eventId = id
      } else {
        const result = await create('/api/evenements', payload)
        eventId = result?.data?.idEvenement || result?.idEvenement
      }

      if (eventId && standingZones.length > 0) {
        for (const zone of standingZones) {
          await create(`/api/evenements/${eventId}/zones`, {
            nom: zone.nom,
            capacite: zone.capacite ? Number(zone.capacite) : null,
            prix: Number(zone.prix),
          })
        }
      }

      navigate('/organizer')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function canNext() {
    if (step === 0) {
      if (!form.titre || !form.codeCategorie || !form.dateEvenement) return false
      if (caracteristiquesLoading) return false
      const requiredCaracs = caracteristiques.filter(c => c.obligatoire)
      if (requiredCaracs.length === 0) return true
      return requiredCaracs.every(c => {
        const id = c.idCaracteristique || c.id
        const val = caracteristiqueValues[id]
        if (c.typeDonnee === 'boolean') return val !== undefined
        return val !== undefined && String(val).trim() !== ''
      })
    }
    if (step === 2) return form.idLieu && form.numeroSalle
    return true
  }

  const typePlaceColors = {
    VIP: '#9b59b6',
    Premium: '#e67e22',
    Standard: '#3498db',
    'Première classe': '#2ecc71',
  }

  const placeTypes = [...new Set(selectedSallePlaces.map(p => p.typePlace || 'Standard'))]
  const currentSalle = salles.find(s => (s.numeroSalle || s.id) === form.numeroSalle)
  const isStandingOnly = form.typeAgencement === 'DEBOUT_AVEC_LIMITE' || form.typeAgencement === 'DEBOUT_SANS_LIMITE'

  function renderStep() {
    switch (step) {
      case 0:
        return (
          <div className="wizard-step">
            <label>Titre <input value={form.titre} onChange={set('titre')} required /></label>
            <label>Description <textarea value={form.description} onChange={set('description')} /></label>
            <label>Catégorie
              <select value={form.codeCategorie} onChange={set('codeCategorie')} required>
                <option value="">Sélectionner...</option>
                {categories.map(c => (
                  <option key={c.codeCategorie || c.id} value={c.codeCategorie || c.id}>
                    {c.nomCategorie || c.nom || c.libelle}
                  </option>
                ))}
              </select>
            </label>
            <label>Date <input type="date" value={form.dateEvenement} onChange={set('dateEvenement')} required /></label>
            <label>Heure <input type="time" value={form.heureEvenement} onChange={set('heureEvenement')} /></label>
            <label>Statut
              <select value={form.statut} onChange={set('statut')}>
                <option value="planifie">Planifié</option>
                <option value="en_cours">En cours</option>
                <option value="termine">Terminé</option>
                <option value="annule">Annulé</option>
              </select>
            </label>
            {renderCaracteristiques()}
          </div>
        )
      case 1:
        return (
          <div className="wizard-step">
            <label>Image (URL) <input value={form.image} onChange={set('image')} placeholder="https://..." /></label>
          </div>
        )
      case 2:
        return (
          <div className="wizard-step">
            <label>Lieu
              <select value={form.idLieu} onChange={set('idLieu')} required>
                <option value="">Sélectionner un lieu...</option>
                {lieux.map(l => (
                  <option key={l.idLieu || l.id} value={l.idLieu || l.id}>
                    {l.nomLieu || l.nom || l.libelle} {l.ville ? `(${l.ville})` : ''}
                  </option>
                ))}
              </select>
            </label>
            {form.idLieu && (
              <>
                <h4 style={{ marginTop: '1rem', marginBottom: '0.5rem' }}>Salles disponibles</h4>
                {salles.length === 0 ? (
                  <p style={{ color: '#666' }}>Aucune salle trouvée pour ce lieu.</p>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {salles.map(s => (
                      <label key={s.numeroSalle || s.id} style={{
                        display: 'flex', alignItems: 'center', gap: '12px',
                        padding: '12px', border: `2px solid ${form.numeroSalle === (s.numeroSalle || s.id) ? '#0f3460' : '#ddd'}`,
                        borderRadius: '8px', cursor: 'pointer',
                        background: form.numeroSalle === (s.numeroSalle || s.id) ? '#f0f4ff' : '#fff',
                      }}>
                        <input type="radio" name="salle" value={s.numeroSalle || s.id}
                          checked={form.numeroSalle === (s.numeroSalle || s.id)}
                          onChange={e => {
                            setForm({ ...form, numeroSalle: e.target.value, typeAgencement: s.typeAgencement || '' })
                          }} />
                        <div>
                          <strong>{s.nomSalle || s.nom}</strong>
                          <span style={{ marginLeft: '8px', color: '#666', fontSize: '0.85rem' }}>
                            {s.capacite || '?'} places
                          </span>
                          {s.typeAgencement && (
                            <span style={{ marginLeft: '8px', fontSize: '0.8rem', color: '#0f3460', background: '#e8edf5', padding: '1px 8px', borderRadius: '8px' }}>
                              {TYPE_AGENCEMENT_LABELS[s.typeAgencement] || s.typeAgencement}
                            </span>
                          )}
                        </div>
                      </label>
                    ))}
                  </div>
                )}
                {form.numeroSalle && (
                  <div style={{ marginTop: '1rem', padding: '12px', background: '#f8f9fa', borderRadius: '8px' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: 0 }}>
                      <span style={{ fontWeight: 500 }}>Type d'agencement (surcharge):</span>
                      <select value={form.typeAgencement} onChange={set('typeAgencement')} style={{ flex: 1 }}>
                        {TYPE_AGENCEMENT_OPTIONS.map(opt => (
                          <option key={opt.value} value={opt.value}>{opt.label}</option>
                        ))}
                      </select>
                    </label>
                    <p style={{ fontSize: '0.8rem', color: '#888', marginTop: '4px' }}>
                      Par défaut : celui de la salle. Vous pouvez le surcharger pour cet événement.
                    </p>
                  </div>
                )}
              </>
            )}
          </div>
        )
      case 3:
        return (
          <div className="wizard-step">
            {isStandingOnly ? (
              <>
                <h4>Configuration des zones debout</h4>
                <p style={{ color: '#666', marginBottom: '1rem', fontSize: '0.9rem' }}>
                  {form.typeAgencement === 'DEBOUT_AVEC_LIMITE'
                    ? 'Cet événement est debout avec jauge. Définissez la capacité maximale.'
                    : 'Cet événement est debout sans limite de places.'}
                </p>
                {standingZones.map((zone, i) => (
                  <div key={i} style={{
                    padding: '16px', border: '1px solid #e0e0e0', borderRadius: '8px',
                    background: '#fafafa', marginBottom: '12px',
                  }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                      <strong>Zone {i + 1}</strong>
                      <button className="btn-danger" style={{ padding: '4px 10px', fontSize: '0.8rem' }}
                        onClick={() => removeStandingZone(i)}>Supprimer</button>
                    </div>
                    <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                      <label style={{ flex: 1, minWidth: '120px' }}>
                        Nom
                        <input value={zone.nom} onChange={e => updateStandingZone(i, 'nom', e.target.value)}
                          placeholder="Ex: Fosse, Pelouse..." />
                      </label>
                      {form.typeAgencement === 'DEBOUT_AVEC_LIMITE' && (
                        <label style={{ flex: 1, minWidth: '100px' }}>
                          Capacité max
                          <input type="number" min="1" value={zone.capacite}
                            onChange={e => updateStandingZone(i, 'capacite', e.target.value)}
                            placeholder="Ex: 500" />
                        </label>
                      )}
                      <label style={{ flex: 1, minWidth: '100px' }}>
                        Prix unitaire (€)
                        <input type="number" step="0.01" min="0" value={zone.prix}
                          onChange={e => updateStandingZone(i, 'prix', e.target.value)} />
                      </label>
                    </div>
                  </div>
                ))}
                <button className="btn-secondary" onClick={addStandingZone}>
                  + Ajouter une zone debout
                </button>
              </>
            ) : form.typeAgencement === 'ASSIS_DEBOUT' ? (
              <>
                <h4>Places assises</h4>
                <p style={{ color: '#666', marginBottom: '1rem', fontSize: '0.9rem' }}>
                  Salle : {currentSalle?.nomSalle || form.numeroSalle}
                </p>
                {selectedSallePlaces.length === 0 ? (
                  <p>Aucune place trouvée dans cette salle.</p>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                    {placeTypes.map(type => (
                      <div key={type} style={{
                        padding: '16px', border: '1px solid #e0e0e0', borderRadius: '8px', background: '#fafafa',
                      }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                          <span style={{ display: 'inline-block', width: '12px', height: '12px', borderRadius: '50%', background: typePlaceColors[type] || '#3498db' }}></span>
                          <strong>{type}</strong>
                          <span style={{ color: '#666', fontSize: '0.85rem' }}>
                            ({selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length} places)
                          </span>
                        </div>
                        <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          Prix unitaire :
                          <input type="number" step="0.01" min="0"
                            value={placePricing[type] || ''}
                            onChange={e => setPlacePricing({ ...placePricing, [type]: parseFloat(e.target.value) || 0 })}
                            style={{ width: '120px' }} /> €
                        </label>
                      </div>
                    ))}
                  </div>
                )}
                <hr style={{ margin: '1.5rem 0' }} />
                <h4>Zones debout</h4>
                {standingZones.map((zone, i) => (
                  <div key={i} style={{
                    padding: '16px', border: '1px solid #e0e0e0', borderRadius: '8px',
                    background: '#fafafa', marginBottom: '12px',
                  }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                      <strong>Zone debout {i + 1}</strong>
                      <button className="btn-danger" style={{ padding: '4px 10px', fontSize: '0.8rem' }}
                        onClick={() => removeStandingZone(i)}>Supprimer</button>
                    </div>
                    <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                      <label style={{ flex: 1, minWidth: '120px' }}>
                        Nom <input value={zone.nom} onChange={e => updateStandingZone(i, 'nom', e.target.value)} placeholder="Ex: Fosse" />
                      </label>
                      <label style={{ flex: 1, minWidth: '100px' }}>
                        Capacité max <input type="number" min="1" value={zone.capacite}
                          onChange={e => updateStandingZone(i, 'capacite', e.target.value)} placeholder="Ex: 200" />
                      </label>
                      <label style={{ flex: 1, minWidth: '100px' }}>
                        Prix (€) <input type="number" step="0.01" min="0" value={zone.prix}
                          onChange={e => updateStandingZone(i, 'prix', e.target.value)} />
                      </label>
                    </div>
                  </div>
                ))}
                <button className="btn-secondary" onClick={addStandingZone}>
                  + Ajouter une zone debout
                </button>
              </>
            ) : (
              <>
                <h4>Tarification par type de place</h4>
                <p style={{ color: '#666', marginBottom: '1rem', fontSize: '0.9rem' }}>
                  Salle : {currentSalle?.nomSalle || form.numeroSalle}
                </p>
                {selectedSallePlaces.length === 0 ? (
                  <p>Aucune place trouvée dans cette salle.</p>
                ) : (
                  <>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                      {placeTypes.map(type => (
                        <div key={type} style={{
                          padding: '16px', border: '1px solid #e0e0e0', borderRadius: '8px',
                          background: '#fafafa',
                        }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                            <span style={{
                              display: 'inline-block', width: '12px', height: '12px', borderRadius: '50%',
                              background: typePlaceColors[type] || '#3498db',
                            }}></span>
                            <strong>{type}</strong>
                            <span style={{ color: '#666', fontSize: '0.85rem' }}>
                              ({selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length} places)
                            </span>
                          </div>
                          <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            Prix unitaire :
                            <input type="number" step="0.01" min="0"
                              value={placePricing[type] || ''}
                              onChange={e => setPlacePricing({ ...placePricing, [type]: parseFloat(e.target.value) || 0 })}
                              style={{ width: '120px' }} /> €
                          </label>
                          <div style={{ display: 'flex', gap: '4px', marginTop: '8px', flexWrap: 'wrap' }}>
                            {selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).slice(0, 20).map(p => (
                              <span key={p.numeroPlace} style={{
                                padding: '2px 6px', borderRadius: '4px', fontSize: '0.75rem',
                                background: `${typePlaceColors[type] || '#3498db'}22`,
                                border: `1px solid ${typePlaceColors[type] || '#3498db'}`,
                              }}>{p.numeroPlace}</span>
                            ))}
                            {selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length > 20 &&
                              <span style={{ fontSize: '0.75rem', color: '#666' }}>+{selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length - 20}...</span>}
                          </div>
                        </div>
                      ))}
                    </div>
                    <p style={{ marginTop: '1rem', fontSize: '0.85rem', color: '#666' }}>
                      Les prix seront appliqués individuellement à chaque place. Vous pouvez aussi modifier les prix
                      via la section <strong>Gestion des places</strong> après la création.
                    </p>
                  </>
                )}
              </>
            )}
          </div>
        )
      case 4:
        return (
          <div className="wizard-step">
            <h4>Récapitulatif</h4>
            <div style={{ display: 'grid', gap: '8px', marginTop: '1rem' }}>
              <p><strong>Titre:</strong> {form.titre}</p>
              <p><strong>Description:</strong> {form.description || '—'}</p>
              <p><strong>Catégorie:</strong> {categories.find(c => (c.codeCategorie || c.id) === form.codeCategorie)?.nomCategorie || form.codeCategorie}</p>
              <p><strong>Date:</strong> {form.dateEvenement} {form.heureEvenement}</p>
              <p><strong>Statut:</strong> {form.statut}</p>
              <p><strong>Image:</strong> {form.image || '—'}</p>
              <p><strong>Lieu:</strong> {lieux.find(l => (l.idLieu || l.id) === form.idLieu)?.nomLieu || form.idLieu}</p>
              <p><strong>Salle:</strong> {currentSalle?.nomSalle || form.numeroSalle}</p>
              <p><strong>Type d'agencement:</strong> {TYPE_AGENCEMENT_LABELS[form.typeAgencement] || form.typeAgencement}</p>
              {Object.keys(caracteristiqueValues).filter(k => caracteristiqueValues[k]).length > 0 && (
                <>
                  <p><strong>Caractéristiques:</strong></p>
                  <ul>
                    {Object.entries(caracteristiqueValues)
                      .filter(([, v]) => v)
                      .map(([k, v]) => {
                        const c = caracteristiques.find(c => (c.idCaracteristique || c.id) === Number(k))
                        return <li key={k}>{c?.nom || k}: {v}</li>
                      })}
                  </ul>
                </>
              )}
              {!isStandingOnly && placeTypes.length > 0 && (
                <>
                  <p><strong>Types de places assises:</strong></p>
                  <ul>
                    {placeTypes.map(type => (
                      <li key={type}>{type}: {placePricing[type]?.toFixed(2) || '0.00'} € ({selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length} places)</li>
                    ))}
                  </ul>
                </>
              )}
              {standingZones.length > 0 && (
                <>
                  <p><strong>Zones debout:</strong></p>
                  <ul>
                    {standingZones.map((z, i) => (
                      <li key={i}>Zone {i + 1} - {z.nom || '(nom à définir)'}: {z.capacite ? z.capacite + ' places max' : 'Sans limite'} - {Number(z.prix).toFixed(2)} €</li>
                    ))}
                  </ul>
                </>
              )}
            </div>
          </div>
        )
      default:
        return null
    }
  }

  return (
    <div className="wizard">
      <h1>{isEdit ? 'Modifier Événement' : 'Créer un Événement'}</h1>
      <div className="wizard-steps">
        {STEPS.map((s, i) => (
          <span key={i} className={`wizard-step ${i === step ? 'active' : ''} ${i < step ? 'completed' : ''}`}>
            <span className="step-num">{i + 1}</span>
            {s}
          </span>
        ))}
      </div>
      {error && <div className="error-msg">{error}</div>}
      <div className="wizard-content">
        {renderStep()}
      </div>
      <div className="wizard-nav" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button className="btn-secondary" onClick={() => navigate('/organizer')}>
            Annuler
          </button>
          {step > 0 && <button className="btn-secondary" onClick={() => setStep(step - 1)}>Précédent</button>}
        </div>
        {step < STEPS.length - 1 ? (
          <button className="btn-primary" onClick={() => setStep(step + 1)} disabled={!canNext()}>
            Suivant
          </button>
        ) : (
          <button className="btn-success" onClick={handleSave} disabled={loading}>
            {loading ? 'Enregistrement...' : isEdit ? 'Mettre à jour' : "Créer l'événement"}
          </button>
        )}
      </div>
    </div>
  )
}
