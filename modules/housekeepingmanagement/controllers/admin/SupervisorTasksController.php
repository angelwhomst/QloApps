<?php
if (!defined('_PS_VERSION_')) {
    exit; 
}

/**
 * SupervisorTasksController
 * 
 * This controller manages the admin interface for assigning housekeeping staff to rooms.
 * It extends ModuleAdminController, which gives it PrestaShop's admin functionality,
 * including toolbar, page header, templates, and list rendering.
 */
class SupervisorTasksController extends ModuleAdminController
{
    /**
     * Constructor
     * 
     * Initializes the controller, enables bootstrap styling,
     * and sets up the toolbar button for adding a new task.
     */
    public function __construct()
    {
        $this->bootstrap = true; 
        parent::__construct(); 

        $this->page_header_toolbar_btn['new_task'] = [
            'href' => $this->context->link->getAdminLink('SupervisorTasks') . '&addnewtask=1', 
            'desc' => $this->l('Assign Staff'), 
            'icon' => 'process-icon-new', 
        ];
    }

    /**
     * initPageHeaderToolbar
     * 
     * Override the default toolbar behavior to hide the assign task button
     * when the user is adding a new task.
     */
    public function initPageHeaderToolbar()
    {
        // Call parent to initialize toolbar first
        parent::initPageHeaderToolbar();

        // Hide only the "new_task" button if we're adding a new task
        if (Tools::isSubmit('addnewtask') && isset($this->page_header_toolbar_btn['new_task'])) {
            unset($this->page_header_toolbar_btn['new_task']);
        }
    }


    /**
     * render List
     * This method is responsible for rendering the task list table.
     */
    public function renderList()
    {
        if (!Tools::isSubmit('addnewtask')) {
            // Fetch the Smarty template for the supervisor tasks list
            return $this->context->smarty->fetch(
                _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/supervisor_tasks.tpl'
            );
        }

        return ''; 
    }

    /**
     * initContent
     * 
     * Main content rendering method.
     * This handles both the task list view and the "assign task" form view.
     */
    public function initContent()
    {
        if (Tools::isSubmit('addnewtask')) {
            // Sample data
            $staffList = ['John Doe', 'Jane Smith', 'Mary Johnson'];

            $this->context->smarty->assign([
                'staffList' => $staffList, 
                'current'   => self::$currentIndex, 
                'token'     => Tools::getAdminTokenLite('SupervisorTasks'), 
            ]);

            // Render the task assignment form 
            $this->content = $this->context->smarty->fetch(
                _PS_MODULE_DIR_ . 'housekeepingmanagement/views/templates/admin/task_assign_form.tpl'
            );

            parent::initContent();
        } else {
            parent::initContent();
        }
    }
}
