<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelBranchInformation.php');

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

        //  filter to only show active records
        $this->_where = 'AND a.`deleted` = 0';

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
                'filter_key' => 'a!room_type',
                'callback' => 'displayRoomType'
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
     * display room type name
     */
    public function displayRoomType($roomTypeId, $row)
    {
        if (empty($roomTypeId)) {
            return $this->l('All Room Types');
        }
        
        $objProduct = new Product($roomTypeId, false, $this->context->language->id);
        if (Validate::isLoadedObject($objProduct)) {
            return $objProduct->name;
        }
        
        return $roomTypeId;
    }

    /**
     * override delete method to implement soft delete
     */
    public function processDelete()
    {
        if (Validate::isLoadedObject($object = $this->loadObject())) {
            // Implement soft delete instead of hard delete
            $object->deleted = 1;
            $object->active = 0; // a;so deactivate it
            
            if ($object->update()) {
                $this->redirect_after = self::$currentIndex.'&conf=1&token='.$this->token;
            } else {
                $this->errors[] = $this->l('An error occurred while deleting the object.').' <b>'.$this->table.'</b> '.$this->l('(cannot load object)');
            }
        } else {
            $this->errors[] = $this->l('An error occurred while deleting the object.').' <b>'.$this->table.'</b> '.$this->l('(cannot load object)');
        }
        
        return $object;
    }
    
    /**
     * implement bulk soft delete
     */
    public function processBulkDelete()
    {
        if (is_array($this->boxes) && !empty($this->boxes)) {
            $success = true;
            
            foreach ($this->boxes as $id) {
                $object = new $this->className((int)$id);
                if (Validate::isLoadedObject($object)) {
                    $object->deleted = 1;
                    $object->active = 0;
                    $success &= $object->update();
                } else {
                    $success = false;
                }
            }
            
            if ($success) {
                $this->redirect_after = self::$currentIndex.'&conf=2&token='.$this->token;
            } else {
                $this->errors[] = $this->l('An error occurred while deleting selection.');
            }
        } else {
            $this->errors[] = $this->l('You must select at least one element to delete.');
        }
    }

    /**
     * render form for adding/editing SOPs
     */
    public function renderForm()
    {
        // Get available room types for dropdown
        $roomTypeOptions = $this->getRoomTypeOptions();
        
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
                ),
                array(
                    'type' => 'hidden',
                    'name' => 'deleted',
                    'value' => 0
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
                    $sop->date_add = date('Y-m-d H:i:s');
                    $sop->id_employee = $this->context->employee->id;
                    $sop->deleted = 0; // Ensure deleted flag is set to 0 for new records
                }
                
                $sop->title = $title;
                $sop->description = $description;
                $sop->room_type = $room_type;
                $sop->active = $active;
                $sop->date_upd = date('Y-m-d H:i:s');
                
                if ($sop->save()) {
                    // delete existing steps
                    if ($id_sop) {
                        SOPStepModel::deleteStepsBySOP($id_sop);
                    }
                    
                    // save steps
                    foreach ($steps as $index => $step) {
                        if (!empty($step)) {
                            $sopStep = new SOPStepModel();
                            $sopStep->id_sop = $sop->id;
                            $sopStep->step_order = $index + 1;
                            $sopStep->step_description = $step;
                            $sopStep->save();
                        }
                    }
                    
                    if ($id_sop) {
                        $this->confirmations[] = $this->l('SOP updated successfully');
                    } else {
                        Tools::redirectAdmin(self::$currentIndex.'&conf=3&token='.$this->token);
                    }
                } else {
                    $this->errors[] = $this->l('Error saving SOP');
                }
            }
        }
        
        return parent::postProcess();
    }

    /**
     * render SOP details view
     */
    public function renderView()
    {
        $id_sop = (int)Tools::getValue('id_sop');
        
        if (!$id_sop) {
            $this->errors[] = $this->l('Invalid SOP ID');
            return $this->renderList();
        }
        
        $sopModel = new SOPModel($id_sop);
        
        if (!Validate::isLoadedObject($sopModel) || $sopModel->deleted == 1) {
            $this->errors[] = $this->l('SOP not found');
            return $this->renderList();
        }
        
        $sopStepModel = new SOPStepModel();
        $steps = $sopStepModel->getStepsBySOP($id_sop);
        
        // get room type name
        $roomTypeName = $this->l('All Room Types');
        if (!empty($sopModel->room_type)) {
            $objProduct = new Product($sopModel->room_type, false, $this->context->language->id);
            if (Validate::isLoadedObject($objProduct)) {
                $roomTypeName = $objProduct->name;
            }
        }
        
        // preepare data for view
        $this->context->smarty->assign(array(
            'sop' => array(
                'id_sop' => $sopModel->id,
                'title' => $sopModel->title,
                'description' => $sopModel->description,
                'room_type' => $roomTypeName,
                'active' => $sopModel->active,
                'date_add' => $sopModel->date_add,
                'date_upd' => $sopModel->date_upd
            ),
            'steps' => $steps,
            'link' => $this->context->link
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/sop_view.tpl');
    }

    /**
     * get room type options for dropdown
     */
    protected function getRoomTypeOptions()
    {
        $roomTypes = array();
        
        // afd "All Room Types" option
        $roomTypes[] = array(
            'id_option' => '',
            'name' => $this->l('All Room Types')
        );
        
        // get room types from product table where hotel room is set
        $sql = 'SELECT p.id_product, pl.name 
                FROM '._DB_PREFIX_.'product p
                LEFT JOIN '._DB_PREFIX_.'product_lang pl ON (p.id_product = pl.id_product AND pl.id_lang = '.(int)$this->context->language->id.')
                WHERE p.id_product IN (
                    SELECT id_product FROM '._DB_PREFIX_.'htl_room_type
                )
                ORDER BY pl.name ASC';
        
        $result = Db::getInstance()->executeS($sql);
        
        if ($result) {
            foreach ($result as $row) {
                $roomTypes[] = array(
                    'id_option' => $row['id_product'],
                    'name' => $row['name']
                );
            }
        }
        
        return $roomTypes;
    }
}