<div class="panel sop-panel">
    <div class="panel-heading">
        <i class="fas fa-list"></i> {l s='Standard Operating Procedures' mod='housekeepingmanagement'}
        <span class="badge">{$sops|@count}</span>
        <div class="panel-heading-action">
            <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&addhousekeeping_sop" class="btn btn-primary btn-sm">
                <i class="fas fa-plus"></i> {l s='Add New SOP' mod='housekeepingmanagement'}
            </a>
            <!-- Export CSV button -->
            <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&exporthousekeeping_sop=1&token={$token}" class="btn btn-outline-secondary btn-sm" style="margin-left:8px;">
                <i class="fas fa-file-export"></i> {l s='Export' mod='housekeepingmanagement'}
            </a>
        </div>
    </div>
    
    <!-- Filter Form -->
    <div class="filter-panel">
        <form id="sop_filter_form" method="post" class="form-horizontal">
            <div class="row">
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='ID' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <input type="text" name="id_sop_filter" value="{if isset($id_sop_filter)}{$id_sop_filter}{/if}" class="filter form-control">
                        </div>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='Title' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <input type="text" name="title_filter" value="{if isset($title_filter)}{$title_filter}{/if}" class="filter form-control">
                        </div>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='Room Type' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <select name="room_type_filter" class="filter form-control">
                                <option value="">{l s='All' mod='housekeepingmanagement'}</option>
                                {foreach from=$room_types item=room_type}
                                    <option value="{$room_type.id_option}" {if isset($room_type_filter) && $room_type_filter == $room_type.id_option}selected="selected"{/if}>{$room_type.name}</option>
                                {/foreach}
                            </select>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='Status' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <select name="active_filter" class="filter form-control">
                                <option value="">{l s='All' mod='housekeepingmanagement'}</option>
                                <option value="1" {if isset($active_filter) && $active_filter == '1'}selected="selected"{/if}>{l s='Active' mod='housekeepingmanagement'}</option>
                                <option value="0" {if isset($active_filter) && $active_filter == '0'}selected="selected"{/if}>{l s='Inactive' mod='housekeepingmanagement'}</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row" style="margin-top:10px;">
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='From' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <input type="date" name="date_from" value="{if isset($date_from)}{$date_from}{/if}" class="filter form-control">
                        </div>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="form-group">
                        <label class="control-label col-lg-4">{l s='To' mod='housekeepingmanagement'}</label>
                        <div class="col-lg-8">
                            <input type="date" name="date_to" value="{if isset($date_to)}{$date_to}{/if}" class="filter form-control">
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="form-group filter-actions" style="text-align:right;">
                        <button type="submit" id="submitFilterButtonSOP" name="submitFilterButtonSOP" class="btn btn-primary">
                            <i class="fas fa-filter"></i> {l s='Filter' mod='housekeepingmanagement'}
                        </button>
                        <button type="submit" name="submitResetSOP" class="btn btn-default">
                            <i class="fas fa-undo"></i> {l s='Reset' mod='housekeepingmanagement'}
                        </button>
                    </div>
                </div>
            </div>
        </form>
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
                            <td>{$sop.id_sop}</td>
                            <td>
                                <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop">
                                    <strong>{$sop.title|escape:'html':'UTF-8'}</strong>
                                </a>
                            </td>
                            <td>{$sop.room_type_name|escape:'html':'UTF-8'}</td>
                            <td class="text-center">{$sop.steps_count}</td>
                            <td class="text-center">
                                {if $sop.active}
                                    <span class="sop-badge sop-badge-success">{l s='Active' mod='housekeepingmanagement'}</span>
                                {else}
                                    <span class="sop-badge sop-badge-danger">{l s='Inactive' mod='housekeepingmanagement'}</span>
                                {/if}
                            </td>
                            <td>
                                <i class="fas fa-clock text-muted"></i> {$sop.date_upd|date_format:'%Y-%m-%d'}
                            </td>
                            <td class="text-right">
                                <div class="btn-group">
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&viewhousekeeping_sop" class="btn btn-default btn-sm" title="{l s='View' mod='housekeepingmanagement'}">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&updatehousekeeping_sop=1" class="btn btn-default btn-sm" title="{l s='Edit' mod='housekeepingmanagement'}">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&deletehousekeeping_sop" class="btn btn-default btn-sm btn-delete-sop" title="{l s='Delete' mod='housekeepingmanagement'}">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    {/foreach}
                {else}
                    <tr>
                        <td colspan="7" class="text-center">
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle"></i> {l s='No SOPs found. Create your first SOP!' mod='housekeepingmanagement'}
                            </div>
                        </td>
                    </tr>
                {/if}
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    {if $pagination_total > $pagination_limit}
    <div class="row">
        <div class="col-lg-6">
            <div class="pagination">
                {if $pagination_page > 1}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page-1}" class="btn btn-default"><i class="fas fa-chevron-left"></i></a>
                {/if}
                {for $p=1 to $pagination_pages}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$p}" class="btn btn-default {if $p == $pagination_page}active{/if}">{$p}</a>
                {/for}
                {if $pagination_page < $pagination_pages}
                    <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&{$filter_params}&page={$pagination_page+1}" class="btn btn-default"><i class="fas fa-chevron-right"></i></a>
                {/if}
            </div>
        </div>
        <div class="col-lg-6 text-right">
            <div class="dataTables_paginate">
                {l s='Displaying' mod='housekeepingmanagement'} 
                <span class="text-info">{(($pagination_page-1)*$pagination_limit)+1}</span> - 
                <span class="text-info">{if $pagination_page*$pagination_limit > $pagination_total}{$pagination_total}{else}{$pagination_page*$pagination_limit}{/if}</span> 
                {l s='of' mod='housekeepingmanagement'} <span class="text-info">{$pagination_total}</span> {l s='items' mod='housekeepingmanagement'}
            </div>
        </div>
    </div>
    {/if}
</div>

<!-- CSS for filter section -->
<style>
.filter-panel {
    background: #f8f8f8;
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
    border: 1px solid #e7e7e7;
}

.filter-actions {
    text-align: right;
    padding-top: 10px;
    border-top: 1px solid #e7e7e7;
    margin-top: 10px;
}

.pagination {
    display: inline-block;
    margin: 20px 0;
}

.pagination .btn {
    margin-right: 5px;
}

.pagination .btn.active {
    background-color: #25B9D7;
    color: white;
    border-color: #25B9D7;
}

</style>