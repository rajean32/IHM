import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAll, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function OrganizerDashboard() {
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const user = getUserInfo()
    if (!user?.codeUtilisateur) {
      setError(t('organizer.dashboard.userNotFound'))
      setLoading(false)
      return
    }
    getAll(`/api/organisateurs/${user.codeUtilisateur}/dashboard`)
      .then(setData)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [t])

  if (loading) return <div className="loading">{t('common.loading')}</div>
  if (error) return <div className="error-msg">{error}</div>
  if (!data) return null

  const currency = 'Ar'

  const stats = [
    { label: t('organizer.dashboard.totalEvents'), value: data.totalEvents },
    { label: t('organizer.dashboard.ticketsSold'), value: data.totalTicketsSold },
    { label: t('organizer.dashboard.reservations'), value: data.totalReservations },
    { label: t('organizer.dashboard.totalRevenue'), value: `${data.totalRevenue ?? 0} ${currency}` },
    { label: t('organizer.dashboard.totalPlaces'), value: data.totalPlaces },
    { label: t('organizer.dashboard.availablePlaces'), value: data.placesDisponibles },
  ]

  return (
    <div className="dashboard">
      <h1>{t('organizer.dashboard.title')}</h1>
      <div className="stat-grid">
        {stats.map((s, i) => (
          <div key={i} className="stat-card">
            <div className="stat-label">{s.label}</div>
            <div className="stat-value">{s.value ?? t('organizer.dashboard.na')}</div>
          </div>
        ))}
      </div>
      <h2>{t('organizer.dashboard.myEvents')}</h2>
      {data.myEvents?.length > 0 ? (
        <ul className="recent-list">
          {data.myEvents.map(ev => (
            <li key={ev.id || ev.codeEvenement}>{ev.titre || ev.nom}</li>
          ))}
        </ul>
      ) : (
        <p className="empty">{t('organizer.dashboard.noEvents')}</p>
      )}
      <div style={{ marginTop: '1rem' }}>
        <button className="btn-primary" onClick={() => navigate('/organizer/create-event')}>
          {t('organizer.dashboard.createEvent')}
        </button>
      </div>
    </div>
  )
}
