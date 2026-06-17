import { useState, useEffect } from 'react'
import { getAll } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function AdminDashboard() {
  const { t } = useLanguage()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    getAll('/api/admin/dashboard')
      .then(res => { setData(res.data || res) })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="loading">{t('common.loading')}</div>
  if (error) return <div className="error-msg">{error}</div>
  if (!data) return <div className="empty">{t('admin.dashboard.noData')}</div>

  const currency = 'Ar'

  const stats = [
    { label: t('admin.dashboard.totalEvents'), value: data.totalEvents },
    { label: t('admin.dashboard.totalClients'), value: data.totalClients },
    { label: t('admin.dashboard.totalOrganisateurs'), value: data.totalOrganisateurs },
    { label: t('admin.dashboard.totalReservations'), value: data.totalReservations },
    { label: t('admin.dashboard.ticketsSold'), value: data.totalTicketsSold },
    { label: t('admin.dashboard.totalRevenue'), value: data.totalRevenue != null ? `${Number(data.totalRevenue).toFixed(2)} ${currency}` : 'N/A' },
    { label: t('admin.dashboard.totalVenues'), value: data.totalLieux },
    { label: t('admin.dashboard.totalRooms'), value: data.totalSalles },
  ]

  const recentEvents = data.recentEvents || []
  const eventsByStatus = data.eventsByStatus || {}

  return (
    <div className="dashboard">
      <h2>{t('admin.dashboard.title')}</h2>
      <div className="stat-grid">
        {stats.map(s => (
          <div key={s.label} className="stat-card">
            <span className="stat-label">{s.label}</span>
            <span className="stat-value">{s.value ?? '—'}</span>
          </div>
        ))}
      </div>

      {recentEvents.length > 0 && (
        <div className="section-container">
          <h3>{t('admin.dashboard.recentEvents')}</h3>
          <ul className="recent-list">
            {recentEvents.map((ev, i) => (
              <li key={ev.idEvenement ?? i}>
                {ev.titre} — {ev.dateEvenement ? new Date(ev.dateEvenement).toLocaleDateString() : ''}
              </li>
            ))}
          </ul>
        </div>
      )}

      {Object.keys(eventsByStatus).length > 0 && (
        <div className="section-container">
          <h3>{t('admin.dashboard.eventsByStatus')}</h3>
          <div className="stat-grid">
            {Object.entries(eventsByStatus).map(([status, count]) => (
              <div key={status} className="stat-card">
                <span className="stat-label">{status}</span>
                <span className="stat-value">{count}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
