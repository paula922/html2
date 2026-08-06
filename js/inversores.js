const inversores = [
  { id: '7721098821', name: 'Global Capital Group', email: 'corp@globalcapital.io', phone: '3002211445', type: 'Jurídico', part: 25.5, status: 'ACTIVO' },
  { id: '1023445566', name: 'Inversiones del Pacífico S.A.', email: 'gestion@invpacifico.co', phone: '3114455882', type: 'Jurídico', part: 18.0, status: 'ACTIVO' },
  { id: '8827711002', name: 'Dr. Fernando Arango', email: 'fernando.arango@med.com', phone: '3009988112', type: 'Natural', part: 12.2, status: 'INACTIVO' },
  { id: '1109922883', name: 'Fundación Bienestar Social', email: 'proyectos@fbienestar.org', phone: '3205566778', type: 'Jurídico', part: 5.4, status: 'ACTIVO' },
  { id: '9921188334', name: 'Ing. Marta Lucía Pérez', email: 'marta.perez@consultores.co', phone: '3152233445', type: 'Natural', part: 8.8, status: 'ACTIVO' },
  { id: '1002233445', name: 'Holdings Unidas del Norte', email: 'admin@unidasnorte.co', phone: '3041122334', type: 'Jurídico', part: 30.1, status: 'INACTIVO' },
];

let searchTerm = '';
let typeFilter = '';
let statusFilter = '';

window.filterInversores = function (val) { searchTerm = val; renderInversores(); };
window.filterByType = function (val) { typeFilter = val; renderInversores(); };
window.filterByStatus = function (val) { statusFilter = val; renderInversores(); };
window.resetInversores = function () {
  searchTerm = ''; typeFilter = ''; statusFilter = '';
  document.querySelectorAll('.filter-input,.filter-select').forEach(el => el.value = '');
  renderInversores();
};

window.renderInversores = function () {
  const grid = document.getElementById('inversores-grid');
  if (!grid) return;
  const filtered = inversores.filter(inv => {
    const matchSearch = inv.name.toLowerCase().includes(searchTerm.toLowerCase()) || inv.id.includes(searchTerm);
    const matchType = !typeFilter || inv.type === typeFilter;
    const matchStatus = !statusFilter || inv.status === statusFilter;
    return matchSearch && matchType && matchStatus;
  });
  if (filtered.length === 0) {
    grid.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:60px 20px;background:var(--card);border:2px dashed var(--border);border-radius:32px"><h3 style="font-weight:900;text-transform:uppercase;color:var(--text)">Sin resultados</h3><p style="color:var(--text-muted);margin-top:4px">No hay inversores que coincidan con los filtros.</p><button onclick="resetInversores()" style="margin-top:16px;font-size:11px;font-weight:900;color:var(--blue-600);background:none;border:none;cursor:pointer;text-transform:uppercase;text-decoration:underline">Restablecer Búsqueda</button></div>`;
    return;
  }
  grid.innerHTML = filtered.map(inv => `
    <div class="inversor-card">
      <div class="inversor-top">
        <div class="inv-avatar-wrap">
          <img class="inv-avatar" src="https://picsum.photos/seed/${inv.id}/100/100" alt="${inv.name}"/>
          <div class="inv-status-dot ${inv.status === 'ACTIVO' ? 'active' : 'inactive'}">
            ${inv.status === 'ACTIVO'
              ? '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>'
              : '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>'
            }
          </div>
        </div>
        <div>
          <div class="inv-name">${inv.name}</div>
          <div class="inv-badges">
            <span class="badge badge-blue">${inv.type}</span>
            <span class="badge ${inv.status === 'ACTIVO' ? 'badge-green' : 'badge-gray'}">${inv.status}</span>
          </div>
        </div>
      </div>
      <div class="inv-details">
        <div class="inv-detail"><div class="inv-detail-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg></div>${inv.email}</div>
        <div class="inv-detail"><div class="inv-detail-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13 19.79 19.79 0 0 1 1.61 4.38 2 2 0 0 1 3.58 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg></div>(+57) ${inv.phone}</div>
        <div class="inv-detail" style="font-size:12px;font-family:monospace;font-style:italic"><div class="inv-detail-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="4" y1="9" x2="20" y2="9"/><line x1="4" y1="15" x2="20" y2="15"/><line x1="10" y1="3" x2="8" y2="21"/><line x1="16" y1="3" x2="14" y2="21"/></svg></div>ID: ${inv.id}</div>
      </div>
      <div class="inv-part-row">
        <div class="inv-part-label">
          <span class="inv-part-text">Participación Societaria</span>
          <span class="inv-part-pct">${inv.part}%</span>
        </div>
        <div class="progress-bar"><div class="progress-fill" style="width:${inv.part}%;${inv.status !== 'ACTIVO' ? 'background:#9ca3af;box-shadow:none' : ''}"></div></div>
      </div>
    </div>
  `).join('');
};