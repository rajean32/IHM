import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function ClientLayout() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = getUserInfo()
  const { t } = useLanguage()

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    navigate('/login')
  }

  return (
    <div className="client-layout">
      <header className="header">
        <div className="user-info">
          <h1 style={{ fontSize: '1.1rem', margin: 0 }}>{t('client.layout.title')}</h1>
        </div>
        <div className="user-info">
          <span>{user?.nom} {user?.prenom}</span>
          <span className="user-badge">{t('client.layout.client')}</span>
          <Link to="/settings" className="btn-icon" style={{ textDecoration: 'none' }}>{t('settings.title')}</Link>
          <button className="btn-logout" onClick={handleLogout}>{t('client.layout.logout')}</button>
        </div>
      </header>

      <main className="main-content">
        <Outlet />
      </main>

      <nav className="bottom-nav">
        <Link to="/client" className={location.pathname === '/client' ? 'active' : ''}>
          {t('client.layout.home')}
        </Link>
        <Link to="/client/my-reservations" className={location.pathname === '/client/my-reservations' ? 'active' : ''}>
          {t('client.layout.myReservations')}
        </Link>
        <Link to="/settings" className={location.pathname === '/settings' ? 'active' : ''}>
          {t('settings.title')}
        </Link>
      </nav>
    </div>
  )
}
