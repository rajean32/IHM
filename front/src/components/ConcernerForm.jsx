import { useState, useEffect } from 'react'
import { getAll, create } from '../api/entityApi'

export default function ConcernerForm({ userRole, userCode }) {
  const [evenements, setEvenements] = useState([])
  const [tickets, setTickets] = useState([])
  const [places, setPlaces] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const [idEvenement, setIdEvenement] = useState('')
  const [codeTicket, setCodeTicket] = useState('')
  const [numeroPlace, setNumeroPlace] = useState('')

  async function fetchAll() {
    setLoading(true)
    try {
      const [evenRes, tickRes, placeRes] = await Promise.all([
        getAll('/api/evenements'),
        getAll('/api/tickets'),
        getAll('/api/places'),
      ])
      let evts = Array.isArray(evenRes.data) ? evenRes.data : []
      if (userRole === 'ORGANISATEUR') {
        evts = evts.filter(e => e.codeOrganisateur === userCode)
      }
      setEvenements(evts)
      setTickets(Array.isArray(tickRes.data) ? tickRes.data : [])
      setPlaces(Array.isArray(placeRes.data) ? placeRes.data : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchAll() }, [])

  async function handleAssociate(e) {
    e.preventDefault()
    if (!idEvenement || !codeTicket || !numeroPlace) {
      setError('Tous les champs sont obligatoires.')
      return
    }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const payload = { idEvenement: Number(idEvenement), codeTicket, numeroPlace }
      await create('/api/concerner', payload)
      setSuccess(`Association créée : ${codeTicket} → Év. #${idEvenement}, Place ${numeroPlace}`)
      setIdEvenement('')
      setCodeTicket('')
      setNumeroPlace('')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="section-container">
      <h2>Affectation Places & Tickets</h2>
      <p className="form-subtitle">
        Lier un Événement, un Ticket et une Place via CONCERNER
        {userRole === 'ORGANISATEUR' && ' — seuls vos événements sont affichés'}
      </p>

      <form className="custom-form" onSubmit={handleAssociate}>
        <div className="form-row three-col">
          <label>Événement *
            <select value={idEvenement} onChange={e => setIdEvenement(e.target.value)} required>
              <option value="">-- Sélectionner --</option>
              {evenements.map(e => (
                <option key={e.idEvenement} value={e.idEvenement}>{e.titre} (#{e.idEvenement})</option>
              ))}
            </select>
          </label>

          <label>Ticket *
            <select value={codeTicket} onChange={e => setCodeTicket(e.target.value)} required>
              <option value="">-- Sélectionner --</option>
              {tickets.map(t => (
                <option key={t.codeTicket} value={t.codeTicket}>{t.codeTicket} — {parseFloat(t.prix).toFixed(2)} €</option>
              ))}
            </select>
          </label>

          <label>Place *
            <select value={numeroPlace} onChange={e => setNumeroPlace(e.target.value)} required>
              <option value="">-- Sélectionner --</option>
              {places.map(p => (
                <option key={p.numeroPlace} value={p.numeroPlace}>{p.numeroPlace} (rangée {p.range || '?'})</option>
              ))}
            </select>
          </label>
        </div>

        {error && <p className="msg error">{error}</p>}
        {success && <p className="msg success">{success}</p>}

        <button type="submit" className="btn-primary" disabled={loading}>
          {loading ? 'Association...' : 'Associer'}
        </button>
      </form>
    </div>
  )
}
