import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { getAll, create, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function StandingBooking() {
  const { eventId } = useParams()
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [step, setStep] = useState(1)
  const [event, setEvent] = useState(null)
  const [zones, setZones] = useState([])
  const [selectedZones, setSelectedZones] = useState({})
  const [loading, setLoading] = useState(true)
  const [processing, setProcessing] = useState(false)
  const [error, setError] = useState('')
  const [modePaiement, setModePaiement] = useState('Carte Bancaire')
  const [reservationResult, setReservationResult] = useState(null)
  const [ticketQrCodes, setTicketQrCodes] = useState({})

  useEffect(() => {
    async function load() {
      setLoading(true)
      try {
        const [detailResp, zonesResp] = await Promise.all([
          getAll(`/api/evenements/${eventId}/detail`),
          getAll(`/api/evenements/${eventId}/zones`).catch(() => ({ data: [] })),
        ])
        const detail = detailResp?.data || detailResp
        setEvent(detail)

        const rawZones = zonesResp?.data || zonesResp || []
        setZones(rawZones.map(z => ({
          ...z,
          prix: z.prix || 0,
          nom: z.nom || 'Zone',
        })))
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [eventId])

  function updateQuantity(zoneId, delta) {
    setSelectedZones(prev => {
      const current = prev[zoneId] || 0
      const next = Math.max(0, current + delta)
      const zone = zones.find(z => z.idZone === zoneId)
      if (zone?.capacite && next > (zone.capacite - (zone.reservationsActuelles || 0)))
        return prev
      return { ...prev, [zoneId]: next }
    })
  }

  function getSelectedItems() {
    return zones.flatMap(z => {
      const qty = selectedZones[z.idZone] || 0
      return qty > 0 ? [{ type: 'standing', label: `${z.nom} x${qty}`, price: (z.prix || 0) * qty, zoneId: z.idZone, qty }] : []
    })
  }

  const totalPrice = getSelectedItems().reduce((sum, item) => sum + item.price, 0)
  const hasSelection = Object.values(selectedZones).some(v => v > 0)
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

      for (const zone of zones) {
        const qty = selectedZones[zone.idZone] || 0
        for (let i = 0; i < qty; i++) {
          const codeTicket = `TKT-${eventId}-${zone.nom.replace(/\s+/g, '')}-${now}-${i}`
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

  if (loading) return <div className="loading"><p>{t('client.booking.loading')}</p></div>
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
        <p style={{ color: 'var(--text-secondary)' }}>{event.lieuNom || event.lieu || ''}</p>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          {zones.reduce((s, z) => s + (z.placesDisponibles || z.capacite || 0), 0)} {t('client.booking.availablePlaces')} · {t('client.booking.price')}: {event.prixMin?.toFixed(0) ?? '?'} - {event.prixMax?.toFixed(0) ?? '?'} Ar
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

          <div className="standing-zones">
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {zones.length === 0 && !loading && (
                <p style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '2rem' }}>
                  {t('client.booking.noSeats')}
                </p>
              )}
              {zones.map(zone => {
                const qty = selectedZones[zone.idZone] || 0
                const isFull = zone.capacite && (zone.reservationsActuelles || 0) >= zone.capacite
                const remaining = zone.capacite ? zone.capacite - (zone.reservationsActuelles || 0) : null
                const pct = zone.capacite ? (((zone.reservationsActuelles || 0) / zone.capacite) * 100) : 0

                return (
                  <div key={zone.idZone} className="standing-zone-card">
                    <div className="standing-zone-header">
                      <div>
                        <strong>{zone.nom}</strong>
                        {zone.capacite ? (
                          <span className="standing-zone-capacity">
                            {(zone.reservationsActuelles || 0)}/{zone.capacite} réservée{(zone.reservationsActuelles || 0) > 1 ? 's' : ''}
                            {remaining !== null && remaining > 0 && ` · ${remaining} restante${remaining > 1 ? 's' : ''}`}
                          </span>
                        ) : (
                          <span className="standing-zone-capacity">{t('client.booking.standingNoLimit')}</span>
                        )}
                      </div>
                      <span className="standing-zone-price">{(zone.prix || 0).toFixed(2)} €</span>
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
                        <button onClick={() => updateQuantity(zone.idZone, -1)} disabled={qty === 0}>−</button>
                        <span>{qty}</span>
                        <button onClick={() => updateQuantity(zone.idZone, 1)}
                          disabled={remaining !== null && qty >= remaining}>+</button>
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </div>

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
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.venue')}:</strong> {event.lieuNom || event.lieu || ''}</p>
          </div>
          <h4 style={{ marginBottom: '0.5rem', color: 'var(--text)' }}>{t('client.booking.selectedItems')}</h4>
          <div style={{ display: 'grid', gap: '6px' }}>
            {zones.map(zone => {
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
            <p style={{ color: 'var(--text)' }}><strong>{t('client.booking.standingAreas')}:</strong> {zones.filter(z => (selectedZones[z.idZone] || 0) > 0).map(z => `${z.nom} x${selectedZones[z.idZone]}`).join(', ') || '—'}</p>
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
