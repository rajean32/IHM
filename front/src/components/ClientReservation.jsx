import { useState, useEffect } from 'react'
import { getAll, create } from '../api/entityApi'
import SeatMap from './SeatMap'

export default function ClientReservation({ userCode }) {
  const [events, setEvents] = useState([])
  const [selectedEventId, setSelectedEventId] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [paymentReservation, setPaymentReservation] = useState(null)
  const [paymentTickets, setPaymentTickets] = useState([])
  const [modePaiement, setModePaiement] = useState('')
  const [paying, setPaying] = useState(false)
  const [success, setSuccess] = useState('')

  useEffect(() => {
    loadEvents()
  }, [])

  async function loadEvents() {
    setLoading(true)
    try {
      const res = await getAll('/api/evenements/search?statut=Actif')
      const data = Array.isArray(res.data) ? res.data : []
      const evRes = await getAll('/api/evenements/upcoming')
      const upData = Array.isArray(evRes.data) ? evRes.data : []
      setEvents(data.length > 0 ? data : upData)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function handleReservationComplete(reservationId, tickets) {
    setPaymentReservation(reservationId)
    setPaymentTickets(tickets)
    setSelectedEventId(null)
  }

  async function handlePay() {
    if (!modePaiement) { setError('Choisissez un mode de paiement.'); return }
    setPaying(true)
    setError('')
    try {
      const montant = paymentTickets.reduce((sum, t) => sum + parseFloat(t.prix || 0), 0)
      await create('/api/paiements', {
        montant,
        datePaiement: new Date().toISOString().slice(0, 19),
        modePaiement,
        idReservation: paymentReservation,
      })
      setSuccess(`Paiement de ${montant.toFixed(2)} € confirmé pour la réservation #${paymentReservation}`)
      setPaymentReservation(null)
      setPaymentTickets([])
      setModePaiement('')
    } catch (err) {
      setError(err.message)
    } finally {
      setPaying(false)
    }
  }

  if (paymentReservation) {
    return (
      <div className="section-container">
        <h2>Paiement</h2>
        {error && <p className="msg error">{error}</p>}
        {success && <p className="msg success">{success}</p>}
        <div className="custom-form">
          <h3>Réservation #{paymentReservation}</h3>
          <p>{paymentTickets.length} ticket{paymentTickets.length > 1 ? 's' : ''}</p>
          <p>Total: <strong>{paymentTickets.reduce((s, t) => s + parseFloat(t.prix || 0), 0).toFixed(2)} €</strong></p>
          <label>
            Mode de paiement *
            <select value={modePaiement} onChange={e => setModePaiement(e.target.value)} required>
              <option value="">-- Choisir --</option>
              <option value="Carte Bancaire">Carte Bancaire</option>
              <option value="Mobile Money">Mobile Money</option>
              <option value="PayPal">PayPal</option>
            </select>
          </label>
          <div className="form-actions">
            <button className="btn-primary" onClick={handlePay} disabled={paying}>
              {paying ? '...' : 'Payer'}
            </button>
            <button className="btn-secondary" onClick={() => { setPaymentReservation(null); setPaymentTickets([]) }}>
              Annuler
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="section-container">
      <h2>Réserver des places</h2>
      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      {!selectedEventId && (
        <>
          <p className="form-subtitle">Sélectionnez un événement pour voir le plan des places</p>
          {loading && <p className="loading">Chargement...</p>}
          {!loading && events.length === 0 && <p className="empty">Aucun événement actif</p>}
          <div className="table-wrap">
            <table>
              <thead><tr><th>ID</th><th>Titre</th><th>Date</th><th>Lieu</th><th>Actions</th></tr></thead>
              <tbody>
                {events.map(ev => (
                  <tr key={ev.idEvenement}>
                    <td>{ev.idEvenement}</td>
                    <td>{ev.titre}</td>
                    <td>{ev.dateEvenement}</td>
                    <td>{ev.idLieu}</td>
                    <td>
                      <button className="btn-primary" onClick={() => setSelectedEventId(ev.idEvenement)}>
                        Choisir mes places
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      {selectedEventId && (
        <>
          <button className="btn-secondary" onClick={() => setSelectedEventId(null)} style={{ marginBottom: '1rem' }}>
            &larr; Retour aux événements
          </button>
          <SeatMap
            eventId={selectedEventId}
            userCode={userCode}
            onReservationComplete={handleReservationComplete}
          />
        </>
      )}
    </div>
  )
}
