<!-- Housekeeping Management - Clean Task Board View -->
<div class="housekeeping-dashboard" style="padding: 20px; font-family: Arial, sans-serif; background: #f5f6f7;">

    <link rel="stylesheet" href="{$smarty.const._MODULE_DIR_}housekeepingmanagement/views/css/housekeeping-task-board.css" />

    <div class="hk-task-board" style="padding: 10px 0; max-width:1200px; margin:0 auto;">
        <div class="hk-header">
            <div class="hk-progress" aria-live="polite">
                <div id="hk-progress-text" style="font-weight:700; font-size:18px;">Task Done: 0/0</div>
                <div id="hk-progressbar" class="hk-progress-bar" role="progressbar" aria-valuemin="0" aria-valuemax="0" aria-valuenow="0" aria-valuetext="Task Done: 0/0" aria-label="Task completion progress"><div id="hk-progress-fill" class="hk-progress-fill"></div></div>
            </div>
            <div class="hk-filters" role="region" aria-label="Filters">
                <input id="hk-search" type="search" placeholder="Search room number or name" aria-label="Search tasks" />
                <select id="hk-status" aria-label="Status filter">
                    <option value="">All Status</option>
                    <option value="To Do">To Do</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Done">Done</option>
                </select>
                <select id="hk-priority" aria-label="Priority filter">
                    <option value="">Priority</option>
                    <option value="High">High</option>
                    <option value="Medium">Medium</option>
                    <option value="Low">Low</option>
                </select>
                <input id="hk-date" type="date" aria-label="Deadline date filter" />
                <button id="hk-clear" class="hk-btn" aria-label="Clear filters">Clear</button>
            </div>
        </div>

        <div class="hk-columns" aria-live="polite">
            <div class="hk-col" id="col-todo" aria-labelledby="col-todo-title">
                <h3 id="col-todo-title">To Do <span id="cnt-todo" class="hk-badge not">0</span></h3>
                <div class="hk-empty" id="empty-todo">No tasks to do.</div>
                <div id="list-todo"></div>
            </div>
            <div class="hk-col" id="col-inprogress" aria-labelledby="col-inprogress-title">
                <h3 id="col-inprogress-title">In Progress <span id="cnt-inprogress" class="hk-badge ip">0</span></h3>
                <div class="hk-empty" id="empty-inprogress">No tasks in progress.</div>
                <div id="list-inprogress"></div>
            </div>
            <div class="hk-col" id="col-done" aria-labelledby="col-done-title">
                <h3 id="col-done-title">Done <span id="cnt-done" class="hk-badge ok">0</span></h3>
                <div class="hk-empty" id="empty-done">No tasks completed yet.</div>
                <div id="list-done"></div>
            </div>
        </div>

        <div id="hk-modal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">Task Details</h4>
                    </div>
                    <div class="modal-body" id="hk-modal-body"></div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {literal}
    <script>
    (function(){
        function currentUrlBase(){ var u = window.location.href.split('#')[0]; return u.indexOf('?')>-1 ? u+'&' : u+'?'; }
        var state = { q:'', status:'', priority:'', date:'' };
        var endpoints = {
            fetch: currentUrlBase() + 'ajax=1&action=fetchTasks',
            toggle: currentUrlBase() + 'ajax=1&action=toggleStep',
            detail: currentUrlBase() + 'ajax=1&action=getTaskDetail'
        };

        function el(id){ return document.getElementById(id); }
        function priorityClass(p){ var v=(p||'').toLowerCase(); if(v==='high')return 'high'; if(v==='medium')return 'medium'; return 'low'; }
        function escapeHtml(s){ return String(s||'').replace(/[&<>"]|'/g, function(c){return({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'}[c]);}); }
        function formatDate(d){ try{ var dt=new Date((d||'').replace(' ','T')); return dt.toLocaleString(); }catch(e){ return d||''; } }

        function renderBoard(data){
            ['todo','inprogress','done'].forEach(function(k){
                var list = el('list-'+k), empty=el('empty-'+k), cnt=el('cnt-'+k);
                list.innerHTML='';
                cnt.textContent = (data[k]||[]).length;
                if(!data[k] || !data[k].length){ empty.style.display='block'; return; } else { empty.style.display='none'; }
                (data[k]||[]).forEach(function(card){ list.appendChild(renderCard(card)); });
            });
            var done = data.summary?data.summary.done:0, total = data.summary?data.summary.total:0;
            var text = 'Task Done: '+done+'/'+total;
            el('hk-progress-text').textContent = text;
            el('hk-progress-fill').style.width = (total?Math.round(done/total*100):0)+'%';
            var pb = el('hk-progressbar');
            if (pb) { pb.setAttribute('aria-valuemin','0'); pb.setAttribute('aria-valuemax', String(total)); pb.setAttribute('aria-valuenow', String(done)); pb.setAttribute('aria-valuetext', text); }
        }

        function renderCard(card){
            var div=document.createElement('div'); div.className='hk-card';
            div.innerHTML =
                '<div class="hk-room">Room '+escapeHtml(card.room.number)+' <span style="font-weight:400;color:#666;">— '+escapeHtml(card.room.type)+'</span></div>'+
                '<div class="hk-meta"><span class="hk-badge '+priorityClass(card.priority)+'">'+escapeHtml(card.priority)+'</span>'+
                '<span><i class="icon-time"></i> '+formatDate(card.deadline)+'</span></div>'+
                '<div class="hk-step-summary"><span class="hk-step-count"></span><button class="hk-btn hk-toggle" data-toggle>Show steps</button></div>'+
                '<div class="hk-steps"></div>'+
                '<div class="hk-actions">'+
                    '<button class="hk-btn primary" data-view="'+card.id_task+'">View Task</button>'+
                '</div>';
            var stepsWrap = div.querySelector('.hk-steps');
            (card.steps||[]).forEach(function(st){ stepsWrap.appendChild(renderStep(card.id_task, st)); });
            var completed=(card.steps||[]).filter(function(s){return s.status==='Completed';}).length;
            var total=(card.steps||[]).length; var stepCount=div.querySelector('.hk-step-count'); stepCount.textContent = total? (completed+'/'+total+' steps completed') : 'No steps';
            if (card.links && card.links.length){
                var linksBar = document.createElement('div'); linksBar.className='hk-meta';
                card.links.forEach(function(l){ var a=document.createElement('a'); a.href=l.href; a.target='_blank'; a.rel='noopener'; a.className='hk-link'; a.textContent=l.label; linksBar.appendChild(a); });
                div.appendChild(linksBar);
            }
            div.addEventListener('click', function(e){ var b=e.target.closest('[data-view]'); if(!b) return; openDetail(b.getAttribute('data-view')); });
            div.addEventListener('click', function(e){ var t=e.target.closest('[data-toggle]'); if(!t) return; var isOpen=div.classList.toggle('expanded'); t.textContent = isOpen ? 'Hide steps' : 'Show steps'; });
            return div;
        }

        function renderStep(idTask, st){
            var row=document.createElement('div'); row.className='hk-step';
            var cls = st.status==='Completed'?'ok':(st.status==='In Progress'?'ip':'not');
            row.innerHTML = '<div class="label">'+escapeHtml(st.label)+'</div>'+
                '<div style="display:flex; align-items:center; gap:8px;">'+
                '<input type="checkbox" class="hk-step-checkbox" aria-label="Mark '+escapeHtml(st.label)+' completed" '+(st.status==='Completed'?'checked ':'')+'data-task="'+idTask+'" data-step="'+st.id_sop_step+'" />'+
                '<select aria-label="'+escapeHtml(st.label)+' status" data-task="'+idTask+'" data-step="'+st.id_sop_step+'">'+
                    '<option '+(st.status==='Not Executed'?'selected':'')+'>Not Executed</option>'+
                    '<option '+(st.status==='In Progress'?'selected':'')+'>In Progress</option>'+
                    '<option '+(st.status==='Completed'?'selected':'')+'>Completed</option>'+
                '</select>'+
                '<span class="hk-status '+cls+'">'+st.status+'</span></div>';
            var selectEl = row.querySelector('select');
            var checkboxEl = row.querySelector('.hk-step-checkbox');
            selectEl.addEventListener('change', function(ev){
                var status = ev.target.value; var idStep=ev.target.getAttribute('data-step'); var idTask = ev.target.getAttribute('data-task');
                var badge=row.querySelector('.hk-status'); var cls = status==='Completed'?'ok':(status==='In Progress'?'ip':'not'); badge.textContent=status; badge.className='hk-status '+cls;
                checkboxEl.checked = (status==='Completed');
                var xhr = new XMLHttpRequest(); xhr.open('POST', endpoints.toggle, true); xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
                xhr.onload=function(){ fetchData(); }; xhr.send('id_task='+encodeURIComponent(idTask)+'&id_sop_step='+encodeURIComponent(idStep)+'&status='+encodeURIComponent(status));
            });
            checkboxEl.addEventListener('change', function(ev){
                var checked = !!ev.target.checked; var idStep=ev.target.getAttribute('data-step'); var idTask = ev.target.getAttribute('data-task');
                var status = checked ? 'Completed' : 'Not Executed';
                selectEl.value = status;
                var badge=row.querySelector('.hk-status'); var cls = status==='Completed'?'ok':(status==='In Progress'?'ip':'not'); badge.textContent=status; badge.className='hk-status '+cls;
                var xhr = new XMLHttpRequest(); xhr.open('POST', endpoints.toggle, true); xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
                xhr.onload=function(){ fetchData(); }; xhr.send('id_task='+encodeURIComponent(idTask)+'&id_sop_step='+encodeURIComponent(idStep)+'&checked='+(checked?'1':'0'));
            });
            return row;
        }

        function openDetail(idTask){ var xhr=new XMLHttpRequest(); xhr.open('GET', endpoints.detail+'&id_task='+encodeURIComponent(idTask), true); xhr.onload=function(){ try{ var r=JSON.parse(xhr.responseText||'{}'); if(r.success) renderDetail(r.task);}catch(e){} }; xhr.send(); }
        function renderDetail(task){
            var html = '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">'+
                       '<h3 style="margin:0;">Room '+escapeHtml(task.room.number)+' <small>— '+escapeHtml(task.room.type)+'</small></h3>'+
                       '<span class="hk-badge '+priorityClass(task.priority)+'">'+escapeHtml(task.priority)+'</span></div>'+
                       '<div style="color:#666; margin-bottom:10px;"><i class="icon-time"></i> '+formatDate(task.deadline)+'</div>'+
                       '<div>'+(task.steps||[]).map(function(st){ var c=st.status==='Completed'?'ok':(st.status==='In Progress'?'ip':'not'); return '<div class="hk-step"><div class="label">'+escapeHtml(st.label)+'</div><div><span class="hk-status '+c+'">'+st.status+'</span></div></div>'; }).join('')+'</div>';
            var body=document.getElementById('hk-modal-body'); body.innerHTML=html; if(window.jQuery && jQuery.fn.modal){ jQuery('#hk-modal').modal('show'); }
        }

        function fetchData(){
            var params='q='+encodeURIComponent(state.q||'')+'&status='+encodeURIComponent(state.status||'')+'&priority='+encodeURIComponent(state.priority||'')+'&date='+encodeURIComponent(state.date||'');
            var xhr=new XMLHttpRequest(); xhr.open('POST', endpoints.fetch, true); xhr.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
            xhr.onload=function(){ try{ var data=JSON.parse(xhr.responseText||'{}'); renderBoard(data);}catch(e){} }; xhr.send(params);
        }

        // bind controls
        document.getElementById('hk-search').addEventListener('input', function(e){ state.q=e.target.value; fetchData(); });
        document.getElementById('hk-status').addEventListener('change', function(e){ state.status=e.target.value; fetchData(); });
        document.getElementById('hk-priority').addEventListener('change', function(e){ state.priority=e.target.value; fetchData(); });
        document.getElementById('hk-date').addEventListener('change', function(e){ state.date=e.target.value; fetchData(); });
        document.getElementById('hk-clear').addEventListener('click', function(){ state={q:'',status:'',priority:'',date:''}; document.getElementById('hk-search').value=''; document.getElementById('hk-status').value=''; document.getElementById('hk-priority').value=''; document.getElementById('hk-date').value=''; fetchData(); });

        // init
        fetchData();
    })();
    </script>
    {/literal}
</div>


