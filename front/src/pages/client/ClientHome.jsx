import { useState, useEffect, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAll } from '../../api/entityApi'
import { useLanguage } from '../../contexts/LanguageContext'

export default function ClientHome() {
  const navigate = useNavigate()
  const { t } = useLanguage()
  const [query, setQuery] = useState('')
  const [categories, setCategories] = useState([])
  const [selectedCategory, setSelectedCategory] = useState('')
  const [dateFrom, setDateFrom] = useState('')
  const [dateTo, setDateTo] = useState('')
  const [events, setEvents] = useState([])
  const [page, setPage] = useState(0)
  const [hasMore, setHasMore] = useState(true)
  const [loading, setLoading] = useState(false)
  const pageSize = 12

  useEffect(() => {
    getAll('/api/categories')
      .then(setCategories)
      .catch(() => {})
  }, [])

  const fetchEvents = useCallback(async (pageNum, append) => {
    setLoading(true)
    try {
      const params = new URLSearchParams()
      if (query) params.append('q', query)
      if (selectedCategory) params.append('categorie', selectedCategory)
      if (dateFrom) params.append('dateFrom', dateFrom)
      if (dateTo) params.append('dateTo', dateTo)
      params.append('page', pageNum)
      params.append('size', pageSize)

      const data = await getAll(`/api/evenements/search?${params.toString()}`)
      const content = data.content || data
      if (append) {
        setEvents(prev => [...prev, ...content])
      } else {
        setEvents(content)
      }
      if (data.last !== undefined) setHasMore(!data.last)
      else if (content.length < pageSize) setHasMore(false)
    } catch {
      if (!append) setEvents([])
    } finally {
      setLoading(false)
    }
  }, [query, selectedCategory, dateFrom, dateTo])

  useEffect(() => {
    setPage(0)
    fetchEvents(0, false)
  }, [fetchEvents])

  function handleSearch(e) {
    e.preventDefault()
    setPage(0)
    fetchEvents(0, false)
  }

  function handleLoadMore() {
    const next = page + 1
    setPage(next)
    fetchEvents(next, true)
  }

  function handleCategoryClick(cat) {
    setSelectedCategory(prev => prev === cat ? '' : cat)
  }

  function formatDate(dateStr) {
    if (!dateStr) return ''
    return new Date(dateStr).toLocaleDateString('fr-FR', {
      day: 'numeric', month: 'long', year: 'numeric'
    })
  }

  function getPriceRange(event) {
    if (!event.prixMin && !event.prixMax) return ''
    if (event.prixMin === event.prixMax) return `${event.prixMin} €`
    return `${event.prixMin || 0} € - ${event.prixMax} €`
  }

  return (
    <div className="client-home">
      <form className="search-bar" onSubmit={handleSearch}>
        <input
          type="text"
          placeholder={t('client.home.search')}
          value={query}
          onChange={e => setQuery(e.target.value)}
        />
        <input
          type="date"
          value={dateFrom}
          onChange={e => setDateFrom(e.target.value)}
          title={t('client.home.dateFrom')}
        />
        <input
          type="date"
          value={dateTo}
          onChange={e => setDateTo(e.target.value)}
          title={t('client.home.dateTo')}
        />
        <button type="submit" className="btn-primary">{t('client.home.searchBtn')}</button>
      </form>

      <div className="filter-chips">
        {categories.map(cat => (
          <button
            key={cat.idCategorie || cat.codeCategorie || cat}
            className={selectedCategory === (cat.idCategorie || cat.codeCategorie || cat) ? 'active' : ''}
            onClick={() => handleCategoryClick(cat.idCategorie || cat.codeCategorie || cat)}
          >
            {cat.nomCategorie || cat.libelle || cat}
          </button>
        ))}
      </div>

      <div className="event-grid">
        {events.map(event => (
          <div
            key={event.idEvenement}
            className="event-card"
            onClick={() => navigate(`/client/book/${event.idEvenement}`)}
          >
            {event.image && (
              <img src={event.image} alt={event.titre} />
            )}
            <div className="card-body">
              <h3>{event.titre}</h3>
              <p>{formatDate(event.dateEvenement)}</p>
              <p>{getPriceRange(event)}</p>
              <span className={`badge badge-${event.statut?.toLowerCase() || 'actif'}`}>
                {event.statut}
              </span>
            </div>
          </div>
        ))}
      </div>

      {loading && <div className="loading">{t('client.home.loading')}</div>}
      {!loading && events.length === 0 && <div className="empty">{t('client.home.noEvents')}</div>}

      {hasMore && !loading && (
        <div style={{ textAlign: 'center', margin: '1rem 0' }}>
          <button className="btn-secondary" onClick={handleLoadMore}>{t('client.home.loadMore')}</button>
        </div>
      )}
    </div>
  )
}
