import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getAll, getById, create, update, getUserInfo } from '../../api/entityApi'

const STEPS = ['Informations', 'Média', 'Lieu & Salle', 'Tarification', 'Récapitulatif']

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
  })

  const [placePricing, setPlacePricing] = useState({})

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
        })
      })
      .catch(err => setError(err.message))
  }, [id, isEdit])

  function set(field) {
    return e => setForm({ ...form, [field]: e.target.value })
  }

  async function handleSave() {
    setLoading(true)
    setError('')
    try {
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
      }
      if (isEdit) {
        await update('/api/evenements', id, payload)
      } else {
        const result = await create('/api/evenements', payload)
        const eventId = result?.data?.idEvenement || result?.idEvenement
      }
      navigate('/organizer')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function canNext() {
    if (step === 0) return form.titre && form.codeCategorie && form.dateEvenement
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
                          onChange={e => setForm({ ...form, numeroSalle: e.target.value })} />
                        <div>
                          <strong>{s.nomSalle || s.nom}</strong>
                          <span style={{ marginLeft: '8px', color: '#666', fontSize: '0.85rem' }}>
                            {s.capacite || s.places?.length || '?'} places
                          </span>
                        </div>
                      </label>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>
        )
      case 3:
        return (
          <div className="wizard-step">
            <h4>Tarification par type de place</h4>
            <p style={{ color: '#666', marginBottom: '1rem', fontSize: '0.9rem' }}>
              Salle : {salles.find(s => (s.numeroSalle || s.id) === form.numeroSalle)?.nomSalle || form.numeroSalle}
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
              <p><strong>Salle:</strong> {salles.find(s => (s.numeroSalle || s.id) === form.numeroSalle)?.nomSalle || form.numeroSalle}</p>
              <p><strong>Types de places:</strong></p>
              <ul>
                {placeTypes.map(type => (
                  <li key={type}>{type}: {placePricing[type]?.toFixed(2) || '0.00'} € ({selectedSallePlaces.filter(p => (p.typePlace || 'Standard') === type).length} places)</li>
                ))}
              </ul>
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
      <div className="wizard-nav">
        {step > 0 && <button className="btn-secondary" onClick={() => setStep(step - 1)}>Précédent</button>}
        <div />
        {step < STEPS.length - 1 ? (
          <button className="btn-primary" onClick={() => setStep(step + 1)} disabled={!canNext()}>
            Suivant
          </button>
        ) : (
          <button className="btn-success" onClick={handleSave} disabled={loading}>
            {loading ? 'Enregistrement...' : isEdit ? 'Mettre à jour' : 'Créer l\'événement'}
          </button>
        )}
      </div>
    </div>
  )
}
