{*
  Housekeeper Dashboard: Modern Professional Task Board UI
  - 3 columns: To Do, In Progress, Done
  - Progress summary (left), filters (right) in header
  - Task cards: status display matches column, View Task button lower right
*}

<div class="hk-dashboard">
  <div class="hk-dashboard-header">
    <div class="hk-progress-container">
      <div class="hk-progress-summary" role="region" aria-label="Task Progress">
        <span class="hk-progress-label">Task Done: {$taskCount.completed|default:0}/{$taskCount.total|default:0}</span>
        <div class="hk-progress-track">
          {assign var=progress value=($taskCount.total > 0) ? (100 * $taskCount.completed / $taskCount.total) : 0}
          <div class="hk-progress-bar" style="width:{$progress|round:0}%"></div>
        </div>
        <span class="hk-progress-percentage">{$progress|round:0}%</span>
      </div>
    </div>

    {* Filters horizontally aligned at top right *}
    <div class="hk-filters-container">
      <form class="hk-filters-form" method="get" id="hk-filters-form">
        <input type="hidden" name="controller" value="HousekeeperDashboard">
        <input type="hidden" name="token" value="{$token}">
        <input type="text" name="search" placeholder="Search rooms..." value="{$filters.search|escape:'html'}" aria-label="Search tasks" class="hk-filter-search">
        <select name="status" class="hk-filter-select" aria-label="Filter by status">
          <option value="">Status</option>
          <option value="to_do" {if $filters.status=='to_do'}selected{/if}>To Do</option>
          <option value="in_progress" {if $filters.status=='in_progress'}selected{/if}>In Progress</option>
          <option value="done" {if $filters.status=='done'}selected{/if}>Done</option>
        </select>
        <select name="priority" class="hk-filter-select" aria-label="Filter by priority">
          <option value="">Priority</option>
          <option value="High" {if $filters.priority=='High'}selected{/if}>High</option>
          <option value="Medium" {if $filters.priority=='Medium'}selected{/if}>Medium</option>
          <option value="Low" {if $filters.priority=='Low'}selected{/if}>Low</option>
        </select>
        <input type="date" name="date_from" class="hk-filter-date" value="{$filters.date_from|escape:'html'}" aria-label="From date">
        <input type="date" name="date_to" class="hk-filter-date" value="{$filters.date_to|escape:'html'}" aria-label="To date">
        <button type="submit" class="hk-filter-button">Apply</button>
      </form>
    </div>
  </div>

  {* Task Board Columns *}
  <div class="hk-board" role="list">
    {foreach from=['to_do'=>'To Do','in_progress'=>'In Progress','done'=>'Done'] key=colKey item=colLabel}
      <div class="hk-column" aria-labelledby="col-{$colKey}">
        <div class="hk-column-header" id="col-{$colKey}">
          <h2>{$colLabel}</h2>
          <span class="hk-column-count">{$tasks[$colKey]|@count}</span>
        </div>
        <div class="hk-column-content">
          {if $tasks[$colKey]|@count > 0}
            {foreach from=$tasks[$colKey] item=task}
              <div class="hk-task-card" tabindex="0" aria-label="Task for room {$task.room_num|escape:'html'}">
                <div class="hk-task-card-header">
                  <div class="hk-room-info">
                    <span class="hk-room-number">Room {$task.room_num|escape:'html'}</span>
                    <span class="hk-room-type">{$task.room_type_name|escape:'html'}</span>
                  </div>
                  {if isset($task.priority) && $task.priority}
                  <div class="hk-priority-badge hk-priority-{$task.priority|strtolower|escape:'html'}">
                    {$task.priority|escape:'html'}
                  </div>
                  {/if}
                </div>
                <div class="hk-task-checklist">
                  <ul class="hk-steps-list">
                    {foreach from=$task.steps item=step name=steps}
                      {if $smarty.foreach.steps.index < 3}
                        <li class="hk-step-item {$step.status}">
                          {$step.step_description|escape:'html'|truncate:50:"..."}
                        </li>
                      {/if}
                    {/foreach}
                    {if $task.steps|@count > 3}
                      <li class="hk-step-item hk-step-more">
                        +{$task.steps|@count - 3} more steps
                      </li>
                    {/if}
                  </ul>
                </div>
                <div class="hk-task-card-footer">
                  <div class="hk-task-status hk-status-{$colKey}">
                    {if $colKey == 'to_do'}Not Executed
                    {elseif $colKey == 'in_progress'}In Progress
                    {else}Done
                    {/if}
                  </div>
                  <a href="index.php?controller=HousekeeperTaskDetail&id_task={$task.id_task}&token={$detail_token}" 
                     class="hk-view-task-btn" 
                     role="button" 
                     aria-label="View details for room {$task.room_num|escape:'html'}">
                    View Task
                  </a>
                </div>
              </div>
            {/foreach}
          {else}
            <div class="hk-empty-column">
              <div class="hk-empty-icon">📋</div>
              <p>No tasks in this column</p>
            </div>
          {/if}
        </div>
      </div>
    {/foreach}
  </div>
</div>

<style>
/* Modern Professional Dashboard Styling */
.hk-dashboard {
  font-family: Arial,Helvetica,sans-serif;
  color: #333;
  padding: 24px;
  background: #f5f7fa;
  border-radius: 8px;
}

/* Header section with progress and filters */
.hk-dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 20px;
}

.hk-progress-container {
  flex: 1;
  min-width: 300px;
}

.hk-progress-summary {
  display: flex;
  align-items: center;
  gap: 16px;
}

