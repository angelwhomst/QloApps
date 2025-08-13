<div class="panel">
    <div class="panel-heading">
        <i class="icon-file-text"></i> {$sop.title|escape:'html':'UTF-8'}
    </div>
    
    <div class="row">
        <div class="col-md-8">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-info-circle"></i> {l s='SOP Details' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <h4>{l s='Description' mod='housekeepingmanagement'}</h4>
                            <div class="well">
                                {$sop.description}
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-12">
                            <h4>{l s='Steps' mod='housekeepingmanagement'}</h4>
                            <ol class="list-group">
                                {foreach from=$steps item=step}
                                    <li class="list-group-item">{$step.step_description|escape:'html':'UTF-8'}</li>
                                {/foreach}
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="panel">
                <div class="panel-heading">
                    <i class="icon-info-circle"></i> {l s='Additional Information' mod='housekeepingmanagement'}
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Room Type:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong>{$sop.room_type|escape:'html':'UTF-8'}</strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Status:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6">
                            {if $sop.active}
                                <span class="label label-success">{l s='Active' mod='housekeepingmanagement'}</span>
                            {else}
                                <span class="label label-danger">{l s='Inactive' mod='housekeepingmanagement'}</span>
                            {/if}
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Created by:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong>
                            {if isset($employee_name) && $employee_name}
                                {$employee_name|escape:'html':'UTF-8'}
                            {else}
                                {l s='N/A' mod='housekeepingmanagement'}
                            {/if}
                        </strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Created:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong>{$sop.date_add|date_format:'%Y-%m-%d %H:%M:%S'}</strong></div>
                    </div>
                    <div class="row">
                        <div class="col-xs-6 text-right">{l s='Last updated:' mod='housekeepingmanagement'}</div>
                        <div class="col-xs-6"><strong>{$sop.date_upd|date_format:'%Y-%m-%d %H:%M:%S'}</strong></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="panel-footer">
        <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}" class="btn btn-default">
            <i class="process-icon-back"></i> {l s='Back to list' mod='housekeepingmanagement'}
        </a>
        <a href="{$link->getAdminLink('AdminSOPManagement')|escape:'html':'UTF-8'}&id_sop={$sop.id_sop}&updateSOPModel" class="btn btn-default">
            <i class="process-icon-edit"></i> {l s='Edit' mod='housekeepingmanagement'}
        </a>
    </div>
</div>