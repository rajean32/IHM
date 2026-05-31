import { useState, useEffect } from 'react'
import { getAll } from '../../api/entityApi'

export default function AdminDashboard() {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    getAll('/api/admin/dashboard')
      .then(res => { setData(res.data || res) })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="loading">Loading...</div>
  if (error) return <div className="msg error">{error}</div>
  if (!data) return <div className="empty">No data</div>

  const stats = [
    { label: 'Total Events', value: data.totalEvents },
    { label: 'Total Clients', value: data.totalClients },
    { label: 'Total Organisateurs', value: data.totalOrganisateurs },
    { label: 'Total Reservations', value: data.totalReservations },
    { label: 'Tickets Sold', value: data.totalTicketsSold },
    { label: 'Total Revenue', value: data.totalRevenue != null ? `${Number(data.totalRevenue).toFixed(2)}` : 'N/A' },
    { label: 'Total Venues', value: data.totalLieux },
    { label: 'Total Rooms', value: data.totalSalles },
  ]

  const recentEvents = data.recentEvents || []
  const eventsByStatus = data.eventsByStatus || {}

  return (
    <div className="dashboard">
      <h2>Dashboard</h2>
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
          <h3>Recent Events</h3>
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
          <h3>Events by Status</h3>
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