.hk-progress-label {
  font-weight: 600;
  white-space: nowrap;
}

.hk-progress-track {
  flex: 1;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
  min-width: 100px;
  max-width: 250px;
}

.hk-progress-bar {
  height: 100%;
  background: #38b2ac;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.hk-progress-percentage {
  font-weight: 600;
  color: #38b2ac;
  min-width: 45px;
}

/* Filters styling - now in the top right */
.hk-filters-container {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex: 1 1 auto;
}

.hk-filters-form {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 10px;
  margin-left: auto;
}

.hk-filter-group, .hk-filter-search, .hk-filter-select, .hk-filter-date {
  margin: 0;
}

.hk-filter-search {
  width: 160px;
  padding: 8px 12px;
  border: 1px solid #cbd5e0;
  border-radius: 4px;
  font-size: 14px;
}

.hk-filter-select {
  padding: 8px 12px;
  border: 1px solid #cbd5e0;
  border-radius: 4px;
  background-color: #fff;
  font-size: 14px;
  min-width: 110px;
}

.hk-filter-date {
  padding: 8px 10px;
  border: 1px solid #cbd5e0;
  border-radius: 4px;
  font-size: 14px;
  width: 120px;
}

.hk-filter-button {
  background: #1a57dbbe;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.hk-filter-button:hover {
  background: #319795;
}

/* Board columns layout */
.hk-board {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.hk-column {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.hk-column-header {
  background: #f9fafb;
  padding: 16px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.hk-column-header h2 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
}

.hk-column-count {
  background: #e5e7eb;
  color: #4b5563;
  font-size: 14px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 12px;
}

.hk-column-content {
  padding: 16px;
  flex: 1;
  overflow-y: auto;
  max-height: 70vh;
}

/* Task cards */
.hk-task-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  margin-bottom: 16px;
  padding: 16px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.03);
  transition: box-shadow 0.2s, transform 0.2s;
}

.hk-task-card:hover {
  box-shadow: 0 4px 6px rgba(0,0,0,0.05);
  transform: translateY(-2px);
}

.hk-task-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.hk-room-info {
  display: flex;
  flex-direction: column;
}

.hk-room-number {
  font-weight: 600;
  font-size: 16px;
  color: #1a56db;
}

.hk-room-type {
  font-size: 13px;
  color: #6b7280;
  margin-top: 2px;
}

.hk-priority-badge {
  font-size: 12px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 4px;
}

.hk-priority-high {
  background: #fee2e2;
  color: #b91c1c;
}

.hk-priority-medium {
  background: #fef3c7;
  color: #b45309;
}

.hk-priority-low {
  background: #d1fae5;
  color: #065f46;
}

/* Checklist styling */
.hk-task-checklist {
  margin: 12px 0;
}

.hk-steps-list {
  margin: 0;
  padding: 0;
  list-style: none;
}

.hk-step-item {
  padding: 6px 0;
  font-size: 14px;
  color: #4b5563;
  position: relative;
  padding-left: 20px;
}

.hk-step-item:before {
  content: "";
  position: absolute;
  left: 0;
  top: 11px;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #d1d5db;
}

.hk-step-item.passed:before {
  background: #10b981;
}

.hk-step-item.failed:before {
  background: #d1d5db;
}

.hk-step-more {
  font-style: italic;
  color: #9ca3af;
}

/* Footer with status and action button */
.hk-task-card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f3f4f6;
}

.hk-task-status {
  font-size: 12px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 12px;
}

.hk-status-not_executed {
  background: #fee2e2;
  color: #b91c1c;
}

.hk-status-in_progress {
  background: #fef3c7;
  color: #b45309;
}

.hk-status-done {
  background: #d1fae5;
  color: #065f46;
}

.hk-status-to_do {
  background: #fee2e2;
  color: #b91c1c;
}

.hk-view-task-btn,
.hk-view-task-btn:visited,
.hk-view-task-btn:active {
  background: #fff;
  color: #111827 !important;
  border: 1.5px solid #111827;
  border-radius: 4px;
  padding: 8px 16px;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.hk-view-task-btn:hover {
  background: #f3f4f6;
  color: #111827 !important;
  border-color: #111827;
  text-decoration: none;
}

/* Empty state styling */
.hk-empty-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 24px;
  color: #9ca3af;
  text-align: center;
}

.hk-empty-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .hk-board {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .hk-dashboard-header {
    flex-direction: column;
    align-items: stretch;
  }
  
  .hk-filters-form {
    justify-content: flex-start;
  }
  
  .hk-board {
    grid-template-columns: 1fr;
  }
  
  .hk-filter-search, 
  .hk-filter-select, 
  .hk-filter-date {
    width: 100%;
  }
  
  .hk-filter-dates {
    width: 100%;
  }
}

@media (max-width: 992px) {
  .hk-dashboard-header {
    flex-direction: column;
    gap: 16px;
  }
  .hk-filters-container {
    justify-content: flex-start;
    margin-top: 12px;
  }
  .hk-filters-form {
    flex-wrap: wrap;
    gap: 8px;
    margin-left: 0;
  }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // Auto-submit form when date or select fields change
  const autoSubmitFields = document.querySelectorAll('.hk-filter-select, .hk-filter-date');
  autoSubmitFields.forEach(field => {
    field.addEventListener('change', function() {
      document.getElementById('hk-filters-form').submit();
    });
  });
  
  // Submit form when pressing enter in search field
  const searchField = document.querySelector('.hk-filter-search');
  if (searchField) {
    searchField.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        document.getElementById('hk-filters-form').submit();
      }
    });
  }
});
</script>