import { useState, useEffect } from 'react'
import { getAll, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function MyReservations() {
  const { t } = useLanguage()
  const [tab, setTab] = useState('reservations')
  const [reservations, setReservations] = useState([])
  const [tickets, setTickets] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [qrCodes, setQrCodes] = useState({})

  const user = getUserInfo()

  useEffect(() => {
    if (!user?.codeUtilisateur) return
    setLoading(true)
    setError('')

    Promise.all([
      getAll(`/api/reservations?client=${user.codeUtilisateur}`),
      getAll(`/api/clients/${user.codeUtilisateur}/tickets`),
    ])
      .then(([resData, ticketData]) => {
        setReservations(Array.isArray(resData) ? resData : resData.content || [])
        setTickets(Array.isArray(ticketData) ? ticketData : ticketData.content || [])
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [user?.codeUtilisateur])

  async function loadQrCode(codeTicket) {
    if (qrCodes[codeTicket]) return
    try {
      const data = await getAll(`/api/tickets/${codeTicket}/qrcode`)
      setQrCodes(prev => ({ ...prev, [codeTicket]: data }))
    } catch {
      setQrCodes(prev => ({ ...prev, [codeTicket]: null }))
    }
  }

  useEffect(() => {
    if (tab === 'tickets') {
      tickets.forEach(t => {
        const code = t.codeTicket || t.code
        if (code && !qrCodes[code]) loadQrCode(code)
      })
    }
  }, [tab, tickets])

  function formatDate(d) {
    if (!d) return ''
    return new Date(d).toLocaleDateString('fr-FR', {
      day: 'numeric', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit',
    })
  }

  if (loading) return <div className="loading">{t('client.reservations.loading')}</div>
  if (error) return <div className="error-msg">{error}</div>

  return (
    <div className="my-reservations">
      <h1>{t('client.reservations.title')}</h1>
      <div className="auth-tabs">
        <button className={tab === 'reservations' ? 'active' : ''} onClick={() => setTab('reservations')}>
          {t('client.reservations.tabReservations')}
        </button>
        <button className={tab === 'tickets' ? 'active' : ''} onClick={() => setTab('tickets')}>
          {t('client.reservations.tabTickets')}
        </button>
      </div>

      {tab === 'reservations' && (
        <div className="section-container">
          {reservations.length === 0 ? (
            <div className="empty">{t('client.reservations.noReservations')}</div>
          ) : (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>{t('client.reservations.reference')}</th>
                    <th>{t('client.reservations.date')}</th>
                    <th>{t('client.reservations.status')}</th>
                    <th>{t('client.reservations.amount')}</th>
                  </tr>
                </thead>
                <tbody>
                  {reservations.map(res => (
                    <tr key={res.idReservation || res.id || res.reference}>
                      <td>{res.reference || res.idReservation || res.id}</td>
                      <td>{formatDate(res.dateReservation)}</td>
                      <td><span className={`badge badge-${(res.statut || 'actif').toLowerCase()}`}>{res.statut || 'Actif'}</span></td>
                      <td>{res.montantTotal || res.montant || '-'} €</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {tab === 'tickets' && (
        <div className="section-container">
          <h2>{t('client.reservations.myTickets')}</h2>
          {tickets.length === 0 ? (
            <div className="empty">{t('client.reservations.noTickets')}</div>
          ) : (
            <div className="tickets-list">
              {tickets.map(ticket => {
                const code = ticket.codeTicket || ticket.code
                const qr = qrCodes[code]
                return (
                  <div key={code} className="ticket-card">
                    <div className="ticket-info">
                      <h4>#{code}</h4>
                      <p>{ticket.eventTitre || ticket.evenement?.titre || '-'}</p>
                      <p>{ticket.numeroPlace || ticket.place?.numeroPlace || '-'} · {ticket.prix || ticket.prixPlace || '-'} €</p>
                      <span className={`badge badge-${(ticket.statut || 'actif').toLowerCase()}`}>
                        {ticket.statut || 'Actif'}
                      </span>
                      {qr && qr.qrCodeBase64 && (
                        <img
                          src={`data:image/png;base64,${qr.qrCodeBase64}`}
                          alt={`QR ${code}`}
                          style={{ width: 80, height: 80, marginTop: 8 }}
                        />
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
