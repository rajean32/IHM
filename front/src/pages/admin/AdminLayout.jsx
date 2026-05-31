import { Outlet, useNavigate, Link, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'

export default function AdminLayout() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = getUserInfo()

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    navigate('/login')
  }

  const navLinks = [
    { to: '/admin', label: 'Dashboard' },
    { to: '/admin/users', label: 'Users' },
    { to: '/admin/data/evenements', label: 'Events' },
    { to: '/admin/data/categories', label: 'Categories' },
    { to: '/admin/data/lieux', label: 'Venues' },
    { to: '/admin/data/salles', label: 'Rooms' },
    { to: '/admin/data/places', label: 'Places' },
    { to: '/admin/data/tickets', label: 'Tickets' },
    { to: '/admin/data/reservations', label: 'Reservations' },
    { to: '/admin/data/paiements', label: 'Payments' },
  ]

  return (
    <div className="admin-layout">
      <aside className="sidebar">
        <h2>Admin Panel</h2>
        <nav>
          {navLinks.map(link => (
            <Link
              key={link.to}
              to={link.to}
              className={location.pathname === link.to ? 'active' : ''}
            >
              {link.label}
            </Link>
          ))}
        </nav>
      </aside>
      <div className="main-content">
        <header className="header">
          <div className="user-info">
            <span>{user?.nom || user?.codeUtilisateur || 'Admin'}</span>
            {user?.role && <span className="user-badge">{user.role}</span>}
          </div>
          <button className="btn-logout" onClick={handleLogout}>Logout</button>
        </header>
        <main>
          <Outlet />
        </main>
      </div>
    </div>
  )
}
