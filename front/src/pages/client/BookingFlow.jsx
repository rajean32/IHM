import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { getAll, create, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

const TYPE_COLORS = {
  VIP: '#9b59b6',
  Premium: '#e67e22',
  Standard: '#3498db',
  'Première classe': '#2ecc71',
  Or: '#f1c40f',
  Argent: '#95a5a6',
}

const TYPE_AGENCEMENT_LABELS = {
  UNIQUEMENT_ASSIS: 'Uniquement assis',
  TABLE_ASSIS: 'Tables + chaises',
  ASSIS_DEBOUT: 'Assis/Debout mixte',
  DEBOUT_AVEC_LIMITE: 'Debout avec jauge',
  DEBOUT_SANS_LIMITE: 'Debout sans limite',
}

export default function BookingFlow() {
  const { eventId } = useParams()
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [step, setStep] = useState(1)
  const [event, setEvent] = useState(null)
  const [seats, setSeats] = useState([])
  const [selectedSeats, setSelectedSeats] = useState([])
  const [standingZones, setStandingZones] = useState([])
  const [selectedZones, setSelectedZones] = useState({})
  const [loading, setLoading] = useState(true)
  const [processing, setProcessing] = useState(false)
  const [error, setError] = useState('')
  const [modePaiement, setModePaiement] = useState('Carte Bancaire')
  const [reservationResult, setReservationResult] = useState(null)
  const [ticketQrCodes, setTicketQrCodes] = useState({})
  const [typeFilter, setTypeFilter] = useState('all')

  useEffect(() => {
    async function load() {
      setLoading(true)
      try {
        const [detailResp, availableResp, zonesResp] = await Promise.all([
          getAll(`/api/evenements/${eventId}/detail`),
          getAll(`/api/evenements/${eventId}/places/available`),
          getAll(`/api/evenements/${eventId}/zones`).catch(() => ({ data: [] })),
        ])
        const detail = detailResp?.data || detailResp
        setEvent(detail)

        const seatsList = Array.isArray(availableResp) ? availableResp
          : availableResp?.data || availableResp?.places || []
        setSeats(seatsList.map(s => ({
          ...s,
          typePlace: s.typePlace || 'Standard',
          statut: s.statut || (s.disponible ? 'DISPONIBLE' : 'RESERVEE'),
        })))

        const zones = zonesResp?.data || zonesResp || []
        setStandingZones(zones)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [eventId])

  const agencement = event?.typeAgencement
  const isStandingOnly = agencement === 'DEBOUT_AVEC_LIMITE' || agencement === 'DEBOUT_SANS_LIMITE'
  const isMixed = agencement === 'ASSIS_DEBOUT'

  function toggleSeat(seat) {
    if (seat.statut !== 'DISPONIBLE' && !selectedSeats.find(s => s.numeroPlace === seat.numeroPlace)) return
    setSelectedSeats(prev => {
      const exists = prev.find(s => s.numeroPlace === seat.numeroPlace)
      if (exists) return prev.filter(s => s.numeroPlace !== seat.numeroPlace)
      return [...prev, seat]
    })
  }

  function updateZoneQuantity(zoneId, delta) {
    setSelectedZones(prev => {
      const current = prev[zoneId] || 0
      const next = Math.max(0, current + delta)
      const zone = standingZones.find(z => z.idZone === zoneId)
      if (zone?.capacite && next > (zone.capacite - zone.reservationsActuelles)) return prev
      return { ...prev, [zoneId]: next }
    })
  }

  function getSelectedItems() {
    const items = []
    for (const s of selectedSeats) {
      items.push({ type: 'seat', label: s.numeroPlace, price: s.prix || 0 })
    }
    for (const z of standingZones) {
      const qty = selectedZones[z.idZone] || 0
      if (qty > 0) {
        items.push({ type: 'standing', label: `${z.nom} x${qty}`, price: (z.prix || 0) * qty, zoneId: z.idZone, qty })
      }
    }
    return items
  }

  const totalPrice = getSelectedItems().reduce((sum, item) => sum + item.price, 0)
  const hasSelection = selectedSeats.length > 0 || Object.values(selectedZones).some(v => v > 0)

  function groupByRow(seatsList) {
    const map = {}
    for (const s of seatsList) {
      const row = s.rang || s.range || '0'
      if (!map[row]) map[row] = []
      map[row].push(s)
    }
    return Object.entries(map).sort(([a], [b]) => {
      const na = parseInt(a), nb = parseInt(b)
      if (!isNaN(na) && !isNaN(nb)) return na - nb
      return a.localeCompare(b)
    })
  }

  function getSeatStyle(seat) {
    const isSelected = selectedSeats.find(s => s.numeroPlace === seat.numeroPlace)
    if (isSelected) return { background: 'var(--seat-selected)', borderColor: 'var(--seat-selected-border)', color: 'var(--seat-selected-text)', cursor: 'pointer' }
    switch (seat.statut) {
      case 'DISPONIBLE':
        return { background: 'var(--seat-available)', borderColor: 'var(--seat-available-border)', color: 'var(--seat-available-text)', cursor: 'pointer' }
      case 'RESERVEE':
        return { background: 'var(--seat-reserved)', borderColor: 'var(--seat-reserved-border)', color: 'var(--seat-reserved-text)', cursor: 'not-allowed' }
      case 'INDISPONIBLE':
        return { background: 'var(--seat-unavailable)', borderColor: 'var(--seat-unavailable-border)', color: 'var(--seat-unavailable-text)', cursor: 'not-allowed' }
      case 'EN_ATTENTE':
        return { background: 'var(--seat-pending)', borderColor: 'var(--seat-pending-border)', color: 'var(--seat-pending-text)', cursor: 'not-allowed' }
      default:
        return { background: 'var(--seat-unavailable)', borderColor: 'var(--seat-unavailable-border)', color: 'var(--seat-unavailable-text)', cursor: 'not-allowed' }
    }
  }

  function getTypeIndicator(type) {
    return TYPE_COLORS[type] || '#3498db'
  }

  const seatTypes = [...new Set(seats.map(s => s.typePlace))]
  const filteredSeats = typeFilter === 'all' ? seats : seats.filter(s => s.typePlace === typeFilter)
  const rows = groupByRow(filteredSeats)
  const user = getUserInfo()

  async function handleConfirm() {
    setStep(2)
  }

  async function handlePayment() {
    setProcessing(true)
    setError('')
    try {
      const ticketCodes = []
      const now = Date.now()

      for (const seat of selectedSeats) {
        const codeTicket = `TKT-${eventId}-${seat.numeroPlace}-${now}`
        const ticketResp = await create('/api/tickets', {
          codeTicket,
          prix: seat.prix,
          numeroPlace: seat.numeroPlace,
          idEvenement: Number(eventId),
        })
        const ticketData = ticketResp?.data || ticketResp
        ticketCodes.push(ticketData.codeTicket || codeTicket)
        const qrResp = await getAll(`/api/tickets/${ticketData.codeTicket || codeTicket}/qrcode`)
        const qrData = qrResp?.data || qrResp
        setTicketQrCodes(prev => ({ ...prev, [ticketData.codeTicket || codeTicket]: qrData }))
      }

      for (const zone of standingZones) {
        const qty = selectedZones[zone.idZone] || 0
        for (let i = 0; i < qty; i++) {
          const codeTicket = `TKT-${eventId}-${zone.nom}-${now}-${i}`
          const ticketResp = await create('/api/tickets', {
            codeTicket,
            prix: zone.prix || 0,
            idZone: zone.idZone,
            idEvenement: Number(eventId),
          })
          const ticketData = ticketResp?.data || ticketResp
          ticketCodes.push(ticketData.codeTicket || codeTicket)
          const qrResp = await getAll(`/api/tickets/${ticketData.codeTicket || codeTicket}/qrcode`)
          const qrData = qrResp?.data || qrResp
          setTicketQrCodes(prev => ({ ...prev, [ticketData.codeTicket || codeTicket]: qrData }))
        }
      }

      const reservationResp = await create('/api/reservations', {
        dateReservation: new Date().toISOString(),
        codeClient: user?.codeUtilisateur,
        codeTickets: ticketCodes,
      })
      const reservation = reservationResp?.data || reservationResp

      await create('/api/paiements', {
        montant: totalPrice,
        datePaiement: new Date().toISOString(),
        modePaiement,
        idReservation: reservation.idReservation || reservation.id,
      })

      setReservationResult({ ...reservation, ticketCodes, total: totalPrice, modePaiement })
      setStep(4)
    } catch (err) {
      setError(err.message)
    } finally {
      setProcessing(false)
    }
  }

  function handleFinish() {
    navigate('/client/my-reservations')
  }

  if (loading) return <div className="error-state"><p>{t('client.booking.loading')}</p></div>
  if (error) return <div className="error-msg">{error}</div>
  if (!event) return <div className="error-state"><p>{t('client.booking.eventNotFound')}</p></div>

  return (
    <div className="booking-flow">
      <div style={{ marginBottom: '1rem' }}>
        <h2>{event.titre}</h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {event.dateEvenement ? new Date(event.dateEvenement).toLocaleDateString('fr-FR') : ''}
          {event.heureEvenement ? ` à ${event.heureEvenement}` : ''}
        </p>
        <p style={{ color: 'var(--text-secondary)' }}>{event.lieuNom || event.lieu || event.venue || ''}</p>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          {event.placesDisponibles ?? '?'} {t('client.booking.availablePlaces')} · {t('client.booking.price')}: {event.prixMin ?? '?'} - {event.prixMax ?? '?'} €
          {agencement && <span style={{ marginLeft: '8px', padding: '2px 8px', borderRadius: '8px', background: 'var(--primary-light)', color: 'var(--primary)', fontSize: '0.8rem' }}>{TYPE_AGENCEMENT_LABELS[agencement] || agencement}</span>}
        </p>
      </div>

      <div className="wizard-steps" style={{ marginBottom: '1.5rem' }}>
        {[
          t('client.booking.stepSelect'),
          t('client.booking.stepConfirm'),
          t('client.booking.stepPayment'),
          t('client.booking.stepSuccess')
        ].map((label, i) => (
          <span key={i} className={`wizard-step ${step === i + 1 ? 'active' : ''} ${step > i + 1 ? 'completed' : ''}`}>
            <span className="step-num">{i + 1}</span>
            {label}
          </span>
        ))}
      </div>

      {step === 1 && (
        <>
          <button className="btn-secondary" onClick={() => navigate('/client')} style={{ marginBottom: '1rem' }}>
            {t('client.booking.back')}
          </button>
          {!isStandingOnly && (
            <>
              <div className="seat-legend">
                <span className="seat-legend-item">
                  <span className="seat-legend-color" style={{ background: 'var(--seat-available)', border: '2px solid var(--seat-available-border)' }}></span>
                  {t('client.booking.legendAvailable')}
                </span>
                <span className="seat-legend-item">
                  <span className="seat-legend-color" style={{ background: 'var(--seat-reserved)', border: '2px solid var(--seat-reserved-border)' }}></span>
                  {t('client.booking.legendReserved')}
                </span>
                <span className="seat-legend-item">
                  <span className="seat-legend-color" style={{ background: 'var(--seat-unavailable)', border: '2px solid var(--seat-unavailable-border)' }}></span>
                  {t('client.booking.legendUnavailable')}
                </span>
                <span className="seat-legend-item">
                  <span className="seat-legend-color" style={{ background: 'var(--seat-selected)', border: '2px solid var(--seat-selected-border)' }}></span>
                  {t('client.booking.legendSelected')}
                </span>
              </div>

              <div className="filter-chips" style={{ marginBottom: '1rem' }}>
                <button className={typeFilter === 'all' ? 'active' : ''} onClick={() => setTypeFilter('all')}>
                  {t('client.booking.seatAll')}
                </button>
                {seatTypes.map(type => (
                  <button key={type} className={typeFilter === type ? 'active' : ''} onClick={() => setTypeFilter(type)}
                    style={typeFilter === type ? { background: getTypeIndicator(type), borderColor: getTypeIndicator(type), color: '#fff' } : {}}>
                    <span style={{
                      display: 'inline-block', width: '8px', height: '8px', borderRadius: '50%',
                      background: getTypeIndicator(type), marginRight: '4px',
                    }}></span>
                    {type}
                  </button>
                ))}
              </div>

              <div className="seat-map">
                {rows.length === 0 ? (
                  <p style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '2rem' }}>{t('client.booking.noSeats')}</p>
                ) : (
                  rows.map(([row, rowSeats]) => (
                    <div key={row} className="seat-row">
                      <span className="seat-row-label">{row}</span>
                      <div style={{ display: 'flex', gap: '3px', flexWrap: 'wrap' }}>
                        {rowSeats.map(seat => (
                          <div key={seat.numeroPlace}
                            className="seat-tile"
                            style={{
                              ...getSeatStyle(seat),
                              borderLeft: `3px solid ${getTypeIndicator(seat.typePlace)}`,
                            }}
                            onClick={() => toggleSeat(seat)}
                            title={`${seat.numeroPlace} · ${seat.typePlace} · ${seat.prix ? seat.prix.toFixed(2) + ' €' : ''} · ${seat.statut}`}>
                            {seat.numeroPlace}
                          </div>
                        ))}
                      </div>
                    </div>
                  ))
                )}
              </div>

              <div style={{ marginTop: '1rem', display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                {seatTypes.map(type => (
                  <span key={type} style={{
                    display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: '0.8rem',
                    padding: '4px 10px', borderRadius: '12px',
                    background: `${getTypeIndicator(type)}18`,
                    border: `1px solid ${getTypeIndicator(type)}`,
                    color: getTypeIndicator(type),
                  }}>
                    <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: getTypeIndicator(type) }}></span>
                    {type} · {selectedSeats.filter(s => s.typePlace === type).length} {t('client.booking.seatsSelected')}
                  </span>
                ))}
              </div>
            </>
          )}

          {standingZones.length > 0 && (
            <div className="standing-zones" style={{ marginTop: isStandingOnly ? 0 : '1.5rem' }}>
              {!isStandingOnly && <h4 style={{ marginBottom: '0.75rem', color: 'var(--text)' }}>{t('client.booking.standingZones')}</h4>}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {standingZones.map(zone => {
                  const qty = selectedZones[zone.idZone] || 0
                  const isFull = zone.capacite && zone.reservationsActuelles >= zone.capacite
                  const remaining = zone.capacite ? zone.capacite - zone.reservationsActuelles : null
                  const pct = zone.capacite ? ((zone.reservationsActuelles / zone.capacite) * 100) : 0

                  return (
                    <div key={zone.idZone} className="standing-zone-card">
                      <div className="standing-zone-header">
                        <div>
                          <strong>{zone.nom}</strong>
                          {zone.capacite ? (
                            <span className="standing-zone-capacity">
                              {zone.reservationsActuelles}/{zone.capacite} réservée{zone.reservationsActuelles > 1 ? 's' : ''}
                              {remaining !== null && remaining > 0 && ` · ${remaining} restante${remaining > 1 ? 's' : ''}`}
                            </span>
                          ) : (
                            <span className="standing-zone-capacity">{t('client.booking.standingNoLimit')}</span>
                          )}
                        </div>
                        <span className="standing-zone-price">{zone.prix?.toFixed(2)} €</span>
                      </div>
                      {zone.capacite && (
                        <div className="capacity-bar">
                          <div className="capacity-fill" style={{ width: `${Math.min(pct, 100)}%` }}></div>
                        </div>
                      )}
                      {isFull ? (
                        <p style={{ color: 'var(--error)', fontSize: '0.85rem' }}>{t('client.booking.standingFull')}</p>
                      ) : (
                        <div className="quantity-selector">
                          <button onClick={() => updateZoneQuantity(zone.idZone, -1)} disabled={qty === 0}>−</button>
                          <span>{qty}</span>
                          <button onClick={() => updateZoneQuantity(zone.idZone, 1)}
                            disabled={remaining !== null && qty >= remaining}>+</button>
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>
            </div>
          )}

          <div className="summary-bar">
            <div>
              <span><strong>{getSelectedItems().length}</strong> {t('client.booking.selectionCount')}</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <span className="total">{totalPrice.toFixed(2)} €</span>
              <button className="btn-primary" disabled={!hasSelection} onClick={handleConfirm}>
                {t('client.booking.confirmSelection')}
              </button>
            </div>
          </div>
        </>
      )}

      {step === 2 && (
        <div style={{ background: 'var(--surface)', borderRadius: '12px', padding: '24px', boxShadow: '0 1px 4px rgba(0,0,0,0.06)' }}>
          <h3 style={{ marginBottom: '1rem', color: 'var(--text)' }}>{t('client.booking.confirmTitle')}</h3>
          <div style={{ display: 'grid', gap: '8px', marginBottom: '1rem' }}>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.event')}:</strong> {event.titre}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.date')}:</strong> {event.dateEvenement ? new Date(event.dateEvenement).toLocaleDateString('fr-FR') : ''} {event.heureEvenement || ''}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.venue')}:</strong> {event.lieuNom || event.lieu || event.venue || ''}</p>
          </div>
          <h4 style={{ marginBottom: '0.5rem', color: 'var(--text)' }}>{t('client.booking.selectedItems')}</h4>
          <div style={{ display: 'grid', gap: '6px' }}>
            {selectedSeats.map(seat => (
              <div key={seat.numeroPlace} style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                padding: '8px 12px', border: '1px solid var(--border)', borderRadius: '6px',
                color: 'var(--text)',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ width: '10px', height: '10px', borderRadius: '50%', background: getTypeIndicator(seat.typePlace) }}></span>
                  <strong>{seat.numeroPlace}</strong>
                  <span style={{ color: 'var(--text-secondary)' }}>{t('client.booking.seatRow')} {seat.rang || seat.range}</span>
                  <span style={{ fontSize: '0.8rem', padding: '1px 8px', borderRadius: '8px', background: `${getTypeIndicator(seat.typePlace)}22`, color: getTypeIndicator(seat.typePlace) }}>{seat.typePlace}</span>
                </div>
                <span>{seat.prix?.toFixed(2)} €</span>
              </div>
            ))}
            {standingZones.map(zone => {
              const qty = selectedZones[zone.idZone] || 0
              if (qty === 0) return null
              return (
                <div key={`zone-${zone.idZone}`} style={{
                  display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                  padding: '8px 12px', border: '1px solid var(--border)', borderRadius: '6px',
                  color: 'var(--text)',
                }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#f39c12' }}></span>
                    <strong>{zone.nom}</strong>
                    <span style={{ color: 'var(--text-secondary)' }}>x{qty}</span>
                  </div>
                  <span>{(zone.prix * qty).toFixed(2)} €</span>
                </div>
              )
            })}
          </div>
          <p style={{ marginTop: '1rem', fontSize: '1.1rem', fontWeight: 700, textAlign: 'right', color: 'var(--text)' }}>
            {t('client.booking.total')}: {totalPrice.toFixed(2)} €
          </p>
          <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '1rem' }}>
            <button className="btn-secondary" onClick={() => setStep(1)}>{t('client.booking.backBtn')}</button>
            <button className="btn-primary" onClick={() => setStep(3)}>{t('client.booking.proceedPayment')}</button>
          </div>
        </div>
      )}

      {step === 3 && (
        <div style={{ background: 'var(--surface)', borderRadius: '12px', padding: '24px', boxShadow: '0 1px 4px rgba(0,0,0,0.06)' }}>
          <h3 style={{ marginBottom: '1rem', color: 'var(--text)' }}>{t('client.booking.paymentTitle')}</h3>
          <p style={{ fontSize: '1.2rem', marginBottom: '1rem', color: 'var(--text)' }}>
            {t('client.booking.totalToPay')}: <strong>{totalPrice.toFixed(2)} €</strong>
          </p>
          <div style={{ marginBottom: '1rem' }}>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: 500, color: 'var(--text-secondary)' }}>
              {t('client.booking.paymentMethod')}
            </label>
            <select value={modePaiement} onChange={e => setModePaiement(e.target.value)}
              style={{ width: '100%', padding: '10px 14px', border: '1px solid var(--border)', borderRadius: '8px', fontSize: '0.95rem', background: 'var(--surface)', color: 'var(--text)' }}>
              <option value="Carte Bancaire">{t('client.booking.card')}</option>
              <option value="Mobile Money">{t('client.booking.mobileMoney')}</option>
              <option value="PayPal">{t('client.booking.paypal')}</option>
            </select>
          </div>
          {error && <div className="error-msg">{error}</div>}
          <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '1rem' }}>
            <button className="btn-secondary" onClick={() => setStep(2)}>{t('client.booking.backBtn')}</button>
            <button className="btn-primary" onClick={handlePayment} disabled={processing}>
              {processing ? t('client.booking.processing') : `${t('client.booking.pay')} ${totalPrice.toFixed(2)} €`}
            </button>
          </div>
        </div>
      )}

      {step === 4 && reservationResult && (
        <div style={{ background: 'var(--surface)', borderRadius: '12px', padding: '24px', boxShadow: '0 1px 4px rgba(0,0,0,0.06)' }}>
          <div className="success-msg">
            <strong>{t('client.booking.successTitle')}</strong> {t('client.booking.successMessage')}
          </div>
          <h3 style={{ marginTop: '1rem', marginBottom: '0.5rem', color: 'var(--text)' }}>{t('client.booking.details')}</h3>
          <div style={{ display: 'grid', gap: '6px' }}>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.event')}:</strong> {event.titre}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.date')}:</strong> {event.dateEvenement ? new Date(event.dateEvenement).toLocaleDateString('fr-FR') : ''}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.seats')}:</strong> {selectedSeats.map(s => s.numeroPlace).join(', ') || '—'}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.standingAreas')}:</strong> {standingZones.filter(z => (selectedZones[z.idZone] || 0) > 0).map(z => `${z.nom} x${selectedZones[z.idZone]}`).join(', ') || '—'}</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.totalPaid')}:</strong> {totalPrice.toFixed(2)} €</p>
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.mode')}:</strong> {modePaiement}</p>
          </div>
          <h4 style={{ marginTop: '1rem', marginBottom: '0.5rem', color: 'var(--text)' }}>{t('client.booking.tickets')}</h4>
          <div className="tickets-list">
            {reservationResult.ticketCodes.map(code => (
              <div key={code} className="ticket-card">
                <div className="ticket-info">
                  <h4 style={{ fontSize: '0.9rem' }}>{code}</h4>
                  {ticketQrCodes[code]?.qrCodeBase64 && (
                    <img src={`data:image/png;base64,${ticketQrCodes[code].qrCodeBase64}`}
                      alt={`QR ${code}`} style={{ width: 100, height: 100 }} />
                  )}
                </div>
              </div>
            ))}
          </div>
          <div style={{ marginTop: '1rem', display: 'flex', justifyContent: 'flex-end' }}>
            <button className="btn-primary" onClick={handleFinish}>
              {t('client.booking.viewReservations')}
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
