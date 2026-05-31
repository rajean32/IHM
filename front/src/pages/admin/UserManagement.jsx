import { useState, useEffect, useCallback } from 'react'
import { getAll, create, update, remove } from '../../api/entityApi'

const PAGE_SIZE = 15

export default function UserManagement() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [modal, setModal] = useState(null)
  const [form, setForm] = useState({})
  const [editCode, setEditCode] = useState(null)

  const loadUsers = useCallback(() => {
    setLoading(true)
    getAll('/api/admin/users')
      .then(res => {
        const items = Array.isArray(res) ? res : (res.data || res.content || [])
        setUsers(items)
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  useEffect(() => { loadUsers() }, [loadUsers])

  const filtered = users.filter(u =>
    [u.codeUtilisateur, u.nom, u.prenoms, u.email, u.role]
      .some(v => v && String(v).toLowerCase().includes(search.toLowerCase()))
  )

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE) || 1
  const safePage = Math.min(page, totalPages)
  const paginated = filtered.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  function openCreate() {
    setForm({ codeUtilisateur: '', nom: '', prenoms: '', sexe: '', dateDeNaissance: '', email: '', tel: '', motDePasse: '', role: 'CLIENT' })
    setEditCode(null)
    setModal('create')
  }

  function openEdit(u) {
    setForm({ codeUtilisateur: u.codeUtilisateur, nom: u.nom, prenoms: u.prenoms, sexe: u.sexe || '', dateDeNaissance: u.dateDeNaissance || '', email: u.email, tel: u.tel || '', motDePasse: '', role: u.role })
    setEditCode(u.codeUtilisateur)
    setModal('edit')
  }

  async function handleSave(e) {
    e.preventDefault()
    try {
      if (modal === 'create') {
        await create('/api/admin/users', form)
      } else {
        const payload = { ...form }
        if (!payload.motDePasse) delete payload.motDePasse
        await update('/api/admin/users', editCode, payload)
      }
      setModal(null)
      loadUsers()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleDelete(code) {
    if (!window.confirm(`Delete user ${code}?`)) return
    try {
      await remove('/api/admin/users', code)
      loadUsers()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleChangeRole(code, role) {
    try {
      await update('/api/admin/users', `${code}/role`, { role })
      loadUsers()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleToggleActive(code) {
    try {
      await update('/api/admin/users', `${code}/toggle-active`, {})
      loadUsers()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleResetPassword(code) {
    const newPassword = prompt('Enter new password:')
    if (!newPassword || !newPassword.trim()) return
    try {
      await create('/api/admin/users/reset-password', { codeUtilisateur: code, newPassword })
      alert('Password reset successfully')
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="user-mgmt">
      <div className="section-header">
        <h2>User Management</h2>
        <button className="btn-primary" onClick={openCreate}>Add User</button>
      </div>

      {error && <p className="msg error">{error}</p>}

      <input
        className="search-bar"
        type="text"
        placeholder="Search users..."
        value={search}
        onChange={e => { setSearch(e.target.value); setPage(1) }}
      />

      {loading ? (
        <div className="loading">Loading...</div>
      ) : (
        <>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Code</th>
                  <th>Nom</th>
                  <th>Prénoms</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Active</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {paginated.map((u, i) => (
                  <tr key={u.codeUtilisateur || i}>
                    <td>{u.codeUtilisateur}</td>
                    <td>{u.nom}</td>
                    <td>{u.prenoms}</td>
                    <td>{u.email}</td>
                    <td>{u.role}</td>
                    <td>{u.active != null ? (u.active ? 'Yes' : 'No') : (u.enabled != null ? (u.enabled ? 'Yes' : 'No') : '—')}</td>
                    <td>
                      <button className="btn-icon" onClick={() => openEdit(u)}>Edit</button>
                      <select
                        className="mod-select"
                        value=""
                        onChange={e => { if (e.target.value) handleChangeRole(u.codeUtilisateur, e.target.value) }}
                      >
                        <option value="">Change Role</option>
                        <option value="CLIENT">CLIENT</option>
                        <option value="ORGANISATEUR">ORGANISATEUR</option>
                        <option value="ADMINISTRATEUR">ADMINISTRATEUR</option>
                      </select>
                      <button className="btn-icon" onClick={() => handleToggleActive(u.codeUtilisateur)}>
                        Toggle Active
                      </button>
                      <button className="btn-icon" onClick={() => handleResetPassword(u.codeUtilisateur)}>
                        Reset Pwd
                      </button>
                      <button className="btn-icon danger" onClick={() => handleDelete(u.codeUtilisateur)}>Delete</button>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={7} className="empty">No users found</td></tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button disabled={safePage <= 1} onClick={() => setPage(safePage - 1)}>Prev</button>
            <span>Page {safePage} of {totalPages}</span>
            <button disabled={safePage >= totalPages} onClick={() => setPage(safePage + 1)}>Next</button>
          </div>
        </>
      )}

      {modal && (
        <div className="modal-overlay" onClick={() => setModal(null)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3>{modal === 'create' ? 'Create' : 'Edit'} User</h3>
            <form onSubmit={handleSave}>
              <label>
                Code
                <input type="text" value={form.codeUtilisateur || ''} onChange={e => setForm({ ...form, codeUtilisateur: e.target.value })} required />
              </label>
              <label>
                Nom
                <input type="text" value={form.nom || ''} onChange={e => setForm({ ...form, nom: e.target.value })} required />
              </label>
              <label>
                Prénoms
                <input type="text" value={form.prenoms || ''} onChange={e => setForm({ ...form, prenoms: e.target.value })} required />
              </label>
              <label>
                Sexe
                <select value={form.sexe || ''} onChange={e => setForm({ ...form, sexe: e.target.value })}>
                  <option value="">—</option>
                  <option value="M">M</option>
                  <option value="F">F</option>
                </select>
              </label>
              <label>
                Date de Naissance
                <input type="date" value={form.dateDeNaissance || ''} onChange={e => setForm({ ...form, dateDeNaissance: e.target.value })} />
              </label>
              <label>
                Email
                <input type="email" value={form.email || ''} onChange={e => setForm({ ...form, email: e.target.value })} required />
              </label>
              <label>
                Téléphone
                <input type="text" value={form.tel || ''} onChange={e => setForm({ ...form, tel: e.target.value })} />
              </label>
              {modal === 'create' && (
                <label>
                  Mot de passe
                  <input type="password" value={form.motDePasse || ''} onChange={e => setForm({ ...form, motDePasse: e.target.value })} required />
                </label>
              )}
              {modal === 'edit' && (
                <label>
                  Mot de passe (leave empty to keep)
                  <input type="password" value={form.motDePasse || ''} onChange={e => setForm({ ...form, motDePasse: e.target.value })} />
                </label>
              )}
              <label>
                Rôle
                <select value={form.role || 'CLIENT'} onChange={e => setForm({ ...form, role: e.target.value })}>
                  <option value="CLIENT">CLIENT</option>
                  <option value="ORGANISATEUR">ORGANISATEUR</option>
                  <option value="ADMINISTRATEUR">ADMINISTRATEUR</option>
                </select>
              </label>
              <div className="form-actions">
                <button type="submit" className="btn-primary">Save</button>
                <button type="button" className="btn-secondary" onClick={() => setModal(null)}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
