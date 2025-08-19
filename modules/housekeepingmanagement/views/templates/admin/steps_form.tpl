<div class="sop-steps-container">
    <div class="alert alert-info">
        <i class="fas fa-info-circle"></i> {l s='Add at least one step to your Standard Operating Procedure' mod='housekeepingmanagement'}
    </div>
    
    <div class="steps-container">
        {if isset($steps) && count($steps)}
            {foreach from=$steps item=step name=stepLoop}
                <div class="form-group step-row">
                    <!-- make input wider: col-lg-11, actions smaller: col-lg-1 -->
                    <div class="col-lg-11">
                        <div class="input-group">
                            <span class="input-group-addon">{$smarty.foreach.stepLoop.iteration}</span>
                            <input type="text" name="step[]" class="form-control step-input" value="{$step.step_description|escape:'html':'UTF-8'}" required="required" placeholder="{l s='Enter step description' mod='housekeepingmanagement'}" />
                        </div>
                    </div>
                    <div class="col-lg-1 step-actions">
                        <button type="button" class="btn btn-default move-step-up" title="{l s='Move Up' mod='housekeepingmanagement'}"><i class="fas fa-arrow-up"></i></button>
                        <button type="button" class="btn btn-default move-step-down" title="{l s='Move Down' mod='housekeepingmanagement'}"><i class="fas fa-arrow-down"></i></button>
                        <button type="button" class="btn btn-default remove-step" title="{l s='Remove Step' mod='housekeepingmanagement'}"><i class="fas fa-trash"></i></button>
                    </div>
                </div>
            {/foreach}
        {else}
            <div class="form-group step-row">
                <div class="col-lg-11">
                    <div class="input-group">
                        <span class="input-group-addon">1</span>
                        <input type="text" name="step[]" class="form-control step-input" required="required" placeholder="{l s='Enter step description' mod='housekeepingmanagement'}" />
                    </div>
                </div>
                <div class="col-lg-1 step-actions">
                    <button type="button" class="btn btn-default move-step-up" title="{l s='Move Up' mod='housekeepingmanagement'}"><i class="fas fa-arrow-up"></i></button>
                    <button type="button" class="btn btn-default move-step-down" title="{l s='Move Down' mod='housekeepingmanagement'}"><i class="fas fa-arrow-down"></i></button>
                    <button type="button" class="btn btn-default remove-step" title="{l s='Remove Step' mod='housekeepingmanagement'}"><i class="fas fa-trash"></i></button>
                </div>
            </div>
        {/if}
    </div>
    
    <div class="form-group">
        <div class="col-lg-12">
            <button type="button" class="btn add-step"><i class="fas fa-plus"></i> {l s='Add Step' mod='housekeepingmanagement'}</button>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function() {
        // Add new step
        $(document).on('click', '.add-step', function() {
            var stepsCount = $('.step-row').length;
            var newStepHtml = '<div class="form-group step-row">' +
                '<div class="col-lg-11">' +
                '<div class="input-group">' +
                '<span class="input-group-addon">' + (stepsCount + 1) + '</span>' +
                '<input type="text" name="step[]" class="form-control step-input" required="required" placeholder="{l s='Enter step description' mod='housekeepingmanagement'}" />' +
                '</div>' +
                '</div>' +
                '<div class="col-lg-1 step-actions">' +
                '<button type="button" class="btn btn-default move-step-up" title="{l s='Move Up' mod='housekeepingmanagement'}"><i class="fas fa-arrow-up"></i></button>' +
                '<button type="button" class="btn btn-default move-step-down" title="{l s='Move Down' mod='housekeepingmanagement'}"><i class="fas fa-arrow-down"></i></button>' +
                '<button type="button" class="btn btn-default remove-step" title="{l s='Remove Step' mod='housekeepingmanagement'}"><i class="fas fa-trash"></i></button>' +
                '</div>' +
                '</div>';
            $('.steps-container').append(newStepHtml);
            updateStepNumbers();
            
            // Animate scroll to new step
            $('html, body').animate({
                scrollTop: $('.step-row:last').offset().top - 100
            }, 300);
        });
        
        // Remove step
        $(document).on('click', '.remove-step', function() {
            if ($('.step-row').length > 1) {
                Swal.fire({
                    title: '{l s="Remove Step" mod="housekeepingmanagement" js=1}',
                    text: '{l s="Are you sure you want to remove this step?" mod="housekeepingmanagement" js=1}',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#E74C3C',
                    cancelButtonColor: '#7A7A7A',
                    confirmButtonText: '{l s="Yes, remove it" mod="housekeepingmanagement" js=1}',
                    cancelButtonText: '{l s="Cancel" mod="housekeepingmanagement" js=1}'
                }).then((result) => {
                    if (result.isConfirmed) {
                        $(this).closest('.step-row').fadeOut(300, function() {
                            $(this).remove();
                            updateStepNumbers();
                        });
                    }
                });
            } else {
                Swal.fire({
                    title: '{l s="Cannot Remove" mod="housekeepingmanagement" js=1}',
                    text: '{l s="At least one step is required" mod="housekeepingmanagement" js=1}',
                    icon: 'error',
                    confirmButtonColor: '#25B9D7'
                });
            }
        });
        
        // Move step up
        $(document).on('click', '.move-step-up', function() {
            var currentStep = $(this).closest('.step-row');
            var prevStep = currentStep.prev('.step-row');
            
            if (prevStep.length) {
                currentStep.fadeOut(100, function() {
                    currentStep.insertBefore(prevStep).fadeIn(100);
                    updateStepNumbers();
                });
            }
        });
        
        // Move step down
        $(document).on('click', '.move-step-down', function() {
            var currentStep = $(this).closest('.step-row');
            var nextStep = currentStep.next('.step-row');
            
            if (nextStep.length) {
                currentStep.fadeOut(100, function() {
                    currentStep.insertAfter(nextStep).fadeIn(100);
                    updateStepNumbers();
                });
            }
        });
        
        // Form validation
        $('form#housekeeping_sop_form').on('submit', function(e) {
            var emptySteps = 0;
            $('.step-input').each(function() {
                if ($(this).val().trim() === '') {
                    emptySteps++;
                    $(this).addClass('border-danger');
                } else {
                    $(this).removeClass('border-danger');
                }
            });
            
            if (emptySteps > 0) {
                e.preventDefault();
                Swal.fire({
                    title: '{l s="Form Error" mod="housekeepingmanagement" js=1}',
                    text: '{l s="All steps must have a description" mod="housekeepingmanagement" js=1}',
                    icon: 'error',
                    confirmButtonColor: '#25B9D7',
                    width: '400px'
                });
                return false;
            }
            
            return true;
        });
        
        // Update step numbers
        function updateStepNumbers() {
            $('.step-row').each(function(index) {
                $(this).find('.input-group-addon').text(index + 1);
            });
        }
    });
</script>