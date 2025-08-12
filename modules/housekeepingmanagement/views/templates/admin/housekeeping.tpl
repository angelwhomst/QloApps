<div class="housekeeping-dashboard container-fluid">
  <h2>Housekeeping Management</h2>

  <!-- Summary cards -->
  <div id="hk-summary" class="row mb-3">
    {include file="module:housekeepingmanagement/views/templates/admin/summarycards.tpl"}
  </div>

  <div class="row">
    <div class="col-lg-6 mb-4">
      <!-- SOP Management -->
      <div class="sop-management">
        <h3>Manage SOPs</h3>
        <form id="sopForm">
          <div class="form-group">
            <label for="title">Title (required)</label>
            <input type="text" id="title" name="title" required>
          </div>

          <div class="form-group">
            <label for="description">Description (required)</label>
            <textarea id="description" name="description" required></textarea>
          </div>

          <div class="form-group">
            <label for="roomType">Room Type (optional)</label>
            <select id="roomType" name="roomType">
              <option value="">Select Room Type</option>
              <option value="single">Single</option>
              <option value="double">Double</option>
              <option value="suite">Suite</option>
            </select>
          </div>

          <div class="form-group">
            <label>SOP Steps (at least one required)</label>
            <div id="sopStepsContainer">
              <input type="text" name="sopSteps[]" required placeholder="Step 1">
            </div>
            <button type="button" onclick="addSOPStep()">Add Step</button>
          </div>

          <button type="submit">Submit</button>
        </form>

        <h3>Existing SOPs</h3>
        <table id="sopTable" class="table">
          <thead>
            <tr>
              <th>SOP Title</th>
              <th>Room Type</th>
              <th>Created By</th>
              <th>Last Updated</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <!-- Populate with existing SOPs via JavaScript -->
          </tbody>
        </table>
      </div>
    </div>

    <div class="col-lg-6 mb-4">
      <!-- Room Status -->
      {include file="module:housekeepingmanagement/views/templates/admin/roomstatus.tpl"}
    </div>
  </div>
</div>

{literal}
<script>
  // expose ajax url to JS
  window.HK = window.HK || {};
  window.HK.ajaxUrl = '{$housekeeping_ajax_url|escape:'html':'UTF-8'}';

  document.getElementById('sopForm').addEventListener('submit', function(event) {
      event.preventDefault();
      const formData = new FormData(this);

      fetch(window.HK.ajaxUrl + '/sop', {
          method: 'POST',
          body: formData
      })
      .then(response => response.json())
      .then(data => {
          alert('SOP created/updated successfully!');
          fetchSOPs(); // Refresh the SOP table
      })
      .catch(error => console.error('Error:', error));
  });

  function addSOPStep() {
      const container = document.getElementById('sopStepsContainer');
      const input = document.createElement('input');
      input.type = 'text';
      input.name = 'sopSteps[]';
      input.placeholder = 'Additional Step';
      container.appendChild(input);
  }

  function fetchSOPs() {
      fetch(window.HK.ajaxUrl + '/sops')
          .then(response => response.json())
          .then(data => {
              const tbody = document.querySelector('#sopTable tbody');
              tbody.innerHTML = '';
              data.forEach(sop => {
                  const row = document.createElement('tr');
                  row.innerHTML = `
                      <td>${sop.title}</td>
                      <td>${sop.roomType}</td>
                      <td>${sop.createdBy}</td>
                      <td>${sop.lastUpdated}</td>
                      <td>
                          <button onclick="editSOP(${sop.id})">Edit</button>
                          <button onclick="deleteSOP(${sop.id})">Delete</button>
                      </td>
                  `;
                  tbody.appendChild(row);
              });
          });
  }

  function deleteSOP(id) {
      if (confirm('Are you sure you want to delete this SOP?')) {
          fetch(window.HK.ajaxUrl + '/sop/' + id, { method: 'DELETE' })
              .then(() => fetchSOPs()); // Refresh SOPs after deletion
      }
  }

  // Call fetchSOPs on page load
  window.onload = fetchSOPs;
</script>
{/literal}