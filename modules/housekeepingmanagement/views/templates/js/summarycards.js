function updateSummaryCards() {
    fetch('path/to/your/api/for/summary')
        .then(response => response.json())
        .then(data => {
            document.getElementById('totalRooms').innerText = data.totalRooms;
            document.getElementById('cleanedRooms').innerText = data.cleanedRooms;
            document.getElementById('notCleanedRooms').innerText = data.notCleanedRooms;
            document.getElementById('failedInspections').innerText = data.failedInspections;
        });
}

// Call functions on page load
window.onload = function() {
    fetchSOPs(); // Fetch SOPs
    fetchRooms(); // Fetch Rooms
    updateSummaryCards(); // Update summary cards
};