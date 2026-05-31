import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAll, getUserInfo } from '../../api/entityApi'

export default function OrganizerDashboard() {
  const navigate = useNavigate()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const user = getUserInfo()
    if (!user?.codeUtilisateur) {
      setError('Utilisateur non trouvé')
      setLoading(false)
      return
    }
    getAll(`/api/organisateurs/${user.codeUtilisateur}/dashboard`)
      .then(setData)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div>Chargement...</div>
  if (error) return <div className="error">{error}</div>
  if (!data) return null

  const stats = [
    { label: 'Total Événements', value: data.totalEvents },
    { label: 'Billets Vendus', value: data.totalTicketsSold },
    { label: 'Réservations', value: data.totalReservations },
    { label: 'Revenu Total', value: `${data.totalRevenue ?? 0} Ar` },
    { label: 'Total Places', value: data.totalPlaces },
    { label: 'Places Disponibles', value: data.placesDisponibles },
  ]

  return (
    <div className="dashboard">
      <h1>Tableau de Bord</h1>
      <div className="stat-grid">
        {stats.map((s, i) => (
          <div key={i} className="stat-card">
            <h3>{s.label}</h3>
            <p>{s.value ?? 'N/A'}</p>
          </div>
        ))}
      </div>
      <h2>Mes Événements</h2>
      {data.myEvents?.length > 0 ? (
        <ul>
          {data.myEvents.map(ev => (
            <li key={ev.id || ev.codeEvenement}>{ev.titre || ev.nom}</li>
          ))}
        </ul>
      ) : (
        <p>Aucun événement pour le moment.</p>
      )}
      <button onClick={() => navigate('/organizer/create-event')}>
        Créer un Nouvel Événement
      </button>
    </div>
  )
}
