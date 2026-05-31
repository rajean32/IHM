import { Outlet, Link, useNavigate } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'

export default function OrganizerLayout() {
  const navigate = useNavigate()
  const user = getUserInfo()

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    navigate('/login')
  }

  return (
    <div className="organizer-layout">
      <aside className="sidebar">
        <h2>Organisateur</h2>
        <nav>
          <Link to="/organizer">Dashboard</Link>
          <Link to="/organizer/create-event">Create Event</Link>
          <Link to="/organizer/venues">Manage Venues</Link>
        </nav>
      </aside>
      <div className="main-content">
        <header>
          <span>{user?.nom || user?.codeUtilisateur || 'Organisateur'}</span>
          <button onClick={handleLogout}>Déconnexion</button>
        </header>
        <main>
          <Outlet />
        </main>
      </div>
    </div>
  )
}
