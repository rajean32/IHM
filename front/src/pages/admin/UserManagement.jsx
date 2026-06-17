import { useState, useEffect, useCallback } from 'react'
import { getAll, create, update, remove } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

const PAGE_SIZE = 15

export default function UserManagement() {
  const { t } = useLanguage()
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
    if (!window.confirm(`${t('admin.users.deleteConfirm')} ${code}?`)) return
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
    const newPassword = prompt(t('admin.users.resetPwdPrompt'))
    if (!newPassword || !newPassword.trim()) return
    try {
      await create('/api/admin/users/reset-password', { codeUtilisateur: code, newPassword })
      alert(t('admin.users.resetPwdSuccess'))
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="user-mgmt">
      <div className="section-header">
        <h2>{t('admin.users.title')}</h2>
        <button className="btn-primary" onClick={openCreate}>{t('admin.users.addUser')}</button>
      </div>

      {error && <p className="error-msg">{error}</p>}

      <input
        className="search-bar"
        type="text"
        placeholder={t('admin.users.search')}
        value={search}
        onChange={e => { setSearch(e.target.value); setPage(1) }}
      />

      {loading ? (
        <div className="loading">{t('common.loading')}</div>
      ) : (
        <>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>{t('admin.users.code')}</th>
                  <th>{t('admin.users.lastName')}</th>
                  <th>{t('admin.users.firstName')}</th>
                  <th>{t('admin.users.email')}</th>
                  <th>{t('admin.users.role')}</th>
                  <th>{t('admin.users.active')}</th>
                  <th>{t('admin.users.actions')}</th>
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
                    <td>{u.active != null ? (u.active ? t('admin.users.yes') : t('admin.users.no')) : (u.enabled != null ? (u.enabled ? t('admin.users.yes') : t('admin.users.no')) : '—')}</td>
                    <td>
                      <button className="btn-icon" onClick={() => openEdit(u)}>{t('admin.users.edit')}</button>
                      <select
                        className="mod-select"
                        value=""
                        onChange={e => { if (e.target.value) handleChangeRole(u.codeUtilisateur, e.target.value) }}
                      >
                        <option value="">{t('admin.users.changeRole')}</option>
                        <option value="CLIENT">CLIENT</option>
                        <option value="ORGANISATEUR">ORGANISATEUR</option>
                        <option value="ADMINISTRATEUR">ADMINISTRATEUR</option>
                      </select>
                      <button className="btn-icon" onClick={() => handleToggleActive(u.codeUtilisateur)}>
                        {t('admin.users.toggleActive')}
                      </button>
                      <button className="btn-icon" onClick={() => handleResetPassword(u.codeUtilisateur)}>
                        {t('admin.users.resetPwd')}
                      </button>
                      <button className="btn-icon danger" onClick={() => handleDelete(u.codeUtilisateur)}>{t('admin.users.delete')}</button>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={7} className="empty">{t('admin.users.noUsers')}</td></tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button className="btn-secondary" disabled={safePage <= 1} onClick={() => setPage(safePage - 1)}>{t('admin.users.prev')}</button>
            <span>{t('admin.dataTable.page')} {safePage} {t('admin.dataTable.of')} {totalPages}</span>
            <button className="btn-secondary" disabled={safePage >= totalPages} onClick={() => setPage(safePage + 1)}>{t('admin.users.next')}</button>
          </div>
        </>
      )}

      {modal && (
        <div className="modal-overlay" onClick={() => setModal(null)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3>{modal === 'create' ? t('admin.users.create') : t('admin.users.edit')} User</h3>
            <form onSubmit={handleSave}>
              <label>
                {t('admin.users.code')}
                <input type="text" value={form.codeUtilisateur || ''} onChange={e => setForm({ ...form, codeUtilisateur: e.target.value })} required />
              </label>
              <label>
                {t('admin.users.lastName')}
                <input type="text" value={form.nom || ''} onChange={e => setForm({ ...form, nom: e.target.value })} required />
              </label>
              <label>
                {t('admin.users.firstName')}
                <input type="text" value={form.prenoms || ''} onChange={e => setForm({ ...form, prenoms: e.target.value })} required />
              </label>
              <label>
                {t('admin.users.sexe')}
                <select value={form.sexe || ''} onChange={e => setForm({ ...form, sexe: e.target.value })}>
                  <option value="">—</option>
                  <option value="M">M</option>
                  <option value="F">F</option>
                </select>
              </label>
              <label>
                {t('admin.users.birthDate')}
                <input type="date" value={form.dateDeNaissance || ''} onChange={e => setForm({ ...form, dateDeNaissance: e.target.value })} />
              </label>
              <label>
                {t('admin.users.email')}
                <input type="email" value={form.email || ''} onChange={e => setForm({ ...form, email: e.target.value })} required />
              </label>
              <label>
                {t('admin.users.phone')}
                <input type="text" value={form.tel || ''} onChange={e => setForm({ ...form, tel: e.target.value })} />
              </label>
              {modal === 'create' && (
                <label>
                  {t('admin.users.password')}
                  <input type="password" value={form.motDePasse || ''} onChange={e => setForm({ ...form, motDePasse: e.target.value })} required />
                </label>
              )}
              {modal === 'edit' && (
                <label>
                  {t('admin.users.passwordKeep')}
                  <input type="password" value={form.motDePasse || ''} onChange={e => setForm({ ...form, motDePasse: e.target.value })} />
                </label>
              )}
              <label>
                {t('admin.users.roleLabel')}
                <select value={form.role || 'CLIENT'} onChange={e => setForm({ ...form, role: e.target.value })}>
                  <option value="CLIENT">CLIENT</option>
                  <option value="ORGANISATEUR">ORGANISATEUR</option>
                  <option value="ADMINISTRATEUR">ADMINISTRATEUR</option>
                </select>
              </label>
              <div className="form-actions">
                <button type="submit" className="btn-primary">{t('admin.users.save')}</button>
                <button type="button" className="btn-secondary" onClick={() => setModal(null)}>{t('admin.users.cancel')}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
