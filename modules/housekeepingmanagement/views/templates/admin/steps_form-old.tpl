<div class="panel">
    <div class="panel-heading">{l s='SOP Steps' mod='housekeepingmanagement'}</div>
    <div id="steps-list">
        {if isset($steps) && $steps|@count}
            {foreach from=$steps item=step name=stepLoop}
                <div class="form-group step-row">
                    <label>{l s='Step' mod='housekeepingmanagement'} {$smarty.foreach.stepLoop.iteration}</label>
                    <input type="text" name="step[]" class="form-control" value="{$step.step_description|escape:'html':'UTF-8'}" required />
                </div>
            {/foreach}
        {else}
            <div class="form-group step-row">
                <label>{l s='Step' mod='housekeepingmanagement'} 1</label>
                <input type="text" name="step[]" class="form-control" required />
            </div>
        {/if}
    </div>
    <button type="button" class="btn btn-default" id="add-step">{l s='Add Step' mod='housekeepingmanagement'}</button>
</div>
<script>
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('add-step').onclick = function() {
        var stepsList = document.getElementById('steps-list');
        var count = stepsList.querySelectorAll('.step-row').length + 1;
        var div = document.createElement('div');
        div.className = 'form-group step-row';
        div.innerHTML = '<label>Step ' + count + '</label><input type="text" name="step[]" class="form-control" required />';
        stepsList.appendChild(div);
    };
});
</script>