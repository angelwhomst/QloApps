(function(){
	'use strict';

	function qs(sel, ctx){ return (ctx||document).querySelector(sel); }
	function qsa(sel, ctx){ return Array.prototype.slice.call((ctx||document).querySelectorAll(sel)); }

	function pad(n, t){ var s = String(n); var l = String(t).length; while(s.length < l){ s = '0'+s; } return s; }

	function showToast(message, kind){
		var toast = qs('#hk-toast');
		if (!toast) return;
		toast.textContent = message || '';
		toast.classList.add('show');
		toast.style.background = kind === 'success' ? '#166534' : (kind === 'error' ? '#991b1b' : '#111827');
		setTimeout(function(){ toast.classList.remove('show'); }, 2500);
	}

	function renderChecklist(container, steps){
		container.innerHTML = '';
		if (!steps || !steps.length){
			var empty = document.createElement('div');
			empty.className = 'hk-empty';
			empty.innerHTML = '<div style="margin-bottom:8px;">📋</div><div>No checklist is configured for this room type.</div><div style="font-size:12px;color:#9ca3af;margin-top:4px;">Please contact your supervisor to set up cleaning procedures.</div>';
			container.appendChild(empty);
			return;
		}

		steps.forEach(function(step){
			var row = document.createElement('div');
			row.className = 'hk-checklist-item';
			row.setAttribute('data-id-step', step.id_sop_step);

			var label = document.createElement('div');
			label.className = 'hk-item-label';
			label.textContent = step.label;

			var toggles = document.createElement('div');
			toggles.className = 'hk-toggles';

			// Pass
			var passWrap = document.createElement('label');
			passWrap.className = 'hk-toggle hk-toggle-pass';
			passWrap.setAttribute('tabindex','0');
			var passInput = document.createElement('input');
			passInput.type = 'radio';
			passInput.name = 'step_'+step.id_sop_step;
			passInput.value = 'pass';
			passInput.setAttribute('aria-label','Mark as Passed');
			var passChip = document.createElement('span');
			passChip.className = 'hk-chip';
			passChip.innerHTML = '<span aria-hidden="true">✔</span> Pass';
			passWrap.appendChild(passInput); passWrap.appendChild(passChip);

			// Fail
			var failWrap = document.createElement('label');
			failWrap.className = 'hk-toggle hk-toggle-fail';
			failWrap.setAttribute('tabindex','0');
			var failInput = document.createElement('input');
			failInput.type = 'radio';
			failInput.name = 'step_'+step.id_sop_step;
			failInput.value = 'fail';
			failInput.setAttribute('aria-label','Mark as Failed');
			var failChip = document.createElement('span');
			failChip.className = 'hk-chip';
			failChip.innerHTML = '<span aria-hidden="true">! </span> Fail';
			failWrap.appendChild(failInput); failWrap.appendChild(failChip);

			if (step.status === 'Completed') { passInput.checked = true; }
			if (step.status === 'Not Executed') { /* none checked by default */ }

			toggles.appendChild(passWrap); toggles.appendChild(failWrap);
			row.appendChild(label); row.appendChild(toggles);
			container.appendChild(row);
		});
	}

	function computeProgress(steps){
		var total = steps.length;
		var done = steps.filter(function(s){ return s.status === 'Completed'; }).length;
		return {done: done, total: total};
	}

	function updateProgressEl(progress){
		var el = qs('#hk-progress');
		if (!el) return;
		el.textContent = 'Checklist Done: '+pad(progress.done, progress.total)+'/'+pad(progress.total, progress.total);
	}

	function attachHandlers(state){
		var container = qs('#hk-checklist');
		container.addEventListener('change', function(e){
			var target = e.target;
			if (target && target.type === 'radio'){
				var row = target.closest('.hk-checklist-item');
				if (!row) return;
				var idStep = parseInt(row.getAttribute('data-id-step'), 10);
				var pass = target.value === 'pass';
				// Update local state
				var s = state.steps.find(function(x){ return x.id_sop_step === idStep; });
				if (s){ s.status = pass ? 'Completed' : 'Not Executed'; }
				updateProgressEl(computeProgress(state.steps));
				// Persist via AJAX (non-blocking)
				send('toggleStep', { id_task: state.id_task, id_sop_step: idStep, passed: pass });
			}
		});

		var btn = qs('#hk-btn-submit');
		btn.addEventListener('click', function(){
			btn.disabled = true;
			var old = btn.textContent; 
			btn.textContent = 'Submitting…';
			
			var items = state.steps.map(function(s){ 
				return { id_sop_step: s.id_sop_step, passed: s.status === 'Completed' }; 
			});
			
			if (!items.length){
				showToast('No checklist to submit for this task.', 'info');
				btn.disabled = false; 
				btn.textContent = old;
				return;
			}
			
			// Check if all items are marked (either passed or failed)
			var unmarkedItems = state.steps.filter(function(step) { 
				return step.status !== 'Completed' && step.status !== 'Not Executed'; 
			});
			if (unmarkedItems.length > 0) {
				showToast('Please mark all checklist items (Pass or Fail) before submitting.', 'info');
				btn.disabled = false; 
				btn.textContent = old;
				return;
			}
			
			send('submitChecklist', { id_task: state.id_task, items: JSON.stringify(items) }, function(resp){
				btn.disabled = false; 
				btn.textContent = old;
				try{
					var r = JSON.parse(resp || '{}');
					if (r && r.success){
						showToast('Checklist submitted successfully! Task marked as completed.', 'success');
						
						// Update status badge to completed
						var badge = qs('#hk-status-badge');
						if (badge){ 
							badge.textContent = 'Completed'; 
							badge.className = 'hk-status hk-status-done'; 
						}
						
						// Update progress to show 100%
						var progress = computeProgress(state.steps);
						updateProgressEl(progress);
						
						// Disable submit button since task is complete
						btn.disabled = true;
						btn.textContent = 'Task Completed';
						btn.className = 'hk-btn hk-btn-primary';
						
						// Show inspection table placeholder
						var inspTable = qs('#hk-inspection-table');
						if (inspTable) {
							inspTable.innerHTML = `
								<table style="width:100%;border-collapse:collapse;">
									<thead>
										<tr style="background:#f3f4f6;">
											<th style="padding:8px;border:1px solid #e5e7eb;">Step</th>
											<th style="padding:8px;border:1px solid #e5e7eb;">Result</th>
										</tr>
									</thead>
									<tbody>
										${state.steps.map(s => `
											<tr>
												<td style="padding:8px;border:1px solid #e5e7eb;">${s.label}</td>
												<td style="padding:8px;border:1px solid #e5e7eb;">${s.status === 'Completed' ? 'Pass' : 'Fail'}</td>
											</tr>
										`).join('')}
									</tbody>
								</table>
							`;
						}
						
					} else {
						showToast('Submit failed. Please try again.', 'error');
					}
				} catch(err){ 
					showToast('Unexpected response. Please try again.', 'error'); 
				}
			});
		});
	}

	function send(action, data, cb){
		var root = qs('.hk-task-wrapper');
		var url = root.getAttribute('data-ajax-url');
		var xhr = new XMLHttpRequest();
		xhr.open('POST', url, true);
		xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');
		xhr.onload = function(){ if (cb) cb(xhr.responseText); };
		var payload = 'ajax=1&action='+encodeURIComponent(action);
		Object.keys(data||{}).forEach(function(k){ payload += '&'+encodeURIComponent(k)+'='+encodeURIComponent(data[k]); });
		xhr.send(payload);
	}

	function init(){
		var root = qs('.hk-task-wrapper');
		if (!root) return;
		var idTask = parseInt(root.getAttribute('data-id-task'),10);
		var state = { id_task: idTask, steps: [] };

		send('getTaskDetail', { id_task: idTask }, function(resp){
			try{
				var r = JSON.parse(resp||'{}');
				if (!r || !r.success){ 
					qs('#hk-empty').innerHTML = '<div style="margin-bottom:8px;">❌</div><div>Failed to load task details.</div><div style="font-size:12px;color:#9ca3af;margin-top:4px;">Please refresh the page or contact support.</div>'; 
					return; 
				}
				var t = r.task || {};
				
				// Update room information
				qs('#hk-room-number').textContent = 'Room '+(t.room && t.room.number ? t.room.number : '—');
				qs('#hk-room-type').textContent = (t.room && t.room.type ? t.room.type : '—');
				
				// Update priority with color coding
				var priorityEl = qs('#hk-priority');
				if (priorityEl && t.priority) {
					priorityEl.textContent = t.priority;
					priorityEl.className = 'hk-priority ' + t.priority.toLowerCase();
				}
				
				// Update staff assignment
				if (qs('#hk-staff')) {
					qs('#hk-staff').textContent = t.staff || 'Unassigned';
				}
				
				// Update dates
				qs('#hk-start').textContent = t.start || '—';
				qs('#hk-due').textContent = t.deadline || '—';
				
				// Update status badge
				var statusBadge = qs('#hk-status-badge');
				if (statusBadge && t.status) {
					statusBadge.textContent = t.status;
					statusBadge.className = 'hk-status';
					if (t.status === 'Completed') {
						statusBadge.classList.add('hk-status-done');
					} else if (t.status === 'Not Started') {
						statusBadge.classList.add('hk-status-not-started');
					} else {
						statusBadge.classList.add('hk-status-progress');
					}
				}
				
				// Update state and render checklist
				state.steps = (t.steps || []).map(function(s){ return { id_sop_step: s.id_sop_step, label: s.label, status: s.status }; });

				// Show note if available
				var note = qs('#hk-task-note');
				if (t.notes && t.notes.trim()){ 
					note.hidden = false; 
					qs('.hk-note-text', note).textContent = t.notes; 
				}

				renderChecklist(qs('#hk-checklist'), state.steps);
				updateProgressEl({ done: t.progress ? t.progress.done : 0, total: t.progress ? t.progress.total : state.steps.length });
				attachHandlers(state);
				
				// Enable submit button if there are steps to complete
				var submitBtn = qs('#hk-btn-submit');
				if (submitBtn && state.steps.length > 0) {
					submitBtn.disabled = false;
					submitBtn.textContent = 'Done Task';
				}
			} catch(err){ 
				qs('#hk-empty').innerHTML = '<div style="margin-bottom:8px;">❌</div><div>Failed to parse task details.</div><div style="font-size:12px;color:#9ca3af;margin-top:4px;">Please refresh the page or contact support.</div>'; 
			}
		});
	}

	document.addEventListener('DOMContentLoaded', init);
})();


