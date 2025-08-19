<div class="panel sop-panel">
    <div class="panel-heading" style="padding-bottom:25px;padding-top:25px;">
        <i class="icon-list-alt"></i> {l s='Standard Operating Procedures' mod='housekeepingmanagement'}
        <span class="badge">{$sops|@count}</span>
        <div class="panel-heading-action">
            <div class="btn-group">
                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&addhousekeeping_sop" class="btn btn-primary btn-add-sop" >
                    <i class="icon-plus-circle"></i> {l s='Add New SOP' mod='housekeepingmanagement'}
                </a>
            </div>
        </div>
    </div>

    <!-- Sub-header: Export + Filter -->
    <div class="panel-subheader" style="padding:10px 15px 0;border-bottom:1px solid #eee;background:#fff;">
        <div class="btn-group pull-right">
            <button type="button" class="btn btn-default" data-toggle="collapse" data-target="#filterCollapse" aria-expanded="false">
                <i class="icon-sliders"></i> {l s='Filters' mod='housekeepingmanagement'}
            </button>
            <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&exporthousekeeping_sop=1&token={$token}" class="btn btn-default btn-export-sop">
                <i class="icon-cloud-download"></i> {l s='Export' mod='housekeepingmanagement'}
            </a>
        </div>
        <div class="clearfix"></div>
    </div>
    
    <!-- Compact Filter Form -->
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
                    
                    <!-- All Status -->
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
                    
                    <!-- Date Range (compact) -->
                    <div class="col-sm-3">
                        <div class="form-group">
                            <button type="button"
                                class="btn btn-default date-filter-toggle"
                                title="{l s='Toggle date range' mod='housekeepingmanagement'}"
                                style="width:50%; display:flex; flex-direction:row; justify-content:flex-start; align-items:center; text-align:left;">
                                <i class="icon-calendar" style="margin-right:20px"></i>
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
    
    <div class="table-responsive">
        <table class="table sop-table">
            <thead>
                <tr>
                    <th><span>#</span></th>
                    <th><span>{l s='Title' mod='housekeepingmanagement'}</span></th>
                    <th><span>{l s='Room Type' mod='housekeepingmanagement'}</span></th>
                    <th class="text-center"><span>{l s='Steps' mod='housekeepingmanagement'}</span></th>
                    <th class="text-center"><span>{l s='Status' mod='housekeepingmanagement'}</span></th>
                    <th><span>{l s='Last Updated' mod='housekeepingmanagement'}</span></th>
                    <th class="text-right"><span>{l s='Actions' mod='housekeepingmanagement'}</span></th>
                </tr>
            </thead>
            <tbody>
                {if $sops|@count > 0}
                    {foreach from=$sops item=sop name=sopLoop}
                        <tr class="list-sop-item">
                            <td>{$smarty.foreach.sopLoop.iteration}</td>
                            <td>
                                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop&token={$token}">
                                    <strong>{$sop.title|escape:'html':'UTF-8'}</strong>
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
                                <i class="icon-calendar text-muted"></i> {$sop.date_upd|date_format:'%Y-%m-%d'}
                            </td>
                            <td class="text-right">
                                <div class="btn-group action-buttons">
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop&token={$token}" class="btn btn-default btn-action" title="{l s='View' mod='housekeepingmanagement'}">
                                        <i class="icon-eye"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&updatehousekeeping_sop=1&token={$token}" class="btn btn-default btn-action btn-edit-sop" title="{l s='Edit' mod='housekeepingmanagement'}">
                                        <i class="icon-pencil"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&deletehousekeeping_sop=1&token={$token}" class="btn btn-default btn-action btn-delete-sop" title="{l s='Delete' mod='housekeepingmanagement'}">
                                        <i class="icon-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                {else}
                    <tr>
                        <td colspan="7" class="text-center">
                            <div class="alert alert-warning">
                                <i class="icon-warning-sign"></i> {l s='No SOPs found. Create your first SOP!' mod='housekeepingmanagement'}
                            </div>
                        </td>
                    </tr>
                {/if}
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    {if $pagination_pages > 1}
    <div class="row pagination-container">
        <div class="col-lg-6">
            <div class="pagination">
                {if $pagination_page > 1}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page-1}&token={$token}" class="btn btn-default pagination-btn">
                        <i class="icon-chevron-left"></i>
                    </a>
                {/if}
                {for $p=1 to $pagination_pages}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$p}&token={$token}" class="btn btn-default pagination-btn {if $p == $pagination_page}active{/if}">{$p}</a>
                {/for}
                {if $pagination_page < $pagination_pages}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page+1}&token={$token}" class="btn btn-default pagination-btn">
                        <i class="icon-chevron-right"></i>
                    </a>
                {/if}
            </div>
        </div>
        <div class="col-lg-6 text-right">
            <div class="pagination-info">
                {l s='Displaying' mod='housekeepingmanagement'} 
                <span class="text-info">{(($pagination_page-1)*$pagination_limit)+1}</span> - 
                <span class="text-info">{if $pagination_page*$pagination_limit > $pagination_total}{$pagination_total}{else}{$pagination_page*$pagination_limit}{/if}</span> 
                {l s='of' mod='housekeepingmanagement'} <span class="text-info">{$pagination_total}</span> {l s='items' mod='housekeepingmanagement'}
            </div>
        </div>
    </div>
    {/if}
