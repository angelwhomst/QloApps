document.addEventListener('DOMContentLoaded', function() {
    const from = document.querySelector('.from-date');
    const to = document.querySelector('.to-date');
    const btn = document.getElementById('dateFilterBtn');
    const dropdown = document.getElementById('dateFilterDropdown');
    const tabs = document.querySelectorAll('.tabs .btn');
    const prioritySelect = document.querySelector('.filters select');
    const tableBody = document.getElementById('roomTableBody');
    const paginationContainer = document.querySelector('div[style*="text-align: right"]');

    const rowsPerPage = 7;
    let currentPage = 1;
    let filteredRows = [];

    // Date input behavior
    function setDateBehavior(input) {
        input.addEventListener('focus', () => input.type = 'date');
        input.addEventListener('blur', () => { if (!input.value) input.type = 'text'; });
    }
    setDateBehavior(from);
    setDateBehavior(to);

    btn.addEventListener('click', function(e) {
        e.stopPropagation();
        dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    });
    document.addEventListener('click', () => dropdown.style.display = 'none');

    // Get filtered rows
    function getFilteredRows() {
        const statusFilter = document.querySelector('.tabs .btn.active')?.getAttribute('data-filter') || 'all';
        const priorityFilter = prioritySelect.value;
        const fromDate = from.value ? new Date(from.value) : null;
        const toDate = to.value ? new Date(to.value) : null;

        return Array.from(tableBody.querySelectorAll('tr')).filter(row => {
            const status = row.querySelector('td:nth-child(7)').innerText.trim();
            const priority = row.querySelector('td:nth-child(6)').innerText.trim();
            const deadlineText = row.querySelector('td:nth-child(4)').innerText.trim();
            const deadline = deadlineText ? new Date(deadlineText) : null;

            let show = true;
            if (statusFilter !== 'all' && status !== statusFilter) show = false;
            if (priorityFilter && priority !== priorityFilter) show = false;
            if (fromDate && deadline && deadline < fromDate) show = false;
            if (toDate && deadline && deadline > toDate) show = false;

            return show;
        });
    }

    // Render table with pagination
    function renderTable() {
        const oldNoDataRow = document.getElementById('noDataRow');
        if (oldNoDataRow) oldNoDataRow.remove();

        filteredRows = getFilteredRows();
        const totalPages = Math.ceil(filteredRows.length / rowsPerPage);
        if (currentPage > totalPages) currentPage = totalPages || 1;

        tableBody.querySelectorAll('tr').forEach(row => row.style.display = 'none');

        if (filteredRows.length === 0) {
            const noDataRow = document.createElement('tr');
            noDataRow.id = 'noDataRow';
            noDataRow.innerHTML = `<td colspan="8" style="text-align:center; padding:20px; color:#888;">
                No task assignment found
            </td>`;
            tableBody.appendChild(noDataRow);

            renderPagination(0); // clear pagination
            return;
        }

        const start = (currentPage - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        filteredRows.slice(start, end).forEach(row => row.style.display = '');

        renderPagination(totalPages);
    }

    // Render pagination buttons dynamically
    function renderPagination(totalPages) {
        paginationContainer.innerHTML = ''; 

        const prevBtn = document.createElement('button');
        prevBtn.className = 'btn';
        prevBtn.innerText = 'Previous';
        prevBtn.disabled = currentPage === 1;
        prevBtn.addEventListener('click', () => { currentPage--; renderTable(); });
        paginationContainer.appendChild(prevBtn);

        for (let i = 1; i <= totalPages; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.className = 'btn';
            pageBtn.innerText = i;
            if (i === currentPage) pageBtn.classList.add('active');
            pageBtn.addEventListener('click', () => { currentPage = i; renderTable(); });
            paginationContainer.appendChild(pageBtn);
        }

        const nextBtn = document.createElement('button');
        nextBtn.className = 'btn';
        nextBtn.innerText = 'Next';
        nextBtn.disabled = currentPage === totalPages || totalPages === 0;
        nextBtn.addEventListener('click', () => { currentPage++; renderTable(); });
        paginationContainer.appendChild(nextBtn);
    }

    // Event listeners for filters
    tabs.forEach(tab => tab.addEventListener('click', () => { 
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        currentPage = 1;
        renderTable();
    }));

    [prioritySelect, from, to].forEach(el => el.addEventListener('change', () => { currentPage = 1; renderTable(); }));

    // Initial render
    renderTable();

    // Edit button
    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const taskId = btn.getAttribute('data-task-id');
            const url = new URL(window.location.href);
            url.searchParams.set('edit_task', '1');
            url.searchParams.set('id_task', taskId);
            window.location.href = url.toString();
        });
    });

    // Delete button
    document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const taskId = btn.getAttribute('data-task-id');

            Swal.fire({
                title: 'Are you sure?',
                text: "Do you really want to delete this task?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#E74C3C',
                cancelButtonColor: '#7A7A7A',
                confirmButtonText: 'Yes, delete it',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    const ajaxUrl = window.location.href; 

                    fetch(`${ajaxUrl}&ajax=1&action=deleteTask&id_task=${taskId}`, {
                        method: 'GET',
                        headers: { 'Content-Type': 'application/json' }
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            const row = btn.closest('tr');
                            row.remove();
                            Swal.fire('Deleted!', data.message, 'success');
                        } else {
                            Swal.fire('Error!', data.message, 'error');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        Swal.fire('Error!', 'An error occurred.', 'error');
                    });
                }
            });
        });
    });
});
