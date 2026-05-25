let token = null;
let userInfo = null;

export function setAuthToken(t) { token = t; }
export function getAuthToken() { return token; }
export function setUserInfo(u) { userInfo = u; }
export function getUserInfo() { return userInfo; }

function headers() {
  const h = { 'Content-Type': 'application/json' };
  if (token) h['Authorization'] = `Bearer ${token}`;
  return h;
}

async function handleResponse(res) {
  const body = await res.json();
  if (!res.ok) {
    const msg = body?.message || body?.error || `HTTP ${res.status}`;
    throw new Error(msg);
  }
  return body;
}

export async function loginAdmin(code, password) {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: headers(),
    body: JSON.stringify({ email: code, motDePasse: password }),
  });
  return handleResponse(res);
}

export async function register(data) {
  const res = await fetch('/api/auth/register', {
    method: 'POST',
    headers: headers(),
    body: JSON.stringify(data),
  });
  return handleResponse(res);
}

export async function getAll(endpoint) {
  const res = await fetch(endpoint, { headers: headers() });
  return handleResponse(res);
}

export async function getById(endpoint, id) {
  const res = await fetch(`${endpoint}/${encodeURIComponent(id)}`, { headers: headers() });
  return handleResponse(res);
}

export async function create(endpoint, data) {
  const res = await fetch(endpoint, {
    method: 'POST',
    headers: headers(),
    body: JSON.stringify(data),
  });
  return handleResponse(res);
}

export async function update(endpoint, id, data) {
  const res = await fetch(`${endpoint}/${encodeURIComponent(id)}`, {
    method: 'PUT',
    headers: headers(),
    body: JSON.stringify(data),
  });
  return handleResponse(res);
}

export async function remove(endpoint, id) {
  const res = await fetch(`${endpoint}/${encodeURIComponent(id)}`, {
    method: 'DELETE',
    headers: headers(),
  });
  return handleResponse(res);
}
