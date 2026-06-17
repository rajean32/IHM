import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getUserInfo } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function OrganizerLayout() {
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
    <div className="organizer-layout">
      <aside className="sidebar">
        <h2>{t('organizer.layout.title')}</h2>
        <nav>
          <Link to="/organizer" className={location.pathname === '/organizer' ? 'active' : ''}>{t('organizer.layout.dashboard')}</Link>
          <Link to="/organizer/create-event" className={location.pathname === '/organizer/create-event' ? 'active' : ''}>{t('organizer.layout.createEvent')}</Link>
          <Link to="/organizer/venues" className={location.pathname === '/organizer/venues' ? 'active' : ''}>{t('organizer.layout.manageVenues')}</Link>
          <Link to="/settings" className={location.pathname === '/settings' ? 'active' : ''}>{t('settings.title')}</Link>
        </nav>
      </aside>
      <div className="main-content">
        <header className="header">
          <div className="user-info">
            <span>{user?.nom || user?.codeUtilisateur || 'Organisateur'}</span>
            {user?.role && <span className="user-badge">{user.role}</span>}
          </div>
          <button className="btn-logout" onClick={handleLogout}>{t('organizer.layout.logout')}</button>
        </header>
        <main className="content">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
