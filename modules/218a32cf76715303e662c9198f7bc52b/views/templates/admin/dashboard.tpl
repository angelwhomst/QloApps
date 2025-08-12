<div class="housekeeping-dashboard container-fluid">

    {* ===== Summary Cards ===== *}
    <div class="row mb-4">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-white bg-primary h-100">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <h6 class="card-title">Total Rooms</h6>
                    <h2 id="total-rooms">0</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-white bg-success h-100">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <h6 class="card-title">Cleaned Rooms</h6>
                    <h2 id="cleaned-rooms">0</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-white bg-warning h-100">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <h6 class="card-title">Not Cleaned Rooms</h6>
                    <h2 id="not-cleaned-rooms">0</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-white bg-danger h-100">
                <div class="card-body d-flex flex-column align-items-center justify-content-center">
                    <h6 class="card-title">Failed Inspections</h6>
                    <h2 id="failed-inspections">0</h2>
                </div>
            </div>
        </div>
    </div>

    {* ===== SOP Management ===== *}
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0">SOP Management</h5>
            <div>
              <button id="btn-add-sop" class="btn btn-primary btn-sm">Add SOP</button>
              <button id="btn-reset-data" class="btn btn-outline-secondary btn-sm">Reset Demo Data</button>
            </div>
        </div>
        <div class="card-body">
            <div id="sop-form-container" class="mb-4" style="display:none;">
                {include file="modules/housekeepingexecutive/views/templates/admin/partials/sop_form.tpl"}
            </div>

            <div id="sop-table-container">
                {include file="modules/housekeepingexecutive/views/templates/admin/partials/sop_table.tpl"}
            </div>
        </div>
    </div>

    {* ===== Room Status ===== *}
    <div class="card">
        <div class="card-header">
            <ul class="nav nav-tabs card-header-tabs" id="room-status-tabs">
                <li class="nav-item">
                    <a class="nav-link active" data-status="all" href="#">All Rooms</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-status="cleaned" href="#">Cleaned</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-status="not_cleaned" href="#">Not Cleaned</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-status="failed" href="#">Failed Inspections</a>
                </li>
            </ul>
        </div>
        <div class="card-body" id="room-table-container">
            {include file="modules/housekeepingexecutive/views/templates/admin/partials/room_table.tpl"}
        </div>
    </div>

</div>

{* Include CSS & JS assets for frontend-only demo *}
<link rel="stylesheet" href="modules/housekeepingexecutive/views/css/housekeepingexecutive.css">
<script src="modules/housekeepingexecutive/views/js/housekeepingexecutive.js"></script>
