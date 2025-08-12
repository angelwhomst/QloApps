<div class="housekeeping-dashboard container-fluid">

    {* ===== Summary Cards ===== *}
    <div class="d-flex flex-wrap gap-3 mb-4 justify-content-between">
        <div class="summary-card border-start border-4 border-primary bg-white p-3 flex-fill" style="min-width: 180px;">
            <div class="d-flex flex-column align-items-center justify-content-center text-primary">
                <small class="fw-semibold">Total Rooms</small>
                <span id="total-rooms" class="fs-3 fw-bold">0</span>
            </div>
        </div>
        <div class="summary-card border-start border-4 border-success bg-white p-3 flex-fill" style="min-width: 180px;">
            <div class="d-flex flex-column align-items-center justify-content-center text-success">
                <small class="fw-semibold">Cleaned Rooms</small>
                <span id="cleaned-rooms" class="fs-3 fw-bold">0</span>
            </div>
        </div>
        <div class="summary-card border-start border-4 border-warning bg-white p-3 flex-fill" style="min-width: 180px;">
            <div class="d-flex flex-column align-items-center justify-content-center text-warning">
                <small class="fw-semibold">Not Cleaned Rooms</small>
                <span id="not-cleaned-rooms" class="fs-3 fw-bold">0</span>
            </div>
        </div>
        <div class="summary-card border-start border-4 border-danger bg-white p-3 flex-fill" style="min-width: 180px;">
            <div class="d-flex flex-column align-items-center justify-content-center text-danger">
                <small class="fw-semibold">Failed Inspections</small>
                <span id="failed-inspections" class="fs-3 fw-bold">0</span>
            </div>
        </div>
    </div>

    {* ===== SOP Management ===== *}
    <div class="card mb-4 shadow-sm rounded-3">
        <div class="card-header d-flex justify-content-between align-items-center bg-white border-0 pb-0">
            <h5 class="mb-0 fw-bold">SOP Management</h5>
            <div>
              <button id="btn-add-sop" class="btn btn-primary btn-sm rounded-3">Add SOP</button>
              <button id="btn-reset-data" class="btn btn-outline-secondary btn-sm rounded-3">Reset Demo Data</button>
            </div>
        </div>
        <div class="card-body pt-2">
            <div id="sop-form-container" class="mb-4" style="display:none;">
                {include file="modules/housekeepingexecutive/views/templates/admin/partials/sop_form.tpl"}
            </div>

            <div id="sop-table-container">
                {include file="modules/housekeepingexecutive/views/templates/admin/partials/sop_table.tpl"}
            </div>
        </div>
    </div>

    {* ===== Room Status ===== *}
    <div class="card shadow-sm rounded-3">
        <div class="card-header bg-white border-0 pb-0">
            <ul class="nav nav-tabs card-header-tabs" id="room-status-tabs">
                <li class="nav-item">
                    <a class="nav-link active fw-semibold" data-status="all" href="#">All Rooms</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold" data-status="cleaned" href="#">Cleaned</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold" data-status="not_cleaned" href="#">Not Cleaned</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link fw-semibold" data-status="failed" href="#">Failed Inspections</a>
                </li>
            </ul>
        </div>
        <div class="card-body pt-2" id="room-table-container">
            {include file="modules/housekeepingexecutive/views/templates/admin/partials/room_table.tpl"}
        </div>
    </div>

</div>

{* Include CSS & JS assets for frontend-only demo *}
<link rel="stylesheet" href="modules/housekeepingmanagement/views/css/dashboard.css">
<script src="modules/housekeepingexecutive/views/js/housekeepingexecutive.js"></script>
