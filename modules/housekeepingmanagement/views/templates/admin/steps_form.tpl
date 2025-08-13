<?php
<div class="sop-steps-container">
    <div class="alert alert-info">
        {l s='Add at least one step to your Standard Operating Procedure' mod='housekeepingmanagement'}
    </div>
    
    <div class="steps-container">
        {if isset($steps) && count($steps)}
            {foreach from=$steps item=step name=stepLoop}
                <div class="form-group step-row">
                    <div class="col-lg-10">
                        <div class="input-group">
                            <span class="input-group-addon">{$smarty.foreach.stepLoop.iteration}</span>
                            <input type="text" name="step[]" class="form-control step-input" value="{$step.step_description|escape:'html':'UTF-8'}" required="required" />
                        </div>
                    </div>
                    <div class="col-lg-2">
                        <button type="button" class="btn btn-default remove-step"><i class="icon-trash"></i></button>
                        <button type="button" class="btn btn-default move-step-up"><i class="icon-chevron-up"></i></button>
                        <button type="button" class="btn btn-default move-step-down"><i class="icon-chevron-down"></i></button>
                    </div>
                </div>
            {/foreach}
        {else}
            <div class="form-group step-row">
                <div class="col-lg-10">
                    <div class="input-group">
                        <span class="input-group-addon">1</span>
                        <input type="text" name="step[]" class="form-control step-input" required="required" />
                    </div>
                </div>
                <div class="col-lg-2">
                    <button type="button" class="btn btn-default remove-step"><i class="icon-trash"></i></button>
                    <button type="button" class="btn btn-default move-step-up"><i class="icon-chevron-up"></i></button>
                    <button type="button" class="btn btn-default move-step-down"><i class="icon-chevron-down"></i></button>
                </div>
            </div>
        {/if}
    </div>
    
    <div class="form-group">
        <div class="col-lg-12">
            <button type="button" class="btn btn-default add-step"><i class="icon-plus"></i> {l s='Add Step' mod='housekeepingmanagement'}</button>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        // Add new step
        $(document).on('click', '.add-step', function() {
            var stepsCount = $('.step-row').length;
            var newStepHtml = '<div class="form-group step-row">' +
                '<div class="col-lg-10">' +
                '<div class="input-group">' +
                '<span class="input-group-addon">' + (stepsCount + 1) + '</span>' +
                '<input type="text" name="step[]" class="form-control step-input" required="required" />' +
                '</div>' +
                '</div>' +
                '<div class="col-lg-2">' +
                '<button type="button" class="btn btn-default remove-step"><i class="icon-trash"></i></button>' +
                '<button type="button" class="btn btn-default move-step-up"><i class="icon-chevron-up"></i></button>' +
                '<button type="button" class="btn btn-default move-step-down"><i class="icon-chevron-down"></i></button>' +
                '</div>' +
                '</div>';
            $('.steps-container').append(newStepHtml);
            updateStepNumbers();
        });
        
        // Remove step
        $(document).on('click', '.remove-step', function() {
            if ($('.step-row').length > 1) {
                $(this).closest('.step-row').remove();
                updateStepNumbers();
            } else {
                alert('{l s="At least one step is required" mod="housekeepingmanagement" js=1}');
            }
        });
        
        // Move step up
        $(document).on('click', '.move-step-up', function() {
            var currentStep = $(this).closest('.step-row');
            var prevStep = currentStep.prev('.step-row');
            
            if (prevStep.length) {
                currentStep.insertBefore(prevStep);
                updateStepNumbers();
            }
        });
        
        // Move step down
        $(document).on('click', '.move-step-down', function() {
            var currentStep = $(this).closest('.step-row');
            var nextStep = currentStep.next('.step-row');
            
            if (nextStep.length) {
                currentStep.insertAfter(nextStep);
                updateStepNumbers();
            }
        });
        
        // Update step numbers
        function updateStepNumbers() {
            $('.step-row').each(function(index) {
                $(this).find('.input-group-addon').text(index + 1);
            });
        }
    });
</script>