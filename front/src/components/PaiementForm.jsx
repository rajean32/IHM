import { useState, useEffect } from 'react'
import { getAll, getById, create } from '../api/entityApi'

export default function PaiementForm({ userRole, userCode }) {
  const [records, setRecords] = useState([])
  const [reservations, setReservations] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [showForm, setShowForm] = useState(false)

  const [idReservation, setIdReservation] = useState('')
  const [montant, setMontant] = useState('')
  const [modePaiement, setModePaiement] = useState('')
  const [calculating, setCalculating] = useState(false)

  const isClient = userRole === 'CLIENT'

  async function fetchAll() {
    setLoading(true)
    try {
      const [pRes, rRes] = await Promise.all([
        getAll('/api/paiements'),
        getAll('/api/reservations'),
      ])
      let rData = Array.isArray(rRes.data) ? rRes.data : []
      if (isClient) {
        rData = rData.filter(r => r.codeClient === userCode)
      }
      setRecords(Array.isArray(pRes.data) ? pRes.data : [])
      setReservations(rData)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchAll() }, [])

  async function onReservationChange(resId) {
    setIdReservation(resId)
    setError('')
    if (!resId) { setMontant(''); return }
    setCalculating(true)
    try {
      const res = await getById('/api/reservations', resId)
      const data = res.data
      if (data && data.codeTickets && data.codeTickets.length > 0) {
        const tRes = await getAll('/api/tickets')
        const tickets = Array.isArray(tRes.data) ? tRes.data : []
        const total = data.codeTickets.reduce((sum, code) => {
          const t = tickets.find(tc => tc.codeTicket === code)
          return sum + (t ? parseFloat(t.prix) : 0)
        }, 0)
        setMontant(total.toFixed(2))
      } else {
        setMontant('0.00')
      }
    } catch {
      setMontant('0.00')
    } finally {
      setCalculating(false)
    }
  }

  async function handleCreate(e) {
    e.preventDefault()
    if (!isClient) return
    if (!montant || parseFloat(montant) <= 0) { setError('Montant invalide.'); return }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const payload = {
        montant: parseFloat(montant),
        datePaiement: new Date().toISOString().slice(0, 19),
        modePaiement,
        idReservation: Number(idReservation),
      }
      await create('/api/paiements', payload)
      setSuccess('Paiement enregistré avec succès')
      setIdReservation(''); setMontant(''); setModePaiement('')
      setShowForm(false)
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const paiementsIds = new Set(records.map(r => r.idReservation))
  const dispoReservations = reservations.filter(r => !paiementsIds.has(r.idReservation))

  return (
    <div className="section-container">
      <h2>Paiements</h2>

      {isClient && (
        <div className="section-header" style={{ marginBottom: '1rem' }}>
          <button className="btn-primary" onClick={() => { setShowForm(true); setIdReservation(''); setMontant(''); setModePaiement(''); setError(''); setSuccess('') }}>
            + Nouveau paiement
          </button>
        </div>
      )}

      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      {showForm && isClient && (
        <form className="custom-form" onSubmit={handleCreate}>
          <h3>Régler une réservation</h3>

          <label>
            Réservation *
            <select value={idReservation} onChange={e => onReservationChange(e.target.value)} required>
              <option value="">-- Sélectionner --</option>
              {dispoReservations.map(r => (
                <option key={r.idReservation} value={r.idReservation}>Réservation #{r.idReservation}</option>
              ))}
            </select>
            {reservations.length > 0 && dispoReservations.length === 0 && (
              <small className="hint">Toutes vos réservations ont déjà été payées</small>
            )}
          </label>

          <label>
            Montant (€) *
            <input type="number" step="0.01" value={montant} onChange={e => setMontant(e.target.value)} required />
            {calculating && <small className="hint">Calcul...</small>}
            {!calculating && idReservation && montant && <small className="hint">Montant calculé automatiquement d'après les tickets</small>}
          </label>

          <label>
            Mode de paiement *
            <select value={modePaiement} onChange={e => setModePaiement(e.target.value)} required>
              <option value="">-- Choisir --</option>
              <option value="Carte Bancaire">Carte Bancaire</option>
              <option value="Mobile Money">Mobile Money</option>
              <option value="PayPal">PayPal</option>
              <option value="Espèces">Espèces</option>
            </select>
          </label>

          <p className="form-subtitle">Date: {new Date().toLocaleString('fr-FR')}</p>

          <div className="form-actions">
            <button type="submit" className="btn-primary" disabled={loading || calculating}>
              {loading ? '...' : 'Payer'}
            </button>
            <button type="button" className="btn-secondary" onClick={() => setShowForm(false)}>Annuler</button>
          </div>
        </form>
      )}

      {!showForm && !loading && records.length === 0 && <p className="empty">Aucun paiement</p>}

      {records.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead><tr><th>ID</th><th>Montant</th><th>Date</th><th>Mode</th><th>Réservation</th></tr></thead>
            <tbody>
              {records.map(r => (
                <tr key={r.idPaiement}>
                  <td>{r.idPaiement}</td>
                  <td>{parseFloat(r.montant).toFixed(2)} €</td>
                  <td>{r.datePaiement}</td>
                  <td><span className="badge">{r.modePaiement}</span></td>
                  <td>#{r.idReservation}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
