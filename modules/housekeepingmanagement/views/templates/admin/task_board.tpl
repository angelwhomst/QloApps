<!-- Housekeeping Management - Clean Task Board View -->
<div class="housekeeping-dashboard" style="padding: 24px 0; background: #f5f6f7;">

    <link rel="stylesheet" href="{$smarty.const._MODULE_DIR_}housekeepingmanagement/views/css/housekeeping-task-board.css" />
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        body, .housekeeping-dashboard, .hk-task-board, .hk-task-card, .hk-task-step, .hk-task-actions, .hk-modal-content, .hk-modal-header, .hk-modal-footer {
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        .hk-task-board { max-width:1200px; margin:0 auto; }
        .hk-header { display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:16px; }
        .hk-progress { flex:1 1 220px; }
        .hk-progress-bar { height:8px; background:#e0e0e0; border-radius:4px; margin-top:6px; width:100%; }
        .hk-progress-fill { height:100%; background:#007bff; border-radius:4px; width:0%; transition:width 0.3s; }
        .hk-filters { flex:2 1 400px; display:flex; gap:12px; align-items:center; }
        .hk-filters input, .hk-filters select, .hk-filters button { font-size:15px; }
        .hk-columns { display:flex; gap:18px; margin-top:24px; }
        .hk-col { flex:1; background:#fff; border-radius:8px; box-shadow:0 1px 4px #e3e3e3; padding:16px; min-width:250px; }
        .hk-col h3 { font-size:16px; font-weight:600; color:#222; margin-bottom:10px; display:flex; align-items:center; gap:6px; }
        .hk-badge { border-radius:12px; padding:2px 8px; font-size:13px; margin-left:6px; }
        .hk-badge.not { background:#f0ad4e; color:#fff; }
        .hk-badge.ip { background:#5bc0de; color:#fff; }
        .hk-badge.ok { background:#28a745; color:#fff; }
        .hk-empty { color:#888; font-size:14px; text-align:center; margin:24px 0; }
        .hk-task-card { background:#f8f9fa; border-radius:6px; box-shadow:0 1px 2px #e3e3e3; margin-bottom:16px; padding:14px 16px; }
        .hk-task-header { display:flex; justify-content:space-between; align-items:center; }
        .hk-room { font-weight:600; font-size:15px; color:#222; }
        .hk-type { font-size:13px; color:#555; margin-left:8px; }
        .hk-task-steps { margin:10px 0 0 0; padding:0; list-style:none; }
        .hk-task-step { display:flex; align-items:center; gap:8px; margin-bottom:6px; }
        .hk-step-status { font-size:12px; font-weight:500; padding:2px 8px; border-radius:10px; margin-left:6px; }
        .hk-step-status.not { background:#f8d7da; color:#721c24; }
        .hk-step-status.ip { background:#fff3cd; color:#856404; }
        .hk-step-status.ok { background:#d4edda; color:#155724; }
        .hk-task-actions { margin-top:10px; display:flex; gap:10px; }
        .hk-task-actions a, .hk-task-actions button { font-size:14px; border:none; background:none; color:#007bff; cursor:pointer; text-decoration:underline; }
        .hk-task-actions a:focus, .hk-task-actions button:focus { outline:2px solid #007bff; }
        .hk-task-link { color:#28a745; font-size:13px; margin-left:8px; }
        /* Modal styles */
        .hk-modal { display:none; position:fixed; z-index:9999; left:0; top:0; width:100vw; height:100vh; background:rgba(0,0,0,0.3); align-items:center; justify-content:center; }
        .hk-modal-content { background:#fff; border-radius:8px; max-width:500px; width:90vw; padding:24px; box-shadow:0 2px 16px #0002; }
        .hk-modal-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:12px; }
        .hk-modal-title { font-size:18px; font-weight:600; color:#222; }
        .hk-modal-close { background:none; border:none; font-size:22px; color:#888; cursor:pointer; }
        .hk-modal-footer { text-align:right; margin-top:18px; }
        .hk-modal-footer button { padding:7px 16px; border-radius:4px; background:#007bff; color:#fff; border:none; font-size:15px; cursor:pointer; }
        @media (max-width: 900px) {
            .hk-columns { flex-direction:column; gap:12px; }
        }
    </style>
    <div class="hk-task-board">
        <div class="hk-header">
            <div class="hk-progress" aria-live="polite">
                <div id="hk-progress-text" style="font-weight:600; font-size:20px; color:#222;">Task Done: 0/0</div>
                <div id="hk-progressbar" class="hk-progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="0" aria-valuenow="0" aria-valuetext="Task Done: 0/0" aria-label="Task completion progress">
                    <div id="hk-progress-fill" class="hk-progress-fill"></div>
                </div>
            </div>
            <form class="hk-filters" role="region" aria-label="Filters" onsubmit="return false;">
                <div style="flex:1;">
                    <input id="hk-search" type="search" placeholder="Search room number or name" aria-label="Search tasks" style="width:100%; padding:7px 12px; border:1px solid #d1d5db; border-radius:4px;" />
                </div>
                <div>
                    <select id="hk-status" aria-label="Status filter" style="padding:7px 12px; border:1px solid #d1d5db; border-radius:4px;">
                        <option value="">All Status</option>
                        <option value="To Do">To Do</option>
                        <option value="In Progress">In Progress</option>
                        <option value="Done">Done</option>
                    </select>
                </div>
                <div>
                    <select id="hk-priority" aria-label="Priority filter" style="padding:7px 12px; border:1px solid #d1d5db; border-radius:4px;">
                        <option value="">Priority</option>
                        <option value="High">High</option>
                        <option value="Medium">Medium</option>
                        <option value="Low">Low</option>
                    </select>
                </div>
                <div style="position:relative; display:flex; align-items:center;">
                    <input id="hk-date" type="date" aria-label="Deadline date filter"
                        style="padding:7px 36px 7px 12px; border:1px solid #d1d5db; border-radius:4px; font-size:15px; width:130px;" />
                    <button type="button" tabindex="0" aria-label="Open calendar" style="position:absolute; right:6px; background:none; border:none; padding:0; cursor:pointer;"
                        onclick="document.getElementById('hk-date').focus();">
                        <i class="fa fa-calendar" style="color:#007bff; font-size:18px;"></i>
                    </button>
                </div>
                <button id="hk-clear" class="hk-btn" aria-label="Clear filters" type="button" style="padding:7px 16px; background:#fff; border:1px solid #007bff; color:#007bff; border-radius:4px; font-size:15px; cursor:pointer; transition:background 0.2s;">
                    <i class="fa fa-eraser"></i> Clear
                </button>
            </form>
        </div>
        <div class="hk-columns" aria-live="polite">
            <div class="hk-col" id="col-todo" aria-labelledby="col-todo-title">
                <h3 id="col-todo-title">
                    <i class="fa fa-list-ul" style="color:#007bff;"></i> To Do
                    <span id="cnt-todo" class="hk-badge not">0</span>
                </h3>
                <div class="hk-empty" id="empty-todo">No tasks to do.</div>
                <div id="list-todo"></div>
            </div>
            <div class="hk-col" id="col-inprogress" aria-labelledby="col-inprogress-title">
                <h3 id="col-inprogress-title">
                    <i class="fa fa-spinner" style="color:#007bff;"></i> In Progress
                    <span id="cnt-inprogress" class="hk-badge ip">0</span>
                </h3>
                <div class="hk-empty" id="empty-inprogress">No tasks in progress.</div>
                <div id="list-inprogress"></div>
            </div>
            <div class="hk-col" id="col-done" aria-labelledby="col-done-title">
                <h3 id="col-done-title">
                    <i class="fa fa-check-circle" style="color:#28a745;"></i> Done
                    <span id="cnt-done" class="hk-badge ok">0</span>
                </h3>
                <div class="hk-empty" id="empty-done">No tasks completed yet.</div>
                <div id="list-done"></div>
            </div>
        </div>
        <!-- Modal -->
        <div id="hk-modal" class="hk-modal" tabindex="-1" aria-modal="true" role="dialog">
            <div class="hk-modal-content">
                <div class="hk-modal-header">
                    <span class="hk-modal-title"><i class="fa fa-tasks" style="color:#007bff; margin-right:8px;"></i>Task Details</span>
                    <button class="hk-modal-close" aria-label="Close" onclick="closeModal()">&times;</button>
                </div>
                <div class="hk-modal-body" id="hk-modal-body"></div>
                <div class="hk-modal-footer">
                    <button type="button" onclick="closeModal()">Close</button>
                </div>
            </div>
        </div>
    </div>
    {literal}
    <script>
    // Demo data for tasks
    let tasks = [
        {
            id: 1,
            room: "101",
            type: "Deluxe",
            priority: "High",
            date: "2025-08-19",
            status: "To Do",
            steps: [
                { name: "Sweep floor", status: "Not Executed" },
                { name: "Change linens", status: "Not Executed" },
                { name: "Sanitize bathroom", status: "Not Executed" }
            ],
            link: "https://forms.gle/example1"
        },
        {
            id: 2,
            room: "102",
            type: "Standard",
            priority: "Medium",
            date: "2025-08-19",
            status: "In Progress",
            steps: [
                { name: "Sweep floor", status: "Completed" },
                { name: "Change linens", status: "In Progress" },
                { name: "Sanitize bathroom", status: "Not Executed" }
            ]
        },
        {
            id: 3,
            room: "103",
            type: "Suite",
            priority: "Low",
            date: "2025-08-18",
            status: "Done",
            steps: [
                { name: "Sweep floor", status: "Completed" },
                { name: "Change linens", status: "Completed" },
                { name: "Sanitize bathroom", status: "Completed" }
            ],
            link: ""
        }
    ];

    function getStepColor(status) {
        if (status === "Completed") return "ok";
        if (status === "In Progress") return "ip";
        return "not";
    }

    function renderTasks() {
        let search = document.getElementById('hk-search').value.toLowerCase();
        let status = document.getElementById('hk-status').value;
        let priority = document.getElementById('hk-priority').value;
        let date = document.getElementById('hk-date').value;

        let filtered = tasks.filter(task => {
            let match = true;
            if (search) {
                match = task.room.toLowerCase().includes(search) || task.type.toLowerCase().includes(search);
            }
            if (match && status) match = task.status === status;
            if (match && priority) match = task.priority === priority;
            if (match && date) match = task.date === date;
            return match;
        });

        let todo = filtered.filter(t => t.status === "To Do");
        let inprogress = filtered.filter(t => t.status === "In Progress");
        let done = filtered.filter(t => t.status === "Done");

        document.getElementById('cnt-todo').textContent = todo.length;
        document.getElementById('cnt-inprogress').textContent = inprogress.length;
        document.getElementById('cnt-done').textContent = done.length;

        // Progress bar
        let total = filtered.length;
        let completed = done.length;
        document.getElementById('hk-progress-text').textContent = `Task Done: ${completed}/${total}`;
        document.getElementById('hk-progressbar').setAttribute('aria-valuemax', total);
        document.getElementById('hk-progressbar').setAttribute('aria-valuenow', completed);
        document.getElementById('hk-progressbar').setAttribute('aria-valuetext', `Task Done: ${completed}/${total}`);
        document.getElementById('hk-progress-fill').style.width = total ? ((completed/total)*100)+"%" : "0%";

        function renderColumn(listId, emptyId, arr) {
            let list = document.getElementById(listId);
            let empty = document.getElementById(emptyId);
            list.innerHTML = "";
            if (arr.length === 0) {
                empty.style.display = "";
                return;
            }
            empty.style.display = "none";
            arr.forEach(task => {
                let card = document.createElement('div');
                card.className = "hk-task-card";
                card.setAttribute("tabindex", "0");
                card.innerHTML = `
                    <div class="hk-task-header">
                        <span class="hk-room">${task.room}</span>
                        <span class="hk-type">${task.type}</span>
                        <span class="hk-badge ${getStepColor(task.priority)}" style="margin-left:12px;">${task.priority}</span>
                    </div>
                    <ul class="hk-task-steps">
                        ${task.steps.map((step, idx) => `
                            <li class="hk-task-step">
                                <input type="checkbox" aria-label="Mark step as completed" ${step.status === "Completed" ? "checked" : ""} data-task="${task.id}" data-step="${idx}" style="accent-color:#007bff;" />
                                <span>${step.name}</span>
                                <span class="hk-step-status ${getStepColor(step.status)}">${step.status}</span>
                            </li>
                        `).join('')}
                    </ul>
                    <div class="hk-task-actions">
                        <button type="button" class="hk-view-btn" data-id="${task.id}" aria-label="View Task Details"><i class="fa fa-eye"></i> View Task</button>
                        ${task.link ? `<a href="${task.link}" target="_blank" rel="noopener" class="hk-task-link"><i class="fa fa-external-link-alt"></i> Form</a>` : ""}
                    </div>
                `;
                list.appendChild(card);
            });
        }

        renderColumn('list-todo', 'empty-todo', todo);
        renderColumn('list-inprogress', 'empty-inprogress', inprogress);
        renderColumn('list-done', 'empty-done', done);
    }

    // Event listeners
    document.getElementById('hk-search').addEventListener('input', renderTasks);
    document.getElementById('hk-status').addEventListener('change', renderTasks);
    document.getElementById('hk-priority').addEventListener('change', renderTasks);
    document.getElementById('hk-date').addEventListener('change', renderTasks);
    document.getElementById('hk-clear').addEventListener('click', function() {
        document.getElementById('hk-search').value = "";
        document.getElementById('hk-status').value = "";
        document.getElementById('hk-priority').value = "";
        document.getElementById('hk-date').value = "";
        renderTasks();
    });

    // Step checkbox logic
    document.addEventListener('change', function(e) {
        if (e.target.matches('.hk-task-step input[type="checkbox"]')) {
            let tid = parseInt(e.target.getAttribute('data-task'));
            let sid = parseInt(e.target.getAttribute('data-step'));
            let task = tasks.find(t => t.id === tid);
            if (!task) return;
            let step = task.steps[sid];
            if (e.target.checked) {
                step.status = "Completed";
            } else {
                step.status = "Not Executed";
            }
            // If all steps completed, move to Done
            if (task.steps.every(s => s.status === "Completed")) {
                task.status = "Done";
            } else if (task.steps.some(s => s.status === "In Progress" || s.status === "Completed")) {
                task.status = "In Progress";
            } else {
                task.status = "To Do";
            }
            renderTasks();
        }
    });

    // Modal logic
    function closeModal() {
        document.getElementById('hk-modal').style.display = 'none';
        document.getElementById('hk-modal').setAttribute('aria-hidden', 'true');
    }
    document.addEventListener('click', function(e) {
        if (e.target.closest('.hk-view-btn')) {
            let id = parseInt(e.target.closest('.hk-view-btn').getAttribute('data-id'));
            let task = tasks.find(t => t.id === id);
            if (!task) return;
            let modalBody = document.getElementById('hk-modal-body');
            modalBody.innerHTML = `
                <div style="font-size:16px; font-weight:600; margin-bottom:8px;">Room ${task.room} - ${task.type}</div>
                <div style="margin-bottom:8px;"><strong>Priority:</strong> ${task.priority}</div>
                <div style="margin-bottom:8px;"><strong>Date:</strong> ${task.date}</div>
                <ul style="padding-left:18px;">
                    ${task.steps.map((step, idx) => `
                        <li style="margin-bottom:6px;">
                            <input type="checkbox" ${step.status === "Completed" ? "checked" : ""} disabled />
                            <span>${step.name}</span>
                            <span class="hk-step-status ${getStepColor(step.status)}">${step.status}</span>
                        </li>
                    `).join('')}
                </ul>
                ${task.link ? `<div style="margin-top:10px;"><a href="${task.link}" target="_blank" rel="noopener"><i class="fa fa-external-link-alt"></i> External Form</a></div>` : ""}
            `;
            let modal = document.getElementById('hk-modal');
            modal.style.display = 'flex';
            modal.setAttribute('aria-hidden', 'false');
            modal.focus();
        }
        // Close modal on background click
        if (e.target.classList.contains('hk-modal')) {
            closeModal();
        }
    });

    // Keyboard accessibility for modal
    document.getElementById('hk-modal').addEventListener('keydown', function(e) {
        if (e.key === "Escape") closeModal();
    });

    renderTasks();
    </script>
    {/literal}
</div>


