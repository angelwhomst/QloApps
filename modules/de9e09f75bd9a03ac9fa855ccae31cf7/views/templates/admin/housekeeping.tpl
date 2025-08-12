<div class="housekeeping-dashboard container-fluid">
  <h2>Housekeeping Management</h2>

  <!-- Summary cards -->
  <div id="hk-summary" class="row mb-3">
    {include file="module:housekeepingmanagement/views/templates/admin/_summary_cards.tpl"}
  </div>

  <div class="row">
    <div class="col-lg-6 mb-4">
      <!-- SOP Management -->
      {include file="module:housekeepingmanagement/views/templates/admin/_sop_management.tpl"}
    </div>

    <div class="col-lg-6 mb-4">
      <!-- Room Status -->
      {include file="module:housekeepingmanagement/views/templates/admin/_room_status.tpl"}
    </div>
  </div>
</div>

{literal}
<script>
  // expose ajax url to JS
  window.HK = window.HK || {};
  window.HK.ajaxUrl = '{$housekeeping_ajax_url|escape:'html':'UTF-8'}';
</script>
{/literal}
