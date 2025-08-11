<form id="sop-form" class="needs-validation" novalidate>
  <input type="hidden" id="sop-id" value="">

  <div class="form-row">
    <div class="form-group col-12">
      <label for="sop-title">Title <span class="text-danger">*</span></label>
      <input type="text" class="form-control" id="sop-title" placeholder="e.g. Standard Room Clean" required>
      <div class="invalid-feedback" id="sop-title-error">Title is required.</div>
    </div>
  </div>

  <div class="form-row">
    <div class="form-group col-12">
      <label for="sop-description">Description <span class="text-danger">*</span></label>
      <textarea id="sop-description" class="form-control" rows="3" required></textarea>
      <div class="invalid-feedback" id="sop-description-error">Description is required.</div>
    </div>
  </div>

  <div class="form-row">
    <div class="form-group col-md-6">
      <label for="sop-room-type">Room Type</label>
      <select id="sop-room-type" class="form-control">
        <option value="">-- Any --</option>
        <option value="Standard">Standard</option>
        <option value="Deluxe">Deluxe</option>
        <option value="Suite">Suite</option>
      </select>
    </div>

    <div class="form-group col-md-6">
      <label>Steps <span class="text-danger">*</span></label>
      <div id="sop-steps" class="mb-2">
        <!-- initial step injected by JS -->
      </div>
      <button type="button" id="sop-add-step" class="btn btn-sm btn-outline-secondary">Add step</button>
      <div class="invalid-feedback d-block" id="sop-steps-error" style="display:none;">At least one step is required.</div>
    </div>
  </div>

  <div class="d-flex justify-content-end mt-3">
    <button type="button" id="sop-cancel" class="btn btn-link mr-2">Cancel</button>
    <button type="submit" id="sop-save" class="btn btn-success">Save SOP</button>
  </div>
</form>
