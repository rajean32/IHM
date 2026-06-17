import { useState, useEffect, useCallback } from 'react'
import { useParams } from 'react-router-dom'
import { ENTITY_CONFIG } from '../../utils/entityConfig'
import { getAll, getById, create, update, remove } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

const PAGE_SIZE = 15

export default function AdminDataTable() {
  const { entity } = useParams()
  const config = ENTITY_CONFIG[entity]
  const { t } = useLanguage()

  const [rows, setRows] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [sortKey, setSortKey] = useState(null)
  const [sortAsc, setSortAsc] = useState(true)
  const [modal, setModal] = useState(null)
  const [form, setForm] = useState({})

  const loadData = useCallback(() => {
    if (!config) return
    setLoading(true)
    getAll(config.endpoint)
      .then(res => {
        const items = Array.isArray(res) ? res : (res.data || res.content || [])
        setRows(items)
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [config])

  useEffect(() => { loadData() }, [loadData])

  if (!config) return <div className="empty">{t('admin.dataTable.entityNotFound')}</div>

  const fields = config.fields || []
  const displayFields = config.displayFields || []

  const filtered = rows.filter(row =>
    displayFields.some(fk => {
      const v = row[fk]
      return v != null && String(v).toLowerCase().includes(search.toLowerCase())
    })
  )

  const sorted = [...filtered].sort((a, b) => {
    if (!sortKey) return 0
    const va = a[sortKey], vb = b[sortKey]
    if (va == null) return 1
    if (vb == null) return -1
    if (typeof va === 'number') return sortAsc ? va - vb : vb - va
    return sortAsc
      ? String(va).localeCompare(String(vb))
      : String(vb).localeCompare(String(va))
  })

  const totalPages = Math.ceil(sorted.length / PAGE_SIZE) || 1
  const safePage = Math.min(page, totalPages)
  const paginated = sorted.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  function handleSort(fk) {
    if (sortKey === fk) setSortAsc(!sortAsc)
    else { setSortKey(fk); setSortAsc(true) }
    setPage(1)
  }

  function openCreate() {
    const init = {}
    fields.forEach(f => { init[f.key] = '' })
    setForm(init)
    setModal('create')
  }

  function openEdit(row) {
    const init = {}
    fields.forEach(f => { init[f.key] = row[f.key] ?? '' })
    setForm(init)
    setModal('edit')
    setForm({ ...init, _id: row[fields.find(f => !f.editable)?.key] })
  }

  async function handleSave(e) {
    e.preventDefault()
    try {
      if (modal === 'create') {
        await create(config.endpoint, form)
      } else {
        const idField = fields.find(f => !f.editable)
        const id = idField ? form[idField.key] : form._id
        await update(config.endpoint, id, form)
      }
      setModal(null)
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  async function handleDelete(row) {
    if (!window.confirm(t('admin.dataTable.deleteConfirm'))) return
    try {
      const idField = fields.find(f => !f.editable)
      const id = idField ? row[idField.key] : row._id
      await remove(config.endpoint, id)
      loadData()
    } catch (err) {
      setError(err.message)
    }
  }

  function renderFieldInput(field, value, onChange) {
    const val = value ?? ''
    if (field.type === 'textarea') {
      return <textarea value={val} onChange={e => onChange(e.target.value)} />
    }
    if (field.type === 'select') {
      return (
        <select value={val} onChange={e => onChange(e.target.value)}>
          <option value="">—</option>
          {(field.options || []).map(o => <option key={o} value={o}>{o}</option>)}
        </select>
      )
    }
    if (field.type === 'number') {
      return <input type="number" value={val} onChange={e => onChange(e.target.value)} />
    }
    if (field.type === 'date') {
      return <input type="date" value={val} onChange={e => onChange(e.target.value)} />
    }
    if (field.type === 'datetime' || field.type === 'datetime-local') {
      return <input type="datetime-local" value={val} onChange={e => onChange(e.target.value)} />
    }
    if (field.type === 'email') {
      return <input type="email" value={val} onChange={e => onChange(e.target.value)} />
    }
    return <input type="text" value={val} onChange={e => onChange(e.target.value)} />
  }

  return (
    <div className="data-table-page">
      <div className="section-header">
        <h2>{config.label}</h2>
        <button className="btn-primary" onClick={openCreate}>{t('admin.dataTable.addNew')}</button>
      </div>

      {error && <p className="error-msg">{error}</p>}

      <input
        className="search-bar"
        type="text"
        placeholder={t('admin.dataTable.search')}
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
                  {displayFields.map(fk => {
                    const fieldDef = fields.find(f => f.key === fk)
                    return (
                      <th key={fk} onClick={() => handleSort(fk)} style={{ cursor: 'pointer' }}>
                        {fieldDef?.label || fk}
                        {sortKey === fk ? (sortAsc ? ' ▲' : ' ▼') : ''}
                      </th>
                    )
                  })}
                  <th>{t('admin.dataTable.actions')}</th>
                </tr>
              </thead>
              <tbody>
                {paginated.map((row, i) => (
                  <tr key={row[fields.find(f => !f.editable)?.key] || i}>
                    {displayFields.map(fk => (
                      <td key={fk}>{row[fk] != null ? String(row[fk]) : '—'}</td>
                    ))}
                    <td>
                      <button className="btn-icon" onClick={() => openEdit(row)}>{t('admin.dataTable.edit')}</button>
                      <button className="btn-icon danger" onClick={() => handleDelete(row)}>{t('admin.dataTable.delete')}</button>
                    </td>
                  </tr>
                ))}
                {paginated.length === 0 && (
                  <tr><td colSpan={displayFields.length + 1} className="empty">{t('admin.dataTable.noRecords')}</td></tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="pagination">
            <button className="btn-secondary" disabled={safePage <= 1} onClick={() => setPage(safePage - 1)}>{t('admin.dataTable.prev')}</button>
            <span>{t('admin.dataTable.page')} {safePage} {t('admin.dataTable.of')} {totalPages}</span>
            <button className="btn-secondary" disabled={safePage >= totalPages} onClick={() => setPage(safePage + 1)}>{t('admin.dataTable.next')}</button>
          </div>
        </>
      )}

      {modal && (
        <div className="modal-overlay" onClick={() => setModal(null)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3>{modal === 'create' ? t('admin.dataTable.create') : t('admin.dataTable.edit')} {config.label}</h3>
            <form onSubmit={handleSave}>
              {fields.map(f => (
                <label key={f.key}>
                  {f.label}
                  {renderFieldInput(f, form[f.key], val => setForm({ ...form, [f.key]: val }))}
                </label>
              ))}
              <div className="form-actions">
                <button type="submit" className="btn-primary">{t('admin.dataTable.save')}</button>
                <button type="button" className="btn-secondary" onClick={() => setModal(null)}>{t('admin.dataTable.cancel')}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
