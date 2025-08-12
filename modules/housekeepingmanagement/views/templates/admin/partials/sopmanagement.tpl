<div class="sop-management">
    <h3>Manage SOPs</h3>
    <form id="sopForm" class="form">
        <div class="form-group">
            <label for="title">Title (required)</label>
            <input type="text" id="title" name="title" class="form-control" required>
        </div>

        <div class="form-group">
            <label for="description">Description (required)</label>
            <textarea id="description" name="description" class="form-control" required></textarea>
        </div>

        <div class="form-group">
            <label for="roomType">Room Type (optional)</label>
            <select id="roomType" name="roomType" class="form-control">
                <option value="">Select Room Type</option>
                <option value="single">Single</option>
                <option value="double">Double</option>
                <option value="suite">Suite</option>
            </select>
        </div>

        <div class="form-group">
            <label for="sopSteps">SOP Steps (at least one required)</label>
            <div id="sopStepsContainer">
                <input type="text" name="sopSteps[]" class="form-control" required placeholder="Step 1">
            </div>
            <button type="button" class="btn btn-secondary" onclick="addSOPStep()">Add Step</button>
        </div>

        <button type="submit" class="btn btn-primary">Submit</button>
    </form>

    <h3>Existing SOPs</h3>
    <table id="sopTable" class="table">
        <thead>
            <tr>
                <th>SOP Title</th>
                <th>Room Type</th>
                <th>Created By</th>
                <th>Last Updated</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <!-- Populate with existing SOPs via JavaScript -->
        </tbody>
    </table>
</div>