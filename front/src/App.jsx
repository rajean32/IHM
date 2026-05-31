import { useState, useEffect } from 'react'
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom'
import { setAuthToken, setUserInfo, getAuthToken, getUserInfo } from './api/entityApi'

import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'
import FirstLoginPage from './pages/auth/FirstLoginPage'
import AdminLayout from './pages/admin/AdminLayout'
import AdminDashboard from './pages/admin/AdminDashboard'
import AdminDataTable from './pages/admin/AdminDataTable'
import UserManagement from './pages/admin/UserManagement'
import OrganizerLayout from './pages/organizer/OrganizerLayout'
import OrganizerDashboard from './pages/organizer/OrganizerDashboard'
import EventCreationWizard from './pages/organizer/EventCreationWizard'
import OrganizerVenueManagement from './pages/organizer/OrganizerVenueManagement'
import ClientLayout from './pages/client/ClientLayout'
import ClientHome from './pages/client/ClientHome'
import BookingFlow from './pages/client/BookingFlow'
import MyReservations from './pages/client/MyReservations'

function RequireAuth({ children, roles }) {
  const auth = getAuthToken()
  const user = getUserInfo()
  const location = useLocation()

  if (!auth) return <Navigate to="/login" state={{ from: location }} replace />
  if (roles && !roles.includes(user?.role)) return <Navigate to="/" replace />
  if (user?.isFirstLogin && location.pathname !== '/first-login') return <Navigate to="/first-login" replace />

  return children
}

function RoleHome() {
  const user = getUserInfo()
  if (!user) return <Navigate to="/login" replace />
  switch (user.role) {
    case 'ADMINISTRATEUR': return <Navigate to="/admin" replace />
    case 'ORGANISATEUR': return <Navigate to="/organizer" replace />
    default: return <Navigate to="/client" replace />
  }
}

export default function App() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    const token = getAuthToken()
    const user = getUserInfo()
    if (token && user) setReady(true)
    else setReady(true)
  }, [])

  if (!ready) return <div className="app-loading">Chargement...</div>

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
        <Route path="/first-login" element={<RequireAuth><FirstLoginPage /></RequireAuth>} />
        <Route path="/" element={<RequireAuth><RoleHome /></RequireAuth>} />

        <Route path="/admin" element={<RequireAuth roles={['ADMINISTRATEUR']}><AdminLayout /></RequireAuth>}>
          <Route index element={<AdminDashboard />} />
          <Route path="users" element={<UserManagement />} />
          <Route path="data/:entity" element={<AdminDataTable />} />
        </Route>

        <Route path="/organizer" element={<RequireAuth roles={['ORGANISATEUR']}><OrganizerLayout /></RequireAuth>}>
          <Route index element={<OrganizerDashboard />} />
          <Route path="create-event" element={<EventCreationWizard />} />
          <Route path="edit-event/:id" element={<EventCreationWizard />} />
          <Route path="venues" element={<OrganizerVenueManagement />} />
        </Route>

        <Route path="/client" element={<RequireAuth roles={['CLIENT']}><ClientLayout /></RequireAuth>}>
          <Route index element={<ClientHome />} />
          <Route path="book/:eventId" element={<BookingFlow />} />
          <Route path="my-reservations" element={<MyReservations />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

function PublicRoute({ children }) {
  const auth = getAuthToken()
  const user = getUserInfo()
  if (!auth || !user) return children
  if (user?.isFirstLogin) return <Navigate to="/first-login" replace />
  switch (user.role) {
    case 'ADMINISTRATEUR': return <Navigate to="/admin" replace />
    case 'ORGANISATEUR': return <Navigate to="/organizer" replace />
    default: return <Navigate to="/client" replace />
  }
}
