<div class="form-group">
    <label class="control-label col-lg-3">
        {l s='Steps' mod='housekeepingmanagement'} <span class="required">*</span>
    </label>
    <div class="col-lg-9">
        <div id="steps-container">
            {foreach from=$steps item=step}
                <div class="step-row form-group">
                    <div class="col-lg-1">
                        <span class="step-number">{$step.step_order}</span>
                    </div>
                    <div class="col-lg-9">
                        <textarea name="step[]" class="form-control" rows="2">{$step.step_description|escape:'html':'UTF-8'}</textarea>
                    </div>
                    <div class="col-lg-2">
                        <button type="button" class="btn btn-default remove-step">
                            <i class="icon-trash"></i> {l s='Remove' mod='housekeepingmanagement'}
                        </button>
                    </div>
                </div>
            {/foreach}
        </div>
        <div class="form-group">
            <div class="col-lg-12">
                <button type="button" id="add-step" class="btn btn-default">
                    <i class="icon-plus"></i> {l s='Add Step' mod='housekeepingmanagement'}
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        // Add new step
        $('#add-step').click(function() {
            var stepsCount = $('#steps-container .step-row').length;
            var newStep = '<div class="step-row form-group">' +
                '<div class="col-lg-1">' +
                '<span class="step-number">' + (stepsCount + 1) + '</span>' +
                '</div>' +
                '<div class="col-lg-9">' +
                '<textarea name="step[]" class="form-control" rows="2"></textarea>' +
                '</div>' +
                '<div class="col-lg-2">' +
                '<button type="button" class="btn btn-default remove-step">' +
                '<i class="icon-trash"></i> {l s='Remove' mod='housekeepingmanagement'}' +
                '</button>' +
                '</div>' +
                '</div>';
            
            $('#steps-container').append(newStep);
            updateStepNumbers();
        });
        
        // Remove step
        $(document).on('click', '.remove-step', function() {
            $(this).closest('.step-row').remove();
            updateStepNumbers();
        });
        
        // Update step numbers
        function updateStepNumbers() {
            $('#steps-container .step-row').each(function(index) {
                $(this).find('.step-number').text(index + 1);
            });
        }
    });
</script>