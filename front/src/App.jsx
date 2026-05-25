import { useState } from 'react'
import { setAuthToken, setUserInfo } from './api/entityApi'

import LoginForm from './components/LoginForm'
import RegisterForm from './components/RegisterForm'
import EvenementForm from './components/EvenementForm'
import LieuSallePlaceForm from './components/LieuSallePlaceForm'
import TicketForm from './components/TicketForm'
import ReservationForm from './components/ReservationForm'
import PaiementForm from './components/PaiementForm'
import ConcernerForm from './components/ConcernerForm'

const ROLE_SECTIONS = {
  ADMINISTRATEUR: [
    { key: 'moderation', label: 'Modération Événements', comp: EvenementForm },
    { key: 'lieu-salle-place', label: 'Lieux / Salles / Places', comp: LieuSallePlaceForm },
  ],
  ORGANISATEUR: [
    { key: 'evenements', label: 'Mes Événements', comp: EvenementForm },
    { key: 'tickets', label: 'Tarification Tickets', comp: TicketForm },
    { key: 'concerner', label: 'Affectation Places & Tickets', comp: ConcernerForm },
  ],
  CLIENT: [
    { key: 'evenements', label: 'Catalogue Événements', comp: EvenementForm },
    { key: 'reservations', label: 'Mes Réservations', comp: ReservationForm },
    { key: 'paiements', label: 'Paiements', comp: PaiementForm },
  ],
}

export default function App() {
  const [auth, setAuth] = useState(null)
  const [section, setSection] = useState('login')

  function handleAuth(token, info) {
    setAuthToken(token)
    setUserInfo(info)
    const sections = ROLE_SECTIONS[info.role]
    setAuth({ token, user: info })
    setSection(sections?.[0]?.key || 'evenements')
  }

  function handleLogout() {
    setAuthToken(null)
    setUserInfo(null)
    setAuth(null)
    setSection('login')
  }

  if (!auth) {
    return (
      <div className="app">
        <header>
          <h1>IHM — Gestion Événements & Tickets</h1>
        </header>
        <main className="auth-page">
          <div className="auth-tabs">
            <button className={section === 'login' ? 'active' : ''} onClick={() => setSection('login')}>Connexion</button>
            <button className={section === 'register' ? 'active' : ''} onClick={() => setSection('register')}>Inscription</button>
          </div>
          {section === 'login' ? <LoginForm onAuth={handleAuth} /> : <RegisterForm onAuth={handleAuth} />}
        </main>
      </div>
    )
  }

  const user = auth.user
  const sections = ROLE_SECTIONS[user.role] || []
  const current = sections.find(s => s.key === section)
  if (!current && sections.length > 0) {
    setSection(sections[0].key)
  }
  const ActiveComp = current?.comp || sections[0]?.comp

  return (
    <div className="app">
      <header>
        <h1>IHM — Gestion Événements & Tickets</h1>
        <div className="user-info">
          <span className="user-badge">{user.role}</span>
          <span>{user.code || user.email}</span>
          <button className="btn-logout" onClick={handleLogout}>Déconnexion</button>
        </div>
      </header>

      <nav className="nav-bar">
        {sections.map(s => (
          <button
            key={s.key}
            className={`nav-btn ${(current?.key || sections[0]?.key) === s.key ? 'active' : ''}`}
            onClick={() => setSection(s.key)}
          >
            {s.label}
          </button>
        ))}
      </nav>

      <main>
        <ActiveComp userRole={user.role} userCode={user.code} />
      </main>
    </div>
  )
}
