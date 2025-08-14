<div class="panel sop-panel">
    <div class="panel-heading">
        <i class="fas fa-file-alt"></i> {$sop.title|escape:'html':'UTF-8'}
    </div>
    
    <div class="row">
        <div class="col-md-8">
            <div class="panel sop-panel sop-details-panel">
                <div class="panel-heading">
                    <i class="fas fa-info-circle"></i> {l s='SOP Details' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <h4><i class="fas fa-align-left text-muted"></i> {l s='Description' mod='housekeepingmanagement'}</h4>
                            <div class="well">
                                {$sop.description}
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-12">
                            <h4><i class="fas fa-tasks text-muted"></i> {l s='Steps' mod='housekeepingmanagement'}</h4>
                            <ul class="sop-steps-list">
                                {foreach from=$steps item=step}
                                    <li>{$step.step_description|escape:'html':'UTF-8'}</li>
                                {/foreach}
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="panel sop-panel">
                <div class="panel-heading">
                    <i class="fas fa-info-circle"></i> {l s='Additional Information' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="sop-info-row">
                        <div class="sop-info-label">{l s='Room Type:' mod='housekeepingmanagement'}</div>
                        <div class="sop-info-value">{$sop.room_type|escape:'html':'UTF-8'}</div>
                    </div>
                    <div class="sop-info-row">
                        <div class="sop-info-label">{l s='Status:' mod='housekeepingmanagement'}</div>
                        <div class="sop-info-value">
                            {if $sop.active}
                                <span class="sop-badge sop-badge-success">{l s='Active' mod='housekeepingmanagement'}</span>
                            {else}
                                <span class="sop-badge sop-badge-danger">{l s='Inactive' mod='housekeepingmanagement'}</span>
                            {/if}
                        </div>
                    </div>
                    <div class="sop-info-row">
                        <div class="sop-info-label">{l s='Created by:' mod='housekeepingmanagement'}</div>
                        <div class="sop-info-value">
                            {if isset($employee_name) && $employee_name}
                                <i class="fas fa-user text-muted"></i> {$employee_name|escape:'html':'UTF-8'}
                            {else}
                                {l s='N/A' mod='housekeepingmanagement'}
                            {/if}
                        </div>
                    </div>
                    <div class="sop-info-row">
                        <div class="sop-info-label">{l s='Created:' mod='housekeepingmanagement'}</div>
                        <div class="sop-info-value"><i class="fas fa-calendar text-muted"></i> {$sop.date_add|date_format:'%Y-%m-%d %H:%M:%S'}</div>
                    </div>
                    <div class="sop-info-row">
                        <div class="sop-info-label">{l s='Last updated:' mod='housekeepingmanagement'}</div>
                        <div class="sop-info-value"><i class="fas fa-clock text-muted"></i> {$sop.date_upd|date_format:'%Y-%m-%d %H:%M:%S'}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="panel-footer sop-footer">
        <div>
            <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}" class="btn btn-default">
                <i class="fas fa-arrow-left"></i> {l s='Back to list' mod='housekeepingmanagement'}
            </a>
        </div>
        <div>
            <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&updatehousekeeping_sop=1" class="btn btn-primary">
                <i class="fas fa-edit"></i> {l s='Edit' mod='housekeepingmanagement'}
            </a>
        </div>
    </div>
</div>

<script type="text/javascript">
{literal}
    $(document).ready(function() {
        // Animate steps on page load
        $('.sop-steps-list li').each(function(index) {
            $(this).css('opacity', 0);
            setTimeout(function(element) {
                $(element).animate({opacity: 1}, 300);
            }, 100 * index, this);
        });
    });
{/literal}
</script>