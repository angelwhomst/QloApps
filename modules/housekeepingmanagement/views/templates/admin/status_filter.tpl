<div class="panel">
    <div class="panel-heading">
        <i class="icon-filter"></i> {l s='Room Status Filter' mod='housekeepingmanagement'}
    </div>
    <div class="row">
        <div class="col-md-12">
            <ul class="nav nav-pills">
                <li class="active">
                    <a href="{$current_url|escape:'html':'UTF-8'}">
                        <i class="icon-list"></i> {l s='All Rooms' mod='housekeepingmanagement'} 
                        <span class="badge">{$status_counts.total}</span>
                    </a>
                </li>
                <li>
                    <a href="{$current_url|escape:'html':'UTF-8'}&status={$status_cleaned|escape:'html':'UTF-8'}" class="text-success">
                        <i class="icon-check"></i> {l s='Cleaned' mod='housekeepingmanagement'} 
                        <span class="badge">{$status_counts.cleaned}</span>
                    </a>
                </li>
                <li>
                    <a href="{$current_url|escape:'html':'UTF-8'}&status={$status_not_cleaned|escape:'html':'UTF-8'}" class="text-warning">
                        <i class="icon-times"></i> {l s='Not Cleaned' mod='housekeepingmanagement'} 
                        <span class="badge">{$status_counts.not_cleaned}</span>
                    </a>
                </li>
                <li>
                    <a href="{$current_url|escape:'html':'UTF-8'}&status={$status_failed|escape:'html':'UTF-8'}" class="text-danger">
                        <i class="icon-exclamation-triangle"></i> {l s='Failed Inspection' mod='housekeepingmanagement'} 
                        <span class="badge">{$status_counts.failed_inspection}</span>
                    </a>
                </li>
                <li>
                    <a href="{$current_url|escape:'html':'UTF-8'}&needs_attention=1" class="text-info">
                        <i class="icon-bell"></i> {l s='Needs Attention' mod='housekeepingmanagement'}
                    </a>
                </li>
            </ul>
        </div>
    </div>
</div>