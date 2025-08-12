// housekeepingexecutive.js
// Frontend-only demo: client-side data + DOM rendering for SOPs and Rooms
(function () {
  // ------- Demo initial data --------
  let sops = [
    {
      id: 1,
      title: 'Standard Room Clean',
      description: 'Standard cleaning for regular rooms.',
      room_type: 'Standard',
      steps: ['Strip bedding', 'Dust surfaces', 'Mop floor'],
      created_by: 'Admin',
      date_upd: nowStr()
    },
    {
      id: 2,
      title: 'VIP Suite Procedure',
      description: 'Extra attention for VIPs.',
      room_type: 'Suite',
      steps: ['Check minibar', 'Polish glass', 'Vacuum carpets'],
      created_by: 'Manager',
      date_upd: nowStr(-1)
    }
  ];

  let rooms = [
    { id: 101, room_number: '101', room_type: 'Standard', status: 'Cleaned', assigned_staff: 'Alice', date_upd: nowStr(-2) },
    { id: 102, room_number: '102', room_type: 'Standard', status: 'Not Cleaned', assigned_staff: 'Bob', date_upd: nowStr(-3) },
    { id: 201, room_number: '201', room_type: 'Suite', status: 'Failed Inspection', assigned_staff: 'Charlie', date_upd: nowStr(-4) },
    { id: 202, room_number: '202', room_type: 'Deluxe', status: 'Cleaned', assigned_staff: 'Dina', date_upd: nowStr(-1) },
    { id: 203, room_number: '203', room_type: 'Deluxe', status: 'Not Cleaned', assigned_staff: 'Evan', date_upd: nowStr() }
  ];

  // state
  let currentRoomFilter = 'all'; // all | cleaned | not_cleaned | failed

  // ------- Utilities -------
  function nowStr(daysOffset = 0) {
    const d = new Date();
    if (daysOffset) d.setDate(d.getDate() + daysOffset);
    return d.toLocaleString();
  }
  function el(sel) { return document.querySelector(sel); }
  function elAll(sel) { return Array.from(document.querySelectorAll(sel)); }
  function show(selector) { const e = el(selector); if (e) e.style.display = ''; }
  function hide(selector) { const e = el(selector); if (e) e.style.display = 'none'; }
  function clearChildren(node) { while (node && node.firstChild) node.removeChild(node.firstChild); }
  function idNew() { return Math.max(0, ...sops.map(s => s.id)) + 1; }

  // ------- Summary Cards -------
  function updateSummaryCards(filteredRooms = null) {
    // If filteredRooms given, compute on that; otherwise use all rooms.
    const arr = filteredRooms || rooms;
    const total = arr.length;
    const cleaned = arr.filter(r => r.status === 'Cleaned').length;
    const notCleaned = arr.filter(r => r.status === 'Not Cleaned').length;
    const failed = arr.filter(r => r.status === 'Failed Inspection').length;

    el('#total-rooms').textContent = total;
    el('#cleaned-rooms').textContent = cleaned;
    el('#not-cleaned-rooms').textContent = notCleaned;
    el('#failed-inspections').textContent = failed;
  }

  // ------- Room Table Rendering -------
  function renderRooms(filter = 'all') {
    currentRoomFilter = filter;
    const tbody = el('#room-table tbody');
    hide('#room-empty');
    show('#room-loading');
    clearChildren(tbody);

    // simulate loading
    setTimeout(() => {
      hide('#room-loading');
      let filtered = rooms.slice();
      if (filter === 'cleaned') filtered = filtered.filter(r => r.status === 'Cleaned');
      else if (filter === 'not_cleaned') filtered = filtered.filter(r => r.status === 'Not Cleaned');
      else if (filter === 'failed') filtered = filtered.filter(r => r.status === 'Failed Inspection');

      if (!filtered.length) {
        show('#room-empty');
        updateSummaryCards([]); // cards reflect filtered (empty)
        return;
      }
      hide('#room-empty');

      const rows = filtered.map(r => {
        return `<tr>
          <td>${escape(r.room_number)}</td>
          <td>${escape(r.room_type)}</td>
          <td>${statusBadge(r.status)}</td>
          <td>${escape(r.assigned_staff)}</td>
          <td>${escape(r.date_upd)}</td>
        </tr>`;
      }).join('');
      tbody.insertAdjacentHTML('beforeend', rows);

      // update summary cards based on filtered set (per requirement)
      updateSummaryCards(filtered);
    }, 250);
  }

  function statusBadge(status) {
    const map = {
      'Cleaned': 'badge badge-success',
      'Not Cleaned': 'badge badge-warning',
      'Failed Inspection': 'badge badge-danger'
    };
    const cls = map[status] || 'badge badge-secondary';
    return `<span class="${cls}">${escape(status)}</span>`;
  }

  // ------- SOP Table Rendering -------
  function renderSOPs() {
    const tbody = el('#sop-table tbody');
    hide('#sop-empty');
    show('#sop-loading');
    clearChildren(tbody);

    setTimeout(() => {
      hide('#sop-loading');
      if (!sops.length) {
        show('#sop-empty');
        return;
      }
      hide('#sop-empty');
      const rows = sops.map(s => {
        return `<tr data-id="${s.id}">
          <td>${escape(s.title)}</td>
          <td>${escape(s.room_type || '')}</td>
          <td>${escape(s.created_by || '—')}</td>
          <td>${escape(s.date_upd)}</td>
          <td>
            <button class="btn btn-sm btn-outline-primary btn-sop-edit" data-id="${s.id}">Edit</button>
            <button class="btn btn-sm btn-outline-danger btn-sop-delete" data-id="${s.id}">Delete</button>
          </td>
        </tr>`;
      }).join('');
      tbody.insertAdjacentHTML('beforeend', rows);
    }, 200);
  }

  // ------- Form helpers -------
  function resetForm() {
    el('#sop-id').value = '';
    el('#sop-title').value = '';
    el('#sop-description').value = '';
    el('#sop-room-type').value = '';
    const steps = el('#sop-steps');
    clearChildren(steps);
    addStepInput('');
    hide('#sop-title-error');
    hide('#sop-description-error');
    hide('#sop-steps-error');
  }

  function addStepInput(value = '') {
    const steps = el('#sop-steps');
    const div = document.createElement('div');
    div.className = 'input-group mb-2 sop-step-row';
    div.innerHTML = `
      <input type="text" class="form-control sop-step-input" placeholder="Step description" value="${escape(value)}">
      <div class="input-group-append">
        <button type="button" class="btn btn-outline-danger btn-sop-remove-step" title="Remove step">Remove</button>
      </div>`;
    steps.appendChild(div);
    div.querySelector('.btn-sop-remove-step').addEventListener('click', () => div.remove());
  }

  // ------- Form validation & save -------
  function validateForm() {
    const title = el('#sop-title').value.trim();
    const desc = el('#sop-description').value.trim();
    const stepInputs = Array.from(document.querySelectorAll('.sop-step-input')).map(i => i.value.trim()).filter(Boolean);

    let ok = true;
    if (!title) {
      el('#sop-title-error').style.display = 'block';
      ok = false;
    } else {
      el('#sop-title-error').style.display = 'none';
    }

    if (!desc) {
      el('#sop-description-error').style.display = 'block';
      ok = false;
    } else {
      el('#sop-description-error').style.display = 'none';
    }

    if (!stepInputs.length) {
      el('#sop-steps-error').style.display = 'block';
      ok = false;
    } else {
      el('#sop-steps-error').style.display = 'none';
    }

    return ok;
  }

  function saveSOPFromForm() {
    if (!validateForm()) return false;
    const idVal = el('#sop-id').value;
    const title = el('#sop-title').value.trim();
    const desc = el('#sop-description').value.trim();
    const roomType = el('#sop-room-type').value;
    const steps = Array.from(document.querySelectorAll('.sop-step-input')).map(i => i.value.trim()).filter(Boolean);

    if (idVal) {
      const id = parseInt(idVal, 10);
      const idx = sops.findIndex(s => s.id === id);
      if (idx >= 0) {
        sops[idx].title = title;
        sops[idx].description = desc;
        sops[idx].room_type = roomType;
        sops[idx].steps = steps;
        sops[idx].date_upd = nowStr();
      }
    } else {
      const newSop = {
        id: idNew(),
        title: title,
        description: desc,
        room_type: roomType,
        steps: steps,
        created_by: 'Admin',
        date_upd: nowStr()
      };
      sops.unshift(newSop);
    }
    renderSOPs();
    toggleForm(false);
    return true;
  }

  // ------- Edit / Delete Handlers -------
  function handleSopEdit(id) {
    const sop = sops.find(s => s.id === id);
    if (!sop) return;
    toggleForm(true);
    el('#sop-id').value = sop.id;
    el('#sop-title').value = sop.title;
    el('#sop-description').value = sop.description;
    el('#sop-room-type').value = sop.room_type || '';
    const steps = el('#sop-steps');
    clearChildren(steps);
    (sop.steps || []).forEach(st => addStepInput(st));
  }

  function handleSopDelete(id) {
    const sop = sops.find(s => s.id === id);
    if (!sop) return;
    if (!confirm(`Delete SOP "${sop.title}"? This action cannot be undone.`)) return;
    sops = sops.filter(s => s.id !== id);
    renderSOPs();
    // if the form was editing this sop, reset
    if (el('#sop-id').value == id) resetForm();
  }

  // ------- UI toggle for form -------
  function toggleForm(showFormFlag) {
    if (showFormFlag) {
      show('#sop-form-container');
      el('#btn-add-sop').textContent = 'Hide Form';
      // scroll to form
      el('#sop-form-container').scrollIntoView({ behavior: 'smooth', block: 'center' });
    } else {
      hide('#sop-form-container');
      el('#btn-add-sop').textContent = 'Add SOP';
      resetForm();
    }
  }

  // ------- Events binding -------
  function bindEvents() {
    // Add/hide form button
    el('#btn-add-sop').addEventListener('click', () => {
      const isVisible = getComputedStyle(el('#sop-form-container')).display !== 'none';
      toggleForm(!isVisible);
    });

    // Reset demo data button
    el('#btn-reset-data').addEventListener('click', () => {
      if (!confirm('Reset demo data? This will restore initial demo SOPs and rooms.')) return;
      // reset demo arrays
      sops = [
        {
          id: 1,
          title: 'Standard Room Clean',
          description: 'Standard cleaning for regular rooms.',
          room_type: 'Standard',
          steps: ['Strip bedding', 'Dust surfaces', 'Mop floor'],
          created_by: 'Admin',
          date_upd: nowStr()
        },
        {
          id: 2,
          title: 'VIP Suite Procedure',
          description: 'Extra attention for VIPs.',
          room_type: 'Suite',
          steps: ['Check minibar', 'Polish glass', 'Vacuum carpets'],
          created_by: 'Manager',
          date_upd: nowStr(-1)
        }
      ];
      rooms = [
        { id: 101, room_number: '101', room_type: 'Standard', status: 'Cleaned', assigned_staff: 'Alice', date_upd: nowStr(-2) },
        { id: 102, room_number: '102', room_type: 'Standard', status: 'Not Cleaned', assigned_staff: 'Bob', date_upd: nowStr(-3) },
        { id: 201, room_number: '201', room_type: 'Suite', status: 'Failed Inspection', assigned_staff: 'Charlie', date_upd: nowStr(-4) },
        { id: 202, room_number: '202', room_type: 'Deluxe', status: 'Cleaned', assigned_staff: 'Dina', date_upd: nowStr(-1) },
        { id: 203, room_number: '203', room_type: 'Deluxe', status: 'Not Cleaned', assigned_staff: 'Evan', date_upd: nowStr() }
      ];
      renderSOPs();
      renderRooms(currentRoomFilter);
    });

    // Add step button on form
    el('#sop-add-step').addEventListener('click', () => addStepInput(''));

    // Cancel button
    el('#sop-cancel').addEventListener('click', (e) => {
      e.preventDefault();
      toggleForm(false);
    });

    // Save form
    el('#sop-form').addEventListener('submit', function (e) {
      e.preventDefault();
      saveSOPFromForm();
    });

    // Delegate edit/delete on SOP table
    el('#sop-table').addEventListener('click', function (e) {
      const btn = e.target.closest('button');
      if (!btn) return;
      if (btn.classList.contains('btn-sop-edit')) {
        const id = parseInt(btn.dataset.id, 10);
        handleSopEdit(id);
      } else if (btn.classList.contains('btn-sop-delete')) {
        const id = parseInt(btn.dataset.id, 10);
        handleSopDelete(id);
      }
    });

    // Room filter tabs
    elAll('#room-status-tabs .nav-link').forEach(tab => {
      tab.addEventListener('click', function (e) {
        e.preventDefault();
        elAll('#room-status-tabs .nav-link').forEach(t => t.classList.remove('active'));
        this.classList.add('active');
        const status = this.dataset.status;
        renderRooms(status);
      });
    });

    // Delegate remove step buttons (for dynamically added inputs we add listeners in addStepInput)
  }

  // ------- Basic helpers -------
  function escape(s) {
    if (s === undefined || s === null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

  // ------- Initial render -------
  function init() {
    // set up initial form and tables
    resetForm();
    renderSOPs();
    renderRooms('all');
    bindEvents();
  }

  // Run when DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
