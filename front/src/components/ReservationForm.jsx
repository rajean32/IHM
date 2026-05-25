import { useState, useEffect } from 'react'
import { getAll, create } from '../api/entityApi'

export default function ReservationForm({ userRole, userCode }) {
  const [records, setRecords] = useState([])
  const [tickets, setTickets] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [selectedTickets, setSelectedTickets] = useState([])

  const isClient = userRole === 'CLIENT'

  async function fetchAll() {
    setLoading(true)
    try {
      const [rRes, tRes] = await Promise.all([
        getAll('/api/reservations'),
        getAll('/api/tickets'),
      ])
      let data = Array.isArray(rRes.data) ? rRes.data : []
      if (isClient) {
        data = data.filter(r => r.codeClient === userCode)
      }
      setRecords(data)
      setTickets(Array.isArray(tRes.data) ? tRes.data : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchAll() }, [])

  function toggleTicket(code) {
    setSelectedTickets(prev =>
      prev.includes(code) ? prev.filter(t => t !== code) : [...prev, code]
    )
    setError('')
    setSuccess('')
  }

  async function handleCreate(e) {
    e.preventDefault()
    if (!isClient) return
    if (selectedTickets.length === 0) { setError('Sélectionnez au moins un ticket.'); return }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const payload = {
        dateReservation: new Date().toISOString().slice(0, 19),
        codeClient: userCode,
        codeTickets: selectedTickets,
      }
      const res = await create('/api/reservations', payload)
      setSuccess(`Réservation #${res.data.idReservation} confirmée — vous pouvez maintenant procéder au paiement`)
      setSelectedTickets([])
      setShowForm(false)
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function totalPrice() {
    return selectedTickets.reduce((sum, code) => {
      const t = tickets.find(t => t.codeTicket === code)
      return sum + (t ? parseFloat(t.prix) : 0)
    }, 0).toFixed(2)
  }

  return (
    <div className="section-container">
      <h2>Mes Réservations</h2>

      {isClient && (
        <div className="section-header" style={{ marginBottom: '1rem' }}>
          <button className="btn-primary" onClick={() => { setShowForm(true); setSelectedTickets([]); setError(''); setSuccess('') }}>
            + Nouvelle réservation
          </button>
        </div>
      )}

      {!isClient && (
        <p className="form-subtitle" style={{ marginBottom: '1rem' }}>Consultation des réservations</p>
      )}

      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      {showForm && isClient && (
        <form className="custom-form" onSubmit={handleCreate}>
          <h3>Nouvelle réservation</h3>
          <p className="form-subtitle">
            Date: {new Date().toLocaleDateString('fr-FR')} — Client: {userCode}
          </p>

          <h4 style={{ marginTop: '1rem' }}>Sélection des tickets</h4>
          {tickets.length === 0 && <p className="empty">Aucun ticket disponible</p>}
          <div className="ticket-grid">
            {tickets.map(t => (
              <label key={t.codeTicket} className={`ticket-card ${selectedTickets.includes(t.codeTicket) ? 'selected' : ''}`}>
                <input
                  type="checkbox"
                  checked={selectedTickets.includes(t.codeTicket)}
                  onChange={() => toggleTicket(t.codeTicket)}
                />
                <div>
                  <strong>{t.codeTicket}</strong>
                  <span className="price">{parseFloat(t.prix).toFixed(2)} €</span>
                </div>
              </label>
            ))}
          </div>

          {selectedTickets.length > 0 && (
            <p className="total-price">
              Total: <strong>{totalPrice()} €</strong> ({selectedTickets.length} ticket{selectedTickets.length > 1 ? 's' : ''})
            </p>
          )}

          <div className="form-actions">
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? '...' : 'Confirmer la réservation'}
            </button>
            <button type="button" className="btn-secondary" onClick={() => setShowForm(false)}>Annuler</button>
          </div>
        </form>
      )}

      {!showForm && !loading && records.length === 0 && <p className="empty">Aucune réservation</p>}

      {records.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead><tr><th>ID</th><th>Date</th><th>Client</th></tr></thead>
            <tbody>
              {records.map(r => (
                <tr key={r.idReservation}>
                  <td>{r.idReservation}</td>
                  <td>{r.dateReservation}</td>
                  <td>{r.codeClient}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
