{*
  Housekeeper Dashboard: Task Board UI
  - 3 columns: To Do, In Progress, Done
  - Progress summary, search, filters
  - Responsive, accessible, color contrast
*}
<style>
.hk-board-container { padding: 24px; background: #f8f9fa; font-family: Arial, sans-serif; }
.hk-progress-summary { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
.hk-progress-bar-bg { background: #e0e0e0; border-radius: 8px; width: 200px; height: 16px; overflow: hidden; }
.hk-progress-bar { background: #41C588; height: 100%; border-radius: 8px; transition: width 0.3s; }
.hk-filters-row { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.hk-search { flex: 1; min-width: 180px; }
.hk-search input { width: 100%; padding: 8px 12px; border-radius: 6px; border: 1px solid #ccc; }
.hk-filter-select, .hk-filter-date { padding: 8px 12px; border-radius: 6px; border: 1px solid #ccc; }
.hk-board-columns { display: flex; gap: 20px; flex-wrap: wrap; }
.hk-board-col { flex: 1; min-width: 320px; background: #fff; border-radius: 10px; padding: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
.hk-board-col-title { font-weight: bold; font-size: 18px; margin-bottom: 12px; color: #333; }
.hk-task-card { background: #f7f7fa; border-radius: 8px; margin-bottom: 16px; padding: 16px; box-shadow: 0 1px 4px rgba(0,0,0,0.03); }
.hk-task-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.hk-room-num { font-weight: bold; font-size: 16px; color: #007bff; }
.hk-room-type { font-size: 13px; color: #666; }
.hk-task-steps { margin: 10px 0 0 0; padding: 0; list-style: none; }
.hk-step-row { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
.hk-step-checkbox { width: 18px; height: 18px; accent-color: #41C588; }
.hk-step-label { flex: 1; font-size: 14px; }
.hk-step-status { font-size: 12px; font-weight: bold; border-radius: 8px; padding: 2px 8px; }
.hk-step-status.not_started { background: #f0f0f0; color: #888; }
.hk-step-status.passed { background: #e7f8f0; color: #41C588; }
.hk-step-status.failed { background: #fff5e0; color: #F5A623; }
.hk-task-actions { margin-top: 10px; }
.hk-view-btn { background: #007bff; color: #fff; border: none; border-radius: 6px; padding: 6px 14px; cursor: pointer; font-size: 14px; }
.hk-view-btn:focus { outline: 2px solid #333; }
.hk-empty-state { color: #aaa; text-align: center; margin: 32px 0; font-size: 15px; }
@media (max-width: 900px) {
  .hk-board-columns { flex-direction: column; }
  .hk-board-col { min-width: 0; }
}
</style>

<div class="hk-board-container">
  {* Progress Summary *}
  <div class="hk-progress-summary" role="region" aria-label="Task Progress">
    <span style="font-weight:bold;">Task Done: {$taskCount.completed|default:0}/{$taskCount.total|default:0}</span>
    <div class="hk-progress-bar-bg" aria-hidden="true">
      {assign var=progress value=($taskCount.total > 0) ? (100 * $taskCount.completed / $taskCount.total) : 0}
      <div class="hk-progress-bar" style="width:{$progress|round:0}%"></div>
    </div>
    <span style="color:#41C588; font-weight:bold;">{$progress|round:0}%</span>
  </div>

  {* Filters and Search *}
  <form class="hk-filters-row" method="get" id="hk-filters-form">
    <div class="hk-search">
      <input type="text" name="search" placeholder="Search room number or name..." value="{$filters.search|escape:'html'}" aria-label="Search tasks">
    </div>
    <select name="priority" class="hk-filter-select" aria-label="Filter by priority">
      <option value="">Priority</option>
      <option value="High" {if $filters.priority=='High'}selected{/if}>High</option>
      <option value="Medium" {if $filters.priority=='Medium'}selected{/if}>Medium</option>
      <option value="Low" {if $filters.priority=='Low'}selected{/if}>Low</option>
    </select>
    <input type="date" name="date_from" class="hk-filter-date" value="{$filters.date_from|escape:'html'}" aria-label="From date">
    <input type="date" name="date_to" class="hk-filter-date" value="{$filters.date_to|escape:'html'}" aria-label="To date">
    <button type="submit" class="hk-view-btn" style="background:#41C588;">Filter</button>
  </form>

  {* Task Board Columns *}
  <div class="hk-board-columns" role="list">
    {foreach from=['to_do'=>'To Do','in_progress'=>'In Progress','done'=>'Done'] key=colKey item=colLabel}
      <div class="hk-board-col" aria-labelledby="col-{$colKey}">
        <div class="hk-board-col-title" id="col-{$colKey}">{$colLabel}</div>
        {if $tasks[$colKey]|@count > 0}
          {foreach from=$tasks[$colKey] item=task}
            <div class="hk-task-card" tabindex="0" aria-label="Task for room {$task.room_num|escape:'html'}">
              <div class="hk-task-header">
                <span class="hk-room-num">Room {$task.room_num|escape:'html'}</span>
                <span class="hk-room-type">{$task.room_type_name|escape:'html'}</span>
              </div>
              <ul class="hk-task-steps">
                {foreach from=$task.steps item=step}
                  <li class="hk-step-row">
                    <input type="checkbox" class="hk-step-checkbox" data-task="{$task.id_task}" data-step="{$step.id_task_step}" {if $step.status=='passed'}checked{/if} aria-label="Mark step '{$step.step_description|escape:'html'}' as done" disabled>
                    <span class="hk-step-label">{$step.step_description|escape:'html'}</span>
                    <span class="hk-step-status {if $step.status=='passed'}passed{elseif $step.status=='failed'}failed{else}not_started{/if}">
                      {if $step.status=='passed'}Passed{elseif $step.status=='failed'}Failed{else}Not Executed{/if}
                    </span>
                  </li>
                {/foreach}
              </ul>
              <div class="hk-task-actions">
                <button class="hk-view-btn" data-task="{$task.id_task}" aria-label="View details for room {$task.room_num|escape:'html'}">View Task</button>
              </div>
            </div>
          {/foreach}
        {else}
          <div class="hk-empty-state">No tasks found in this column.</div>
        {/if}
      </div>
    {/foreach}
  </div>
</div>

{* Modal for Task Detail (loaded via AJAX) *}
<div id="hk-task-modal" style="display:none; position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.4); align-items:center; justify-content:center; z-index:9999;">
  <div id="hk-task-modal-content" style="background:#fff; border-radius:10px; max-width:500px; width:95%; margin:auto; padding:24px; position:relative;">
    <button id="hk-modal-close" class="hk-view-btn" style="position:absolute; top:10px; right:10px; background:#ccc; color:#222;">Close</button>
    <div id="hk-task-modal-body"></div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // Modal logic
  const modal = document.getElementById('hk-task-modal');
  const modalBody = document.getElementById('hk-task-modal-body');
  const closeBtn = document.getElementById('hk-modal-close');
  document.querySelectorAll('.hk-view-btn[data-task]').forEach(btn => {
    btn.addEventListener('click', function() {
      const id_task = btn.getAttribute('data-task');
      modal.style.display = 'flex';
      modalBody.innerHTML = '<div style="text-align:center;padding:30px;">Loading...</div>';
      fetch('index.php?controller=HousekeeperTaskDetail&id_task=' + encodeURIComponent(id_task) + '&ajax=1')
        .then(resp => resp.text())
        .then(html => { modalBody.innerHTML = html; });
    });
  });
  closeBtn.onclick = () => { modal.style.display = 'none'; };
  modal.onclick = e => { if (e.target === modal) modal.style.display = 'none'; };
});
</script>