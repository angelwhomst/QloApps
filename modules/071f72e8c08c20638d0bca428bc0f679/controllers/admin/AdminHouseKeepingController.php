<?php
class AdminHousekeepingManagementController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true; // enables bootstrap styles
        $this->table = 'housekeeping_tasks';  // your DB table (create this later)
        $this->className = 'HousekeepingTask'; // your model class (optional for ORM)
        $this->lang = false;

        parent::__construct();
    }

    public function renderList()
    {
        // Define fields for the list view
        $this->fields_list = [
            'id_task' => ['title' => $this->l('ID'), 'width' => 50],
            'task_name' => ['title' => $this->l('Task Name')],
            'status' => ['title' => $this->l('Status')],
        ];

        return parent::renderList();
    }

    // Optional: renderForm() for add/edit form

    // Optional: postProcess() for handling form submissions
}