</div>

<!-- CSS for styling -->
<style>
/* Panel heading */
.panel-heading-action .btn-group {
    display: flex;
}

.panel-heading-action .btn {
    margin-left: 5px;
}

/* Main panel spacing */
.panel.sop-panel {
    margin-left: 16px;
    margin-right: 16px;
}

/* Subheader styles (Export + Filter) */
.panel-subheader {
    display: block;
    
    padding-bottom: 6px;
}
.panel-subheader .btn {
    margin-left: 6px;
    margin-bottom: 10px;
}
.filter-panel {
    margin-top: 10px;
}

/* Modern Filter Panel */
.filter-panel {
    background: #ffffff;
    padding: 0;
    margin-bottom: 15px;
    border-radius: 4px;
    border: 1px solid #e3e3e3;
    box-shadow: 0 1px 5px rgba(0,0,0,0.05);
    overflow: hidden;
}

#filterCollapse {
    padding: 15px 15px 10px;
    border-bottom: 1px solid #eaeaea;
}

.filter-row {
    margin-bottom: 10px;
}

.filter-panel .form-control,
.filter-panel .input-group,
.filter-panel .dropdown-toggle {
    box-sizing: border-box;
}

.filter-panel .input-group-addon {
    background-color: #f7f7f7;
    border-color: #ddd;
    color: #777;
}

.filter-panel .form-control {
    height: 30px;
    border-color: #ddd;
    box-shadow: none;
    transition: border-color 0.15s ease-in-out;
}

.filter-panel .form-control:focus {
    border-color: #25B9D7;
    box-shadow: 0 0 0 2px rgba(37,185,215,0.1);
}

.filter-panel .form-group {
    margin-bottom: 8px;
}

.date-filter-row {
    border-top: 1px solid #eee;
    padding-top: 8px;
    margin-top: 5px;
    margin-bottom: 10px;
}

.quick-date-dropdown .dropdown-toggle {
    width: 100%;
    text-align: left;
}

.quick-date-dropdown .dropdown-menu {
    min-width: auto;
    width: 100%;
}

.filter-actions {
    border-top: 1px solid #eee;
    padding-top: 10px;
    margin-top: 5px;
}

/* Button styles */
.btn-add-sop {
    background: #25B9D7;
    border-color: #25B9D7;
    color: white;
    font-weight: 600;
    padding: 6px 15px;
    margin-right:20px;
    margin-top:7px;
    border-radius: 3px;
    box-shadow: 0 2px 6px rgba(37,185,215,0.15);
    transition: all 0.2s;
}

.btn-add-sop:hover, 
.btn-add-sop:focus {
    background: #1FA8C6;
    border-color: #1FA8C6;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(37,185,215,0.2);
    color: white;
}

.btn-add-sop i {
    margin-right: 5px;
}

/* Pagination */
.pagination-container {
    margin-top: 15px;
    padding-top: 10px;
    border-top: 1px solid #eaeaea;
}

.pagination {
    display: inline-flex;
    align-items: center;
}

.pagination-btn {
    min-width: 32px;
    height: 32px;
    padding: 0;
    margin: 0 2px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: white;
    border: 1px solid #ddd;
    color: #666;
    font-weight: 600;
    border-radius: 3px;
    transition: all 0.2s;
}

.pagination-btn:hover {
    background: #f8f8f8;
    border-color: #25B9D7;
    color: #25B9D7;
}

.pagination-btn.active {
    background: #25B9D7;
    border-color: #25B9D7;
    color: white;
}

.pagination-info {
    color: #777;
    padding-top: 8px;
    font-size: 13px;
}

.pagination-info .text-info {
    color: #25B9D7;
    font-weight: 600;
}

/* Media queries */
@media (max-width: 992px) {
    .filter-row {
        flex-direction: column;
    }
    
    .filter-row > div {
        width: 100%;
    }
    
    .filter-actions .btn-group {
        margin-bottom: 10px;
    }
}

@media (max-width: 768px) {
    .panel-heading-action .btn-group {
        flex-wrap: wrap;
    }
    
    .panel-heading-action .btn {
        margin-bottom: 5px;
    }
    
    .btn-add-sop {
        padding: 6px 12px;
    }
    
    .filter-panel .form-group {
        margin-bottom: 10px;
    }
    
    .action-buttons {
        justify-content: flex-end;
    }
    
    .pagination-container {
        flex-direction: column;
    }
    
    .pagination, .pagination-info {
        text-align: center;
        justify-content: center;
        margin: 10px 0;
    }
}
</style>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Use jQuery in noConflict mode for PrestaShop
    jQuery('.btn-export-sop').off('click').on('click', function(e) {
        e.preventDefault();
        var exportUrl = jQuery(this).attr('href');
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                title: 'Export SOP Data?',
                text: 'Are you sure you want to export the SOP data?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, export',
                cancelButtonText: 'Cancel',
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

    
});
</script>
<script src="{$module_dir}views/js/sop_list.js"></script>
