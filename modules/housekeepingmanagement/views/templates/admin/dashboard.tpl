<div class="housekeeping-dashboard">
  <h2>Housekeeping Management Dashboard</h2>

  <!-- Summary Cards -->
  <div class="summary-cards">
    <div class="card">Total Rooms: {$summary.total_rooms}</div>
    <div class="card">Cleaned Rooms: {$summary.cleaned_rooms}</div>
    <div class="card">Not Cleaned: {$summary.not_cleaned_rooms}</div>
    <div class="card">Failed Inspections: {$summary.failed_inspections}</div>
  </div>

  <!-- SOP Management -->
  <h3>Standard Operating Procedures</h3>
  <table>
    <thead>
      <tr>
        <th>Title</th><th>Room Type</th><th>Created By</th><th>Last Updated</th>
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

  <!-- Room Status Table -->
  <h3>Room Status</h3>
  <table>
    <thead>
      <tr>
        <th>Room Number</th><th>Type</th><th>Status</th><th>Assigned Staff</th><th>Last Updated</th>
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
