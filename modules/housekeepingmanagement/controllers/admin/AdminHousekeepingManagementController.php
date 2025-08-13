<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelBranchInformation.php');

class AdminHousekeepingManagementController extends ModuleAdminController
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

        // Add soft delete filter - only show non-deleted records
        $this->_where = 'AND a.`deleted` = 0';

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

        // add tabs 
        $this->tabs = array(
            'SOPs' => $this->l('SOP Management'),
            'RoomStatus' => $this->l('Room Status')
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
     * override processDelete to implement soft delete
     */
    public function processDelete()
    {
        if (Validate::isLoadedObject($object = $this->loadObject())) {
            // Implement soft delete
            $object->deleted = 1;
            if ($object->update()) {
                $this->redirect_after = self::$currentIndex.'&conf=1&token='.$this->token;
            } else {
                $this->errors[] = $this->l('An error occurred while deleting the object.');
            }
        } else {
            $this->errors[] = $this->l('An error occurred while deleting the object.');
        }
        
        return $object;
    }
    
    /**
     * oveerride processBulkDelete to implement soft delete for multiple records
     */
    public function processBulkDelete()
    {
        if (is_array($this->boxes) && !empty($this->boxes)) {
            $success = true;
            
            foreach ($this->boxes as $id) {
                $toDelete = new $this->className((int)$id);
                if (Validate::isLoadedObject($toDelete)) {
                    $toDelete->deleted = 1;
                    $success &= $toDelete->update();
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
        if (Tools::isSubmit('viewsop_model')) {
            return $this->renderSOPView();
        }

        // Get available room types for dropdown
        $roomTypeOptions = $this->getRoomTypeOptions();
        
        $this->fields_form = array(
            'legend' => array(
                'title' => $this->l('Standard Operating Procedure'),
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
                ),
                array(
                    'type' => 'hidden',
                    'name' => 'date_add'
                ),
                array(
                    'type' => 'hidden',
                    'name' => 'date_upd'
                ),
                array(
                    'type' => 'html',
                    'name' => 'steps_container',
                    'label' => $this->l('Steps'),
                    'html_content' => $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/steps_form.tpl')
                )
            ),
            'submit' => array(
                'title' => $this->l('Save'),
                'name' => 'submitAdd'.$this->table
            )
        );
        
        // handle steps data for editing
        if (Tools::isSubmit('updatehousekeeping_sop')) {
            $id_sop = (int)Tools::getValue('id_sop');
            if ($id_sop) {
                $sopStepModel = new SOPStepModel();
                $steps = $sopStepModel->getStepsBySOP($id_sop);
                
                $this->context->smarty->assign(array(
                    'steps' => $steps
                ));
            }
        }
        
        // load JS for steps management
        $this->addJS(_PS_MODULE_DIR_.'housekeepingmanagement/views/js/sop_steps.js');
        
        return parent::renderForm();
    }

    /**
     * render SOP details view
     */
    protected function renderSOPView()
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
        
        // fetch employee name
        $employee_name = '';
        if ($sopModel->id_employee) {
            $employee = new Employee((int)$sopModel->id_employee);
            if (Validate::isLoadedObject($employee)) {
                $employee_name = $employee->firstname . ' ' . $employee->lastname;
            }
        }
        
        $this->context->smarty->assign(array(
            'sop' => $sopModel,
            'steps' => $steps,
            'link' => $this->context->link,
            'employee_name' => $employee_name,
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/sop_view.tpl');
    }

    /**
     * process form submission
     */
    public function postProcess()
    {
        // process SOP form submission
        if (Tools::isSubmit('submitAddhousekeeping_sop')) {
            $id_sop = (int)Tools::getValue('id_sop');
            
            // validate required fields
            if (!Tools::getValue('title') || !Tools::getValue('description')) {
                $this->errors[] = $this->l('Title and description are required');
            }
            
            // validate steps
            $steps = Tools::getValue('step');
            if (!$steps || !is_array($steps) || count($steps) < 1) {
                $this->errors[] = $this->l('At least one step is required');
            }
            
            // if no errors, proceed with save
            if (empty($this->errors)) {
                // create or update SOP
                $sopModel = new SOPModel($id_sop);
                $sopModel->title = Tools::getValue('title');
                $sopModel->description = Tools::getValue('description');
                $sopModel->room_type = Tools::getValue('room_type');
                $sopModel->active = (int)Tools::getValue('active');
                $sopModel->deleted = 0; //  it's not deleted

                // Always set id_employee for new records
                if (!$id_sop) {
                    $sopModel->date_add = date('Y-m-d H:i:s');
                }
                $sopModel->id_employee = $this->context->employee->id;
                $sopModel->date_upd = date('Y-m-d H:i:s');
                
                // save SOP
                if ($sopModel->save()) {
                    // delete existing steps if editing
                    if ($id_sop) {
                        $sopStepModel = new SOPStepModel();
                        $sopStepModel->deleteStepsBySOP($id_sop);
                    }
                    
                    // create new steps
                    foreach ($steps as $index => $step) {
                        $sopStepModel = new SOPStepModel();
                        $sopStepModel->id_sop = $sopModel->id; 
                        $sopStepModel->step_order = $index + 1;
                        $sopStepModel->step_description = $step;
                        $sopStepModel->save();
                    }
                    
                    // set confirmation message
                    if ($id_sop) {
                        $this->confirmations[] = $this->l('SOP updated successfully');
                    } else {
                        Tools::redirectAdmin(self::$currentIndex.'&conf=4&token='.$this->token);
                    }
                } else {
                    $this->errors[] = $this->l('An error occurred while saving the SOP');
                }
            }
        }
        
        // process room status updates
        if (Tools::isSubmit('update_room_status')) {
            $id_room = (int)Tools::getValue('id_room');
            $status = Tools::getValue('status');
            
            if (RoomStatusModel::updateRoomStatus($id_room, $status, $this->context->employee->id)) {
                $this->confirmations[] = $this->l('Room status updated successfully');
            } else {
                $this->errors[] = $this->l('An error occurred while updating room status');
            }
        }
        
        return parent::postProcess();
    }

    /**
     * Ajax method to handle room status updates
     */
    public function ajaxProcessUpdateRoomStatus()
    {
        $response = array(
            'success' => false,
            'message' => ''
        );
        
        if (Tools::isSubmit('id_room') && Tools::isSubmit('status')) {
            $id_room = (int)Tools::getValue('id_room');
            $status = Tools::getValue('status');
            
            if (RoomStatusModel::updateRoomStatus($id_room, $status, $this->context->employee->id)) {
                $response['success'] = true;
                $response['message'] = $this->l('Room status updated successfully');

                // get updated summary
                $response['summary'] = RoomStatusModel::getRoomStatusSummary();
            } else {
                $response['message'] = $this->l('An error occurred while updating room status');
            }
        } else {
            $response['message'] = $this->l('Invalid parameters');
        }
        
        die(json_encode($response));
    }

    /**
     * display content based on active tab
     */
    public function initContent()
    {
        parent::initContent();

        $this->content = '';

        // determine which tab is active
        $activeTab = 'SOPs';
        if (Tools::getValue('tab') && isset($this->tabs[Tools::getValue('tab')])) {
            $activeTab = Tools::getValue('tab');
        }

        // generate content based on active tab
        if ($activeTab === 'RoomStatus') {
            $this->content .= $this->displayRoomStatusTab();
        } else {
            // default to SOPs tab
            if (Tools::isSubmit('addSOPModel') || Tools::isSubmit('updateSOPModel')) {
                $this->content .= $this->renderForm();
            } else {
                $this->content .= $this->renderList();
            }
        }

        //add tab nav
        $tabLinks = array();
        foreach ($this->tabs as $tabId => $tabLabel) {
            $tabLinks[] = array(
                'id' => $tabId,
                'label' => $tabLabel,
                'active' => ($activeTab === $tabId),
                'url' => $this->context->link->getAdminLink('AdminHousekeepingManagement').'&tab='.$tabId
            );
        }
        
        $this->context->smarty->assign(array(
            'content' => $this->content,
            'tabs' => $tabLinks
        ));
        
        $this->context->smarty->assign('content', $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/tabs.tpl'));
    }

    /**
     * render view for room status management
     */
    public function displayRoomStatusTab()
    {
        // get all hotel rooms
        $objHotelRoomInfo = new HotelRoomInformation();
        $rooms = $objHotelRoomInfo->getAllHotelRooms();
        
        // get room status data
        $roomStatusData = RoomStatusModel::getRoomStatusSummary();
        
        $this->context->smarty->assign(array(
            'rooms' => $rooms,
            'summary' => $roomStatusData,
            'status_cleaned' => RoomStatusModel::STATUS_CLEANED,
            'status_not_cleaned' => RoomStatusModel::STATUS_NOT_CLEANED,
            'status_failed_inspection' => RoomStatusModel::STATUS_FAILED_INSPECTION,
            'link' => $this->context->link
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/room_status.tpl');
    }

    /**
     * Get room type options for dropdown
     */
    protected function getRoomTypeOptions()
    {
        $roomTypes = array();
        
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
            // add "All Room Types" option
            $roomTypes[] = array(
                'id_option' => '',
                'name' => $this->l('All Room Types')
            );
            
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