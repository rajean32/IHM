import { useState, useEffect } from 'react'
import { getAll, create } from '../api/entityApi'

const STATUT_COLORS = {
  DISPONIBLE: '#4ade80',
  RESERVEE: '#f87171',
  INDISPONIBLE: '#9ca3af',
  EN_ATTENTE: '#fbbf24',
}

export default function SeatMap({ eventId, userCode, onReservationComplete }) {
  const [seats, setSeats] = useState([])
  const [event, setEvent] = useState(null)
  const [selectedSeats, setSelectedSeats] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  useEffect(() => {
    loadData()
  }, [eventId])

  async function loadData() {
    setLoading(true)
    try {
      const [evRes, seatsRes] = await Promise.all([
        getAll(`/api/evenements/${eventId}/detail`),
        getAll(`/api/evenements/${eventId}/places/available`),
      ])
      setEvent(evRes.data)
      const allSeats = Array.isArray(seatsRes.data) ? seatsRes.data : []
      const grouped = {}
      for (const s of allSeats) {
        const rang = s.rang || 'U'
        if (!grouped[rang]) grouped[rang] = []
        grouped[rang].push(s)
      }
      for (const r in grouped) {
        grouped[r].sort((a, b) => {
          const getSeatNum = (np) => { const p = np.split('-'); return parseInt((p.length > 1 ? p[p.length-1] : np).replace(/[A-Za-z]/g, '')) || 0 }
          const na = getSeatNum(a.numeroPlace)
          const nb = getSeatNum(b.numeroPlace)
          return na - nb
        })
      }
      setSeats(grouped)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  function toggleSeat(seat) {
    if (!seat.disponible) return
    setSelectedSeats(prev => {
      const exists = prev.find(s => s.numeroPlace === seat.numeroPlace)
      if (exists) return prev.filter(s => s.numeroPlace !== seat.numeroPlace)
      return [...prev, seat]
    })
    setError('')
    setSuccess('')
  }

  function totalPrice() {
    return selectedSeats.reduce((sum, s) => sum + parseFloat(s.prix || 0), 0).toFixed(2)
  }

  async function handleReserve() {
    if (selectedSeats.length === 0) { setError('Sélectionnez au moins une place.'); return }
    setLoading(true)
    setError('')
    setSuccess('')
    try {
      const tickets = []
      for (const seat of selectedSeats) {
        const d = new Date(); const dc = `${String(d.getMonth()+1).padStart(2,'0')}${String(d.getDate()).padStart(2,'0')}${String(d.getHours()).padStart(2,'0')}`; const sq = String(Date.now() % 1000).padStart(3, '0')
        const codeTicket = `TKT${eventId}${dc}${sq}`
        await create('/api/tickets', {
          codeTicket,
          prix: parseFloat(seat.prix || 0),
          idEvenement: eventId,
          numeroPlace: seat.numeroPlace,
        })
        tickets.push(codeTicket)
      }
      const res = await create('/api/reservations', {
        dateReservation: new Date().toISOString().slice(0, 19),
        codeClient: userCode,
        codeTickets: tickets,
      })
      const reservationId = res.data.idReservation
      setSuccess(`Réservation #${reservationId} créée ! ${tickets.length} ticket(s)`)
      setSelectedSeats([])
      if (onReservationComplete) onReservationComplete(reservationId, tickets)
      loadData()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const allRangs = Object.keys(seats).sort()

  return (
    <div className="seat-map-container">
      {event && (
        <div className="event-summary">
          <h3>{event.titre}</h3>
          <p>{event.dateEvenement} | {event.lieuNom} | {event.placesDisponibles}/{event.placesTotal} places disponibles</p>
        </div>
      )}

      <div className="seat-legend">
        <span><span className="legend-dot" style={{ background: STATUT_COLORS.DISPONIBLE }} /> Disponible</span>
        <span><span className="legend-dot" style={{ background: STATUT_COLORS.RESERVEE }} /> Réservée</span>
        <span><span className="legend-dot" style={{ background: STATUT_COLORS.INDISPONIBLE }} /> Indisponible</span>
        <span><span className="legend-dot" style={{ background: STATUT_COLORS.EN_ATTENTE }} /> En attente</span>
        <span><span className="legend-dot selected-dot" /> Sélectionnée</span>
      </div>

      {error && <p className="msg error">{error}</p>}
      {success && <p className="msg success">{success}</p>}

      <div className="seat-grid">
        {allRangs.length === 0 && !loading && <p className="empty">Aucune place disponible</p>}
        {allRangs.map(rang => (
          <div key={rang} className="seat-row">
            <div className="seat-row-label">{rang}</div>
            <div className="seat-row-seats">
              {seats[rang].map(seat => {
                const isSelected = selectedSeats.some(s => s.numeroPlace === seat.numeroPlace)
                let color
                if (isSelected) color = '#3b82f6'
                else if (!seat.disponible) color = seat.statut === 'EN_ATTENTE' ? STATUT_COLORS.EN_ATTENTE : STATUT_COLORS.RESERVEE
                else color = STATUT_COLORS.DISPONIBLE
                return (
                  <div
                    key={seat.numeroPlace}
                    className={`seat-tile ${isSelected ? 'selected' : ''} ${!seat.disponible ? 'taken' : ''}`}
                    style={{ background: color }}
                    onClick={() => toggleSeat(seat)}
                    title={`${seat.numeroPlace.split('-').pop()} - ${seat.typePlace || ''} ${seat.prix ? parseFloat(seat.prix).toFixed(2) + '€' : ''}`}
                  >
                    {seat.numeroPlace.split('-').pop().replace(/[A-Za-z]/g, '')}
                  </div>
                )
              })}
            </div>
          </div>
        ))}
      </div>

      {selectedSeats.length > 0 && (
        <div className="selection-summary">
          <p>
            {selectedSeats.length} place{selectedSeats.length > 1 ? 's' : ''} sélectionnée{selectedSeats.length > 1 ? 's' : ''}
            : <strong>{totalPrice()} €</strong>
          </p>
          <div className="selected-list">
            {selectedSeats.map(s => (
              <span key={s.numeroPlace} className="selected-badge">
                {s.numeroPlace.split('-').pop()} ({parseFloat(s.prix || 0).toFixed(2)}€)
                <button onClick={() => toggleSeat(s)}>&times;</button>
              </span>
            ))}
          </div>
          <button className="btn-primary" onClick={handleReserve} disabled={loading}>
            {loading ? 'Réservation...' : 'Confirmer la réservation'}
          </button>
        </div>
      )}
    </div>
  )
}
