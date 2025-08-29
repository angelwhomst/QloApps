<div class="housekeeping-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7;">
    <style>
        /* Base table styles from inspection_dashboard */
        table.sop-table { 
            width: 100%; 
            border-collapse: collapse; 
            background: #fff; 
            border-radius: 8px; 
            overflow: hidden; 
            table-layout: fixed; 
            margin-bottom: 0;
        }
        .sop-table th, .sop-table td { 
            padding: 12px; 
            border-bottom: 1px solid #eee; 
            text-align: left; 
            word-wrap: break-word; 
            vertical-align: middle;
        }
        .sop-table thead { 
            background: #f9f9f9; 
        }
        .sop-table th { 
            font-weight: 600; 
            color: #555; 
        }
        .sop-table tbody tr:hover { 
            background: #f4f8ff; 
        }

        /* Action buttons from supervisor_tasks */
        .action-buttons {
            display: flex;
            gap: 5px;
            justify-content: flex-start;
        }
        .btn-action {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            padding: 6px 8px;
            cursor: pointer;
            font-size: 12px;
            color: #495057;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .btn-action:hover {
            background: #e9ecef;
            transform: translateY(-1px);
        }
        .btn-action i {
            margin-right: 3px;
        }
        .btn-action:hover {
            text-decoration: none;
        }
        .btn-action.view-btn:hover { color: #007bff; border-color: #007bff; }
        .btn-action.edit-btn:hover { color: #28a745; border-color: #28a745; }
        .btn-action.delete-btn:hover { color: #dc3545; border-color: #dc3545; }

        /* Status badges */
        .badge {
            display: inline-block;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 600;
            border-radius: 12px;
        }
        .badge-success {
            background: #41C588;
            color: #fff;
        }
        .badge-danger {
            background: #F36960;
            color: #fff;
        }

        /* Summary cards from supervisor_tasks */
        .summary-cards {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        .summary-cards .card {
            flex: 1;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        /* Filter panel styling */
        .filter-panel {
            background: #ffffff;
            margin-bottom: 20px;
            border-radius: 8px;
            border: 1px solid #e3e3e3;
            box-shadow: 0 1px 5px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        #filterCollapse {
            padding: 15px 15px 10px;
        }
        .filter-row {
            margin-bottom: 10px;
        }
        .filter-panel .form-control {
            height: 34px;
            border-color: #ddd;
            box-shadow: none;
        }
        .filter-actions {
            border-top: 1px solid #eee;
            padding-top: 10px;
            margin-top: 10px;
        }

        /* Add SOP button */
        .btn-add-sop {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .btn-add-sop i {
            margin-right: 6px;
        }
        .btn-add-sop:hover {
            background: linear-gradient(135deg, #138496 0%, #117a8b 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
            color: white;
            text-decoration: none;
        }
        .btn-add-sop,
        .btn-add-sop:visited,
        .btn-add-sop:active {
            color: #fff !important;
            text-decoration: none !important;
        }
        .btn-add-sop i {
            color: #fff !important;
        }
        .btn-add-sop:hover, .btn-add-sop:focus {
            color: #fff !important;
        }

        /* Filter toggle button */
        .btn-filter-toggle {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            color: #495057;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 13px;
            margin-right: 8px;
            display: flex;
            align-items: center;
        }
        .btn-filter-toggle i {
            margin-right: 6px;
        }
        .btn-filter-toggle:hover {
            background: #e9ecef;
        }

        /* Export button */
        .btn-export {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            color: #495057;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 13px;
            display: flex;
            align-items: center;
        }
        .btn-export i {
            margin-right: 6px;
        }
        .btn-export:hover {
            background: #e9ecef;
        }

        /* Pagination styling */
        .pagination-container {
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .pagination {
            display: flex;
            gap: 5px;
        }
        .pagination-btn {
            min-width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: white;
            border: 1px solid #ddd;
            color: #666;
            font-weight: 600;
            border-radius: 4px;
            text-decoration: none;
        }
        .pagination-btn:hover {
            background: #f8f8f8;
            border-color: #17a2b8;
            color: #17a2b8;
            text-decoration: none;
        }
        .pagination-btn.active {
            background: #17a2b8;
            border-color: #17a2b8;
            color: white;
        }
        .pagination-info {
            color: #777;
            font-size: 13px;
        }
        .pagination-info .text-info {
            color: #17a2b8;
            font-weight: 600;
        }

        /* Alert message */
        .alert-warning {
            background: #fffbe6;
            color: #856404;
            border: 1px solid #ffeeba;
            border-radius: 6px;
            padding: 16px;
            margin: 20px 0;
            font-size: 14px;
        }

        /* Media queries */
        @media (max-width: 992px) {
            .filter-row {
                flex-direction: column;
            }
            .filter-row > div {
                width: 100%;
                margin-bottom: 10px;
            }
        }
        @media (max-width: 768px) {
            .summary-cards {
                flex-direction: column;
            }
            .summary-cards .card {
                margin-bottom: 10px;
            }
            .pagination-container {
                flex-direction: column;
                gap: 10px;
            }
            .pagination, .pagination-info {
                justify-content: center;
                text-align: center;
            }
        }
    </style>

    <!-- Header and Add SOP button -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h2 style="margin: 0; font-size: 24px; color: #333;">
            <i class="icon-list-alt"></i> {l s='Standard Operating Procedures' mod='housekeepingmanagement'}
            <span class="badge" style="background: #17a2b8; color: white; font-size: 14px; vertical-align: middle; border-radius: 12px; padding: 3px 8px;">{$sops|@count}</span>
        </h2>
        <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&addhousekeeping_sop" class="btn-add-sop">
            <i class="icon-plus-circle"></i> {l s='Add New SOP' mod='housekeepingmanagement'}
        </a>
    </div>

    <!-- Summary Cards (Similar to supervisor_tasks) -->
    <div class="summary-cards">
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Total SOPs' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">{$sops|@count}</div>
            </div>
            <i class="icon-list-alt" style="font-size: 32px; color: #17a2b8; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Active SOPs' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">
                    {assign var=activeCount value=0}
                    {foreach from=$sops item=sop}
                        {if $sop.active}{assign var=activeCount value=$activeCount+1}{/if}
                    {/foreach}
                    {$activeCount}
                </div>
            </div>
            <i class="icon-check-circle" style="font-size: 32px; color: #41C588; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Inactive SOPs' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">
                    {assign var=inactiveCount value=0}
                    {foreach from=$sops item=sop}
                        {if !$sop.active}{assign var=inactiveCount value=$inactiveCount+1}{/if}
                    {/foreach}
                    {$inactiveCount}
                </div>
            </div>
            <i class="icon-ban-circle" style="font-size: 32px; color: #F36960; margin-left: 15px;"></i>
        </div>
        <div class="card">
            <div>
                <div style="font-size: 14px; color: #666;">{l s='Total Steps' mod='housekeepingmanagement'}</div>
                <div style="font-size: 28px; font-weight: bold;">
                    {assign var=totalSteps value=0}
                    {foreach from=$sops item=sop}
                        {assign var=totalSteps value=$totalSteps+$sop.steps_count}
                    {/foreach}
                    {$totalSteps}
                </div>
            </div>
            <i class="icon-tasks" style="font-size: 32px; color: #F5A623; margin-left: 15px;"></i>
        </div>
    </div>

    <!-- Filters and Export buttons -->
    <div style="display: flex; justify-content: flex-end; margin-bottom: 15px; gap: 10px;">
        <button type="button" class="btn-filter-toggle" data-toggle="collapse" data-target="#filterCollapse" aria-expanded="false">
            <i class="icon-filter"></i> {l s='Filters' mod='housekeepingmanagement'}
        </button>
        <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&exporthousekeeping_sop=1&token={$token}" class="btn-export btn-export-sop">
            <i class="icon-download"></i> {l s='Export' mod='housekeepingmanagement'}
        </a>
    </div>

    <!-- Filter Panel (preserving original functionality) -->
    <div class="filter-panel">
        <div id="filterCollapse" class="collapse">
            <form id="sop_filter_form" method="post">
                <div class="row filter-row">
                    <div class="col-sm-3">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="icon-file-text"></i></span>
                                <input type="text" name="title_filter" value="{if isset($title_filter)}{$title_filter}{/if}" class="filter form-control" placeholder="{l s='Title' mod='housekeepingmanagement'}">
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-sm-3">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="icon-home"></i></span>
                                <select name="room_type_filter" class="filter form-control">
                                    <option value="">{l s='All Room Types' mod='housekeepingmanagement'}</option>
                                    {foreach from=$room_types item=room_type}
                                        <option value="{$room_type.id_option}" {if isset($room_type_filter) && $room_type_filter == $room_type.id_option}selected="selected"{/if}>{$room_type.name}</option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-sm-3">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="icon-check"></i></span>
                                <select name="active_filter" class="filter form-control">
                                    <option value="">{l s='All Status' mod='housekeepingmanagement'}</option>
                                    <option value="1" {if isset($active_filter) && $active_filter == '1'}selected="selected"{/if}>{l s='Active' mod='housekeepingmanagement'}</option>
                                    <option value="0" {if isset($active_filter) && $active_filter == '0'}selected="selected"{/if}>{l s='Inactive' mod='housekeepingmanagement'}</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-sm-3">
                        <div class="form-group">
                            <button type="button"
                                class="btn btn-default date-filter-toggle"
                                title="{l s='Toggle date range' mod='housekeepingmanagement'}"
                                style="width:100%; display:flex; flex-direction:row; justify-content:flex-start; align-items:center; text-align:left;">
                                <i class="icon-calendar" style="margin-right:10px"></i>
                                <span>{l s='Date Range' mod='housekeepingmanagement'}</span>
                            </button>
                        </div>
                    </div>
                </div>
                
                <div class="row date-filter-row" style="display:none;">
                    <div class="col-sm-5">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="icon-calendar"></i></span>
                                <input type="date" name="date_from" value="{if isset($date_from)}{$date_from}{/if}" class="filter form-control" placeholder="{l s='From' mod='housekeepingmanagement'}">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-5">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon"><i class="icon-calendar"></i></span>
                                <input type="date" name="date_to" value="{if isset($date_to)}{$date_to}{/if}" class="filter form-control" placeholder="{l s='To' mod='housekeepingmanagement'}">
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-2">
                        <button type="button" class="btn btn-default btn-block toggle-date-filter">
                            <i class="icon-close"></i> {l s='Hide' mod='housekeepingmanagement'}
                        </button>
                    </div>
                </div>
                
                <div class="row filter-actions">
                    <div class="col-sm-12">
                        <div class="btn-group pull-right">
                            <button type="submit" id="submitFilterButtonSOP" name="submitFilterButtonSOP" class="btn btn-primary">
                                <i class="icon-search"></i> {l s='Search' mod='housekeepingmanagement'}
                            </button>
                            <button type="button" class="btn btn-default" id="resetFilter">
                                <i class="icon-refresh"></i> {l s='Reset' mod='housekeepingmanagement'}
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Hidden reset button for form submission -->
                <input type="submit" name="submitResetSOP" id="submitResetSOP" class="hidden" />
            </form>
        </div>
    </div>
    
    <!-- Table with SOPs data -->
    <div class="table-responsive-row clearfix">
        <table class="sop-table">
            <thead>
                <tr>
                    <th style="width: 5%;"><span>#</span></th>
                    <th style="width: 25%;"><span>{l s='Title' mod='housekeepingmanagement'}</span></th>
                    <th style="width: 18%;"><span>{l s='Room Type' mod='housekeepingmanagement'}</span></th>
                    <th class="text-center" style="width: 10%;"><span>{l s='Steps' mod='housekeepingmanagement'}</span></th>
                    <th class="text-center" style="width: 12%;"><span>{l s='Status' mod='housekeepingmanagement'}</span></th>
                    <th style="width: 15%;"><span>{l s='Last Updated' mod='housekeepingmanagement'}</span></th>
                    <th style="width: 15%;"><span>{l s='Actions' mod='housekeepingmanagement'}</span></th>
                </tr>
            </thead>
            <tbody>
                {if $sops|@count > 0}
                    {foreach from=$sops item=sop name=sopLoop}
                        <tr class="list-sop-item">
                            <td>{$smarty.foreach.sopLoop.iteration}</td>
                            <td>
                                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop&token={$token}" style="font-weight:600; color:#333; text-decoration:none;">
                                    {$sop.title|escape:'html':'UTF-8'}
                                </a>
                            </td>
                            <td>{$sop.room_type_name|escape:'html':'UTF-8'}</td>
                            <td class="text-center">{$sop.steps_count}</td>
                            <td class="text-center">
                                {if $sop.active}
                                    <span class="badge badge-success">{l s='Active' mod='housekeepingmanagement'}</span>
                                {else}
                                    <span class="badge badge-danger">{l s='Inactive' mod='housekeepingmanagement'}</span>
                                {/if}
                            </td>
                            <td>
                                <i class="icon-calendar" style="color: #888; margin-right: 4px;"></i> {$sop.date_upd|date_format:'%Y-%m-%d'}
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop&token={$token}" class="btn-action view-btn" title="{l s='View' mod='housekeepingmanagement'}">
                                        <i class="icon-eye"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&updatehousekeeping_sop=1&token={$token}" class="btn-action edit-btn" title="{l s='Edit' mod='housekeepingmanagement'}">
                                        <i class="icon-pencil"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&deletehousekeeping_sop=1&token={$token}" class="btn-action delete-btn" title="{l s='Delete' mod='housekeepingmanagement'}">
                                        <i class="icon-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                {else}
                    <tr>
                        <td colspan="7">
                            <div class="alert alert-warning">
                                <i class="icon-warning-sign"></i> {l s='No SOPs found. Create your first SOP!' mod='housekeepingmanagement'}
                            </div>
                        </td>
                    </tr>
                {/if}
            </tbody>
        </table>
    </div>
    
    <!-- Pagination (preserving original functionality) -->
    {if $pagination_pages > 1}
    <div class="pagination-container">
        <div class="pagination">
            {if $pagination_page > 1}
                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page-1}&token={$token}" class="pagination-btn">
                    <i class="icon-chevron-left"></i>
                </a>
            {/if}
            {for $p=1 to $pagination_pages}
                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$p}&token={$token}" class="pagination-btn {if $p == $pagination_page}active{/if}">{$p}</a>
            {/for}
            {if $pagination_page < $pagination_pages}
                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page+1}&token={$token}" class="pagination-btn">
                    <i class="icon-chevron-right"></i>
                </a>
            {/if}
        </div>
        <div class="pagination-info">
            {l s='Displaying' mod='housekeepingmanagement'} 
            <span class="text-info">{(($pagination_page-1)*$pagination_limit)+1}</span> - 
            <span class="text-info">{if $pagination_page*$pagination_limit > $pagination_total}{$pagination_total}{else}{$pagination_page*$pagination_limit}{/if}</span> 
            {l s='of' mod='housekeepingmanagement'} <span class="text-info">{$pagination_total}</span> {l s='items' mod='housekeepingmanagement'}
        </div>
    </div>
    {/if}

    <!-- External dependencies -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Date filter toggle
        const dateFilterToggle = document.querySelector('.date-filter-toggle');
        const dateFilterRow = document.querySelector('.date-filter-row');
        const toggleDateFilter = document.querySelector('.toggle-date-filter');
        
        if (dateFilterToggle && dateFilterRow) {
            dateFilterToggle.addEventListener('click', function() {
                dateFilterRow.style.display = dateFilterRow.style.display === 'none' ? 'block' : 'none';
            });
        }
        
        if (toggleDateFilter && dateFilterRow) {
            toggleDateFilter.addEventListener('click', function() {
                dateFilterRow.style.display = 'none';
            });
        }
        
        // Reset filter button
        const resetBtn = document.getElementById('resetFilter');
        const submitResetBtn = document.getElementById('submitResetSOP');
        
        if (resetBtn && submitResetBtn) {
            resetBtn.addEventListener('click', function() {
                submitResetBtn.click();
            });
        }
        
        // Export SOP confirmation
        const exportBtn = document.querySelector('.btn-export-sop');
        
        if (exportBtn) {
            exportBtn.addEventListener('click', function(e) {
                e.preventDefault();
                const exportUrl = this.getAttribute('href');
                
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        title: 'Export SOP Data?',
                        text: 'Are you sure you want to export the SOP data?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonText: 'Yes, export',
                        cancelButtonText: 'Cancel',
                        confirmButtonColor: '#17a2b8',
                        width: '400px'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.href = exportUrl;
                        }
                    });
                } else {
                    if (confirm('Are you sure you want to export the SOP data?')) {
                        window.location.href = exportUrl;
                    }
                }
            });
        }
        
        // Delete SOP confirmation
        const deleteButtons = document.querySelectorAll('.btn-delete-sop');
        
        deleteButtons.forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const deleteUrl = this.getAttribute('href');
                
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        title: 'Delete SOP?',
                        text: 'Are you sure you want to delete this SOP? This action cannot be undone.',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonText: 'Yes, delete it',
                        cancelButtonText: 'Cancel',
                        confirmButtonColor: '#dc3545',
                        width: '400px'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.href = deleteUrl;
                        }
                    });
                } else {
                    if (confirm('Are you sure you want to delete this SOP? This action cannot be undone.')) {
                        window.location.href = deleteUrl;
                    }
                }
            });
        });
    });
    </script>
</div>