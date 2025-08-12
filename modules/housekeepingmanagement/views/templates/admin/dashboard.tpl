<link rel="stylesheet" type="text/css" href="{$module_dir}views/css/housekeeping.css">

<div class="housekeeping-dashboard">
  
  <h2 class="page-title">Housekeeping Management</h2>

  <!-- Summary Stat Boxes -->
  <div class="stat-row">
    <div class="stat-card bg-blue">
      <span class="stat-number">{$summary.total_rooms}</span>
      <span class="stat-label">Total Rooms</span>
    </div>
    <div class="stat-card bg-green">
      <span class="stat-number">{$summary.cleaned_rooms}</span>
      <span class="stat-label">Cleaned Rooms</span>
    </div>
    <div class="stat-card bg-yellow">
      <span class="stat-number">{$summary.not_cleaned_rooms}</span>
      <span class="stat-label">Not Cleaned</span>
    </div>
    <div class="stat-card bg-red">
      <span class="stat-number">{$summary.failed_inspections}</span>
      <span class="stat-label">Failed Inspections</span>
    </div>
  </div>

  <!-- SOP Management -->
  <div class="card-section">
    <h3>Standard Operating Procedures</h3>
    <table class="styled-table">
      <thead>
        <tr>
          <th>Title</th>
          <th>Room Type</th>
          <th>Created By</th>
          <th>Last Updated</th>
        </tr>
      </thead>
      <tbody>
        {foreach $sops as $sop}
          <tr>
            <td>{$sop.title}</td>
            <td>{$sop.room_type}</td>
            <td>{$sop.created_by}</td>
            <td>{$sop.last_updated}</td>
          </tr>
        {/foreach}
      </tbody>
    </table>
  </div>

  <!-- Room Status -->
  <div class="card-section">
    <h3>Room Status</h3>
    <table class="styled-table">
      <thead>
        <tr>
          <th>Room Number</th>
          <th>Type</th>
          <th>Status</th>
          <th>Assigned Staff</th>
          <th>Last Updated</th>
        </tr>
      </thead>
      <tbody>
        {foreach $rooms as $room}
          <tr>
            <td>{$room.number}</td>
            <td>{$room.type}</td>
            <td>{$room.status}</td>
            <td>{$room.staff}</td>
            <td>{$room.last_updated}</td>
          </tr>
        {/foreach}
      </tbody>
    </table>
  </div>
</div>
