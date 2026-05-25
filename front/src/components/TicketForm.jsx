import { useState, useEffect } from 'react'
import { getAll, create, remove } from '../api/entityApi'

export default function TicketForm({ userRole }) {
  const [records, setRecords] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [code, setCode] = useState('')
  const [prix, setPrix] = useState('')

  const isOrganisateur = userRole === 'ORGANISATEUR'

  async function fetchAll() {
    setLoading(true)
    try {
      const res = await getAll('/api/tickets')
      setRecords(Array.isArray(res.data) ? res.data : [])
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchAll() }, [])

  async function handleCreate(e) {
    e.preventDefault()
    if (!isOrganisateur) return
    setLoading(true)
    setError('')
    try {
      await create('/api/tickets', { codeTicket: code, prix: parseFloat(prix) })
      setCode('')
      setPrix('')
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function handleDelete(id) {
    if (!isOrganisateur) return
    if (!window.confirm('Supprimer ce ticket ?')) return
    setLoading(true)
    try {
      await remove('/api/tickets', id)
      fetchAll()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="section-container">
      <h2>Tarification — Tickets</h2>

      {isOrganisateur && (
        <form className="custom-form compact" onSubmit={handleCreate}>
          <h3>Nouveau ticket</h3>
          <div className="form-row">
            <label>Code ticket *<input value={code} onChange={e => setCode(e.target.value)} placeholder="ex: TCK-INDIV" required /></label>
            <label>Prix (€) *<input type="number" step="0.01" min="0" value={prix} onChange={e => setPrix(e.target.value)} required /></label>
          </div>
          {error && <p className="msg error">{error}</p>}
          <button type="submit" className="btn-primary" disabled={loading}>{loading ? '...' : 'Créer le ticket'}</button>
        </form>
      )}

      {!isOrganisateur && (
        <p className="form-subtitle" style={{ marginBottom: '1rem' }}>Consultation des tarifs</p>
      )}

      <h4 style={{ marginTop: '1.5rem' }}>Tickets disponibles</h4>
      {!loading && records.length === 0 && <p className="empty">Aucun ticket</p>}
      {records.length > 0 && (
        <div className="table-wrap">
          <table>
            <thead><tr><th>Code</th><th>Prix (€)</th>{isOrganisateur && <th>Actions</th>}</tr></thead>
            <tbody>
              {records.map(r => (
                <tr key={r.codeTicket}>
                  <td>{r.codeTicket}</td>
                  <td>{parseFloat(r.prix).toFixed(2)}</td>
                  {isOrganisateur && (
                    <td><button className="btn-icon danger" onClick={() => handleDelete(r.codeTicket)} disabled={loading}>✕</button></td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
