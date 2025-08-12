function fetchRooms() {
    const filter = document.getElementById('roomFilter').value;
    fetch(`path/to/your/api/for/rooms?filter=${filter}`)
        .then(response => response.json())
        .then(data => {
            const tbody = document.querySelector('#roomTable tbody');
            tbody.innerHTML = '';
            data.forEach(room => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${room.number}</td>
                    <td>${room.type}</td>
                    <td>${room.status}</td>
                    <td>${room.assignedStaff}</td>
                    <td>${room.lastUpdated}</td>
                `;
                tbody.appendChild(row);
            });
        });
}