import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'

export default function ClientLayout() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = getUserInfo()

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    navigate('/login')
  }

  return (
    <div className="client-layout">
      <header>
        <h1>🎫 IHM Tickets</h1>
        <div className="user-info">
          <span>{user?.nom} {user?.prenom}</span>
          <span className="user-badge">Client</span>
          <button className="btn-logout" onClick={handleLogout}>Déconnexion</button>
        </div>
      </header>

      <main className="main-content">
        <Outlet />
      </main>

      <nav className="bottom-nav">
        <Link to="/client" className={location.pathname === '/client' ? 'active' : ''}>
          Accueil
        </Link>
        <Link to="/client/my-reservations" className={location.pathname === '/client/my-reservations' ? 'active' : ''}>
          Mes Réservations
        </Link>
      </nav>
    </div>
  )
}
