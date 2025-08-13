<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class AdminSOPManagementController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->table = 'housekeeping_sop';
        $this->className = 'SOPModel';
        $this->lang = false;
        $this->context = Context::getContext();
        $this->identifier = 'id_sop';
        $this->_defaultOrderBy = 'date_upd';
        $this->_defaultOrderWay = 'DESC';
        $this->allow_export = true;

        parent::__construct();

        $this->addRowAction('edit');
        $this->addRowAction('delete');
        $this->addRowAction('view');
        $this->bulk_actions = array(
            'delete' => array(
                'text' => $this->l('Delete selected'),
                'confirm' => $this->l('Delete selected items?'),
                'icon' => 'icon-trash'
            )
        );

        $this->fields_list = array(
            'id_sop' => array(
                'title' => $this->l('ID'),
                'align' => 'center',
                'class' => 'fixed-width-xs'
            ),
            'title' => array(
                'title' => $this->l('Title'),
                'filter_key' => 'a!title'
            ),
            'room_type' => array(
                'title' => $this->l('Room Type'),
                'filter_key' => 'a!room_type'
            ),
            'active' => array(
                'title' => $this->l('Active'),
                'align' => 'center',
                'active' => 'status',
                'type' => 'bool',
                'class' => 'fixed-width-sm'
            ),
            'date_add' => array(
                'title' => $this->l('Created'),
                'type' => 'datetime'
            ),
            'date_upd' => array(
                'title' => $this->l('Updated'),
                'type' => 'datetime'
            )
        );
    }

    /**
     * render list of SOPs
     */
    public function renderList()
    {
        $this->page_header_toolbar_btn['new_sop'] = array(
            'href' => self::$currentIndex.'&addSOPModel&token='.$this->token,
            'desc' => $this->l('Add New SOP'),
            'icon' => 'process-icon-new'
        );
        
        return parent::renderList();
    }

    /**
     * render SOP form for adding/editing
     */
    public function renderForm()
    {
        // Get room types from hotelreservationsystem module
        $roomTypeOptions = array();
        $objRoomType = new HotelRoomType();
        $roomTypes = $objRoomType->getAllRoomTypes();
        
        if ($roomTypes && is_array($roomTypes)) {
            foreach ($roomTypes as $roomType) {
                $roomTypeOptions[] = array(
                    'id_option' => $roomType['room_type'],
                    'name' => $roomType['room_type']
                );
            }
        }

        $this->fields_form = array(
            'legend' => array(
                'title' => $this->l('SOP Information'),
                'icon' => 'icon-file-text'
            ),
            'input' => array(
                array(
                    'type' => 'text',
                    'label' => $this->l('Title'),
                    'name' => 'title',
                    'required' => true,
                    'class' => 'fixed-width-xxl'
                ),
                array(
                    'type' => 'textarea',
                    'label' => $this->l('Description'),
                    'name' => 'description',
                    'required' => true,
                    'autoload_rte' => true,
                    'rows' => 5
                ),
                array(
                    'type' => 'select',
                    'label' => $this->l('Room Type'),
                    'name' => 'room_type',
                    'options' => array(
                        'query' => $roomTypeOptions,
                        'id' => 'id_option',
                        'name' => 'name'
                    )
                ),
                array(
                    'type' => 'switch',
                    'label' => $this->l('Active'),
                    'name' => 'active',
                    'is_bool' => true,
                    'values' => array(
                        array(
                            'id' => 'active_on',
                            'value' => 1,
                            'label' => $this->l('Yes')
                        ),
                        array(
                            'id' => 'active_off',
                            'value' => 0,
                            'label' => $this->l('No')
                        )
                    )
                )
            ),
            'submit' => array(
                'title' => $this->l('Save')
            )
        );

        // add steps fields (dynamic)
        $this->fields_form['input'][] = array(
            'type' => 'html',
            'name' => 'steps_container',
            'html_content' => $this->getStepsHtml()
        );

        return parent::renderForm();
    }

    /**
     * generate HTML for steps section
     */
    protected function getStepsHtml()
    {
        $steps = array();
        
        // If editing, get existing steps
        if (Tools::isSubmit('id_sop')) {
            $id_sop = (int)Tools::getValue('id_sop');
            $steps = SOPStepModel::getStepsBySOP($id_sop);
        }
        
        // Default empty step if none exist
        if (empty($steps)) {
            $steps = array(array('step_order' => 1, 'step_description' => ''));
        }
        
        $this->context->smarty->assign(array(
            'steps' => $steps
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/steps_form.tpl');
    }

    /**
     * process form submission
     */
    public function postProcess()
    {
        if (Tools::isSubmit('submitAddSOPModel')) {
            // get form data
            $id_sop = (int)Tools::getValue('id_sop');
            $title = Tools::getValue('title');
            $description = Tools::getValue('description');
            $room_type = Tools::getValue('room_type');
            $active = (int)Tools::getValue('active', 1);
            $steps = Tools::getValue('step');
            
            // validate form data
            if (empty($title)) {
                $this->errors[] = $this->l('Title is required');
            }
            
            if (empty($description)) {
                $this->errors[] = $this->l('Description is required');
            }
            
            if (empty($steps) || !is_array($steps)) {
                $this->errors[] = $this->l('At least one step is required');
            }
            
            // if no errors, save SOP
            if (empty($this->errors)) {
                if ($id_sop) {
                    $sop = new SOPModel($id_sop);
                } else {
                    $sop = new SOPModel();
                }
                
                $sop->title = $title;
                $sop->description = $description;
                $sop->room_type = $room_type;
                $sop->active = $active;
                $sop->id_employee = $this->context->employee->id;
                
                if ($id_sop) {
                    $success = $sop->update();
                } else {
                    $success = $sop->add();
                }
                
                if ($success) {
                    // save steps
                    SOPStepModel::deleteStepsBySOP($sop->id_sop);
                    
                    foreach ($steps as $order => $description) {
                        if (!empty($description)) {
                            $step = new SOPStepModel();
                            $step->id_sop = $sop->id_sop;
                            $step->step_order = $order + 1;
                            $step->step_description = $description;
                            $step->add();
                        }
                    }
                    
                    if ($id_sop) {
                        $this->confirmations[] = $this->l('SOP updated successfully');
                    } else {
                        $this->confirmations[] = $this->l('SOP created successfully');
                    }
                    
                    if (Tools::isSubmit('submitAddSOPModelAndStay')) {
                        Tools::redirectAdmin(self::$currentIndex.'&id_sop='.$sop->id_sop.'&updateSOPModel&conf=4&token='.$this->token);
                    } else {
                        Tools::redirectAdmin(self::$currentIndex.'&conf=4&token='.$this->token);
                    }
                } else {
                    $this->errors[] = $this->l('An error occurred while saving the SOP');
                }
            }
        }
        
        return parent::postProcess();
    }

    /**
     * render view of a SOP
     */
    public function renderView()
    {
        if (!($id_sop = (int)Tools::getValue('id_sop')) || !Validate::isLoadedObject($sop = new SOPModel($id_sop))) {
            $this->errors[] = $this->l('SOP not found');
            return $this->renderList();
        }
        
        $steps = SOPStepModel::getStepsBySOP($id_sop);
        
        $this->context->smarty->assign(array(
            'sop' => array(
                'id_sop' => $sop->id_sop,
                'title' => $sop->title,
                'description' => $sop->description,
                'room_type' => $sop->room_type,
                'active' => $sop->active,
                'date_add' => $sop->date_add,
                'date_upd' => $sop->date_upd
            ),
            'steps' => $steps,
            'employee_name' => $this->getEmployeeName($sop->id_employee)
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/sop_view.tpl');
    }
    
    /**
     * get employee name by ID
     */
    protected function getEmployeeName($id_employee)
    {
        $employee = new Employee($id_employee);
        if (Validate::isLoadedObject($employee)) {
            return $employee->firstname.' '.$employee->lastname;
        }
        return '';
    }
}