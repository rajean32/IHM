import { Outlet, useNavigate, Link, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function AdminLayout() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = getUserInfo()
  const { t } = useLanguage()

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    navigate('/login')
  }

  const navLinks = [
    { to: '/admin', label: t('admin.layout.dashboard') },
    { to: '/admin/users', label: t('admin.layout.users') },
    { to: '/admin/data/evenements', label: t('admin.layout.events') },
    { to: '/admin/data/categories', label: t('admin.layout.categories') },
    { to: '/admin/data/lieux', label: t('admin.layout.venues') },
    { to: '/admin/data/salles', label: t('admin.layout.rooms') },
    { to: '/admin/data/places', label: t('admin.layout.places') },
    { to: '/admin/data/tickets', label: t('admin.layout.tickets') },
    { to: '/admin/data/reservations', label: t('admin.layout.reservations') },
    { to: '/admin/data/paiements', label: t('admin.layout.payments') },
  ]

  return (
    <div className="admin-layout">
      <aside className="sidebar">
        <h2>{t('admin.layout.title')}</h2>
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
          <Link
            to="/settings"
            className={location.pathname === '/settings' ? 'active' : ''}
          >
            {t('settings.title')}
          </Link>
        </nav>
      </aside>
      <div className="main-content">
        <header className="header">
          <div className="user-info">
            <span>{user?.nom || user?.codeUtilisateur || 'Admin'}</span>
            {user?.role && <span className="user-badge">{user.role}</span>}
          </div>
          <button className="btn-logout" onClick={handleLogout}>{t('admin.layout.logout')}</button>
        </header>
        <main className="content">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
