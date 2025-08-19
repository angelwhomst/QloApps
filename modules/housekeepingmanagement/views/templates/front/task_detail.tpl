{* Housekeeping Detailed Task View *}
<div class="hk-task-wrapper" data-id-task="{$id_task|intval}" data-ajax-url="{$ajax_url|escape:'html':'UTF-8'}">
	<div class="hk-task-header">
		<div class="hk-task-room">
			<div class="hk-room-line">
				<span class="hk-room-number" id="hk-room-number">Room —</span>
				<span class="hk-sep">•</span>
				<span class="hk-room-type" id="hk-room-type">—</span>
			</div>
			<div class="hk-task-details">
				<div class="hk-detail-row">
					<div class="hk-detail-item">
						<span class="hk-label">Priority:</span> 
						<span class="hk-priority" id="hk-priority">—</span>
					</div>
					<div class="hk-detail-item">
						<span class="hk-label">Assigned:</span> 
						<span id="hk-staff">—</span>
					</div>
				</div>
				<div class="hk-dates">
					<div class="hk-date-item"><span class="hk-label">Start:</span> <span id="hk-start">—</span></div>
					<div class="hk-date-item"><span class="hk-label">Due:</span> <span id="hk-due">—</span></div>
				</div>
			</div>
		</div>
		<div class="hk-task-meta">
			<span class="hk-status hk-status-progress" id="hk-status-badge" aria-live="polite">Loading...</span>
			<span class="hk-progress" id="hk-progress" aria-live="polite">Checklist Done: 00/00</span>
		</div>
	</div>

	<div class="hk-task-note" id="hk-task-note" hidden>
		<p class="hk-note-text"></p>
	</div>

	<div class="hk-checklist" id="hk-checklist" aria-live="polite">
		<div class="hk-empty" id="hk-empty" role="status">
			<div style="margin-bottom:8px;">⏳</div>
			<div>Loading task details...</div>
		</div>
	</div>

	<div class="hk-actions">
		<button type="button" id="hk-btn-submit" class="hk-btn hk-btn-primary" aria-label="Submit checklist and mark task as done" disabled>
			Loading...
		</button>
	</div>

	<div class="hk-toast" id="hk-toast" role="status" aria-live="polite" aria-atomic="true"></div>
</div>

