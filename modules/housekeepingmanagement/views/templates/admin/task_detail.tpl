{*
  Housekeeper Task Detail View
  - Room info, checklist, progress, toggles, Done button
  - Accessible, responsive, color contrast
*}
<style>
.hk-detail-container { padding: 16px; font-family: Arial, sans-serif; background: #fff; border-radius: 10px; }
.hk-detail-header { display: flex; flex-wrap: wrap; gap: 16px; align-items: center; margin-bottom: 18px; }
.hk-detail-room { font-size: 20px; font-weight: bold; color: #007bff; }
.hk-detail-type { font-size: 15px; color: #666; }
.hk-detail-status { font-size: 13px; font-weight: bold; border-radius: 8px; padding: 4px 12px; margin-left: 8px; background: #e0f0ff; color: #007bff; }
.hk-detail-dates { font-size: 13px; color: #444; }
.hk-detail-progress { margin: 12px 0 18px 0; }
.hk-detail-progress-bar-bg { background: #e0e0e0; border-radius: 8px; width: 180px; height: 14px; overflow: hidden; display: inline-block; vertical-align: middle; }
.hk-detail-progress-bar { background: #41C588; height: 100%; border-radius: 8px; transition: width 0.3s; }
.hk-detail-checklist { margin: 0; padding: 0; list-style: none; }
.hk-detail-step-row { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.hk-detail-step-label { flex: 1; font-size: 15px; }
.hk-detail-toggle { display: flex; gap: 6px; }
.hk-detail-toggle-btn { border: none; border-radius: 6px; padding: 4px 14px; font-size: 14px; cursor: pointer; font-weight: bold; }
.hk-detail-toggle-btn.pass { background: #e7f8f0; color: #41C588; }
.hk-detail-toggle-btn.fail { background: #fff5e0; color: #F5A623; }
.hk-detail-toggle-btn.selected { box-shadow: 0 0 0 2px #007bff; }
.hk-detail-step-status { font-size: 12px; font-weight: bold; border-radius: 8px; padding: 2px 8px; }
.hk-detail-step-status.passed { background: #e7f8f0; color: #41C588; }
.hk-detail-step-status.failed { background: #fff5e0; color: #F5A623; }
.hk-detail-step-status.not_started { background: #f0f0f0; color: #888; }
.hk-detail-empty { color: #aaa; text-align: center; margin: 32px 0; font-size: 15px; }
.hk-detail-done-btn { margin-top: 24px; background: #41C588; color: #fff; border: none; border-radius: 8px; padding: 10px 28px; font-size: 16px; font-weight: bold; cursor: pointer; }
.hk-detail-done-btn:focus { outline: 2px solid #333; }
@media (max-width: 600px) {
  .hk-detail-header { flex-direction: column; align-items: flex-start; gap: 8px; }
  .hk-detail-progress-bar-bg { width: 100%; }
}
</style>

<div class="hk-detail-container" role="dialog" aria-modal="true" aria-label="Task Detail">
  <div class="hk-detail-header">
    <span class="hk-detail-room">Room {$task.room_num|escape:'html'}</span>
    <span class="hk-detail-type">{$task.room_type_name|escape:'html'}</span>
    <span class="hk-detail-status">{if $task.status=='in_progress'}In Progress{elseif $task.status=='done'}Done{else}To Do{/if}</span>
    <span class="hk-detail-dates">
      Start: {$task.date_add|date_format:"%m/%d/%Y %H:%M"}<br>
      Due: {$task.deadline|date_format:"%m/%d/%Y %H:%M"}
    </span>
  </div>
  <div class="hk-detail-progress">
    {assign var=doneCount value=$task.completion.completed|default:0}
    {assign var=totalCount value=$task.completion.total|default:0}
    <span style="font-weight:bold;">Checklist Done: {$doneCount}/{$totalCount}</span>
    <div class="hk-detail-progress-bar-bg" aria-hidden="true">
      {assign var=progress value=($totalCount > 0) ? (100 * $doneCount / $totalCount) : 0}
      <div class="hk-detail-progress-bar" style="width:{$progress|round:0}%"></div>
    </div>
    <span style="color:#41C588; font-weight:bold;">{$progress|round:0}%</span>
  </div>
  <div style="margin-bottom:12px; color:#555; font-size:14px;">
    {if $task.sop_title}
      <b>SOP:</b> {$task.sop_title|escape:'html'}
    {/if}
    {if $task.special_notes}
      <br><b>Notes:</b> {$task.special_notes|escape:'html'}
    {/if}
  </div>
  <ul class="hk-detail-checklist">
    {if $task.steps|@count > 0}
      {foreach from=$task.steps item=step}
        <li class="hk-detail-step-row">
          <span class="hk-detail-step-label">{$step.step_description|escape:'html'}</span>
          <div class="hk-detail-toggle" role="group" aria-label="Step status">
            <button class="hk-detail-toggle-btn pass{if $step.status=='passed'} selected{/if}" data-step="{$step.id_task_step}" data-status="passed" aria-pressed="{if $step.status=='passed'}true{else}false{/if}">Pass</button>
            <button class="hk-detail-toggle-btn fail{if $step.status=='failed'} selected{/if}" data-step="{$step.id_task_step}" data-status="failed" aria-pressed="{if $step.status=='failed'}true{else}false{/if}">Fail</button>
          </div>
          <span class="hk-detail-step-status {if $step.status=='passed'}passed{elseif $step.status=='failed'}failed{else}not_started{/if}">
            {if $step.status=='passed'}Passed{elseif $step.status=='failed'}Failed{else}Not Executed{/if}
          </span>
        </li>
      {/foreach}
    {else}
      <li class="hk-detail-empty">No checklist steps found for this task.</li>
    {/if}
  </ul>
  <button class="hk-detail-done-btn" id="hk-detail-done-btn" {if $task.status=='done'}disabled style="background:#ccc;"{/if}>Done Task</button>
</div>

{* Toast/snackbar for confirmation *}
<div id="hk-detail-toast" style="display:none; position:fixed; bottom:24px; left:50%; transform:translateX(-50%); background:#41C588; color:#fff; padding:12px 28px; border-radius:8px; font-size:16px; z-index:99999;">Task marked as done!</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // Toggle step status
  document.querySelectorAll('.hk-detail-toggle-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      const id_task_step = btn.getAttribute('data-step');
      const status = btn.getAttribute('data-status');
      fetch(window.location.href, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'ajax=1&action=updateStepStatus&id_task_step=' + encodeURIComponent(id_task_step) + '&status=' + encodeURIComponent(status) + '&id_task={$task.id_task|intval}'
      })
      .then(resp => resp.json())
      .then(data => {
        if (data.success) {
          // Update UI
          document.querySelectorAll('.hk-detail-toggle-btn[data-step="'+id_task_step+'"]').forEach(b => {
            b.classList.remove('selected');
            b.setAttribute('aria-pressed', 'false');
          });
          btn.classList.add('selected');
          btn.setAttribute('aria-pressed', 'true');
          // Update status badge
          const statusSpan = btn.closest('.hk-detail-step-row').querySelector('.hk-detail-step-status');
          if (status === 'passed') {
            statusSpan.textContent = 'Passed';
            statusSpan.className = 'hk-detail-step-status passed';
          } else if (status === 'failed') {
            statusSpan.textContent = 'Failed';
            statusSpan.className = 'hk-detail-step-status failed';
          }
          // Update progress bar/count
          if (data.completion) {
            document.querySelector('.hk-detail-progress span').textContent = 'Checklist Done: ' + data.completion.completed + '/' + data.completion.total;
            const percent = data.completion.total > 0 ? Math.round(100 * data.completion.completed / data.completion.total) : 0;
            document.querySelector('.hk-detail-progress-bar').style.width = percent + '%';
            document.querySelector('.hk-detail-progress').querySelectorAll('span')[2].textContent = percent + '%';
          }
        }
      });
    });
  });

  // Done Task button
  const doneBtn = document.getElementById('hk-detail-done-btn');
  if (doneBtn) {
    doneBtn.addEventListener('click', function() {
      fetch(window.location.href, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'ajax=1&action=markTaskDone&id_task={$task.id_task|intval}'
      })
      .then(resp => resp.json())
      .then(data => {
        if (data.success) {
          doneBtn.disabled = true;
          doneBtn.style.background = '#ccc';
          showToast('Task marked as done!');
        }
      });
    });
  }

  // Toast/snackbar
  function showToast(msg) {
    const toast = document.getElementById('hk-detail-toast');
    toast.textContent = msg;
    toast.style.display = 'block';
    setTimeout(() => { toast.style.display = 'none'; }, 2500);
  }
});
</script>