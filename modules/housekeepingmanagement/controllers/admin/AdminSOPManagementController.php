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

        // always assign steps for the form
        $steps = array();
        $id_sop = (int)Tools::getValue('id_sop');
        if ($id_sop) {
            $steps = SOPStepModel::getStepsBySOP($id_sop);
        }
        if (empty($steps)) {
            $steps = array(array('step_order' => 1, 'step_description' => ''));
        }
        $this->context->smarty->assign(array('steps' => $steps));
        
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

        // add JS for SweetAlert translations
        Media::addJsDef(array(
            'empty_steps_error_title' => $this->l('Form Error'),
            'empty_steps_error_msg' => $this->l('All steps must have a description'),
            'delete_sop_title' => $this->l('Delete SOP'),
            'delete_sop_confirm' => $this->l('Are you sure you want to delete this SOP?'),
            'delete_confirm_btn' => $this->l('Yes, delete it'),
            'delete_cancel_btn' => $this->l('Cancel')
        ));

        // add CSS and JS for improved UI
        $this->addCSS(_PS_MODULE_DIR_.'housekeepingmanagement/views/css/housekeeping-admin.css');
        $this->addJS(_PS_MODULE_DIR_.'housekeepingmanagement/views/js/sop_steps.js');

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
        
        // default empty step if none exist
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
        if (Tools::isSubmit('submitAddhousekeeping_sop')) {
            // get form data
            $id_sop = (int)Tools::getValue('id_sop');
            $title = Tools::getValue('title');
            $description = Tools::getValue('description');
            $room_type = Tools::getValue('room_type');
            $active = (int)Tools::getValue('active', 1);
            $steps = Tools::getValue('step');

            // DEBUG: Check what is posted
            error_log('POST: '.print_r($_POST, true), 3, _PS_MODULE_DIR_.'housekeepingmanagement/logs/error_logs.log');
            error_log('STEPS: '.print_r(Tools::getValue('step'), true), 3, _PS_MODULE_DIR_.'housekeepingmanagement/logs/error_logs.log');
            
            // validate form data
            if (empty($title)) $this->errors[] = $this->l('Title is required');
            if (empty($description)) $this->errors[] = $this->l('Description is required');
            if (empty($steps) || !is_array($steps)) $this->errors[] = $this->l('At least one step is required');
                
            // if no errors, save SOP
            if (empty($this->errors)) {
                if ($id_sop) {
                    $sop = new SOPModel($id_sop);
                } else {
                    $sop = new SOPModel();
                    $sop->date_add = date('Y-m-d H:i:s');
                    $sop->deleted = 0;
                }
                $sop->id_employee = (int)$this->context->employee->id ?: 1;
                $sop->title = $title;
                $sop->description = $description;
                $sop->room_type = $room_type;
                $sop->active = $active;
                $sop->date_upd = date('Y-m-d H:i:s');

                if ($sop->save()) {
                    $id_sop = $sop->id;
                    // always delete old steps and insert new
                    SOPStepModel::deleteStepsBySOP($id_sop);
                    foreach ($steps as $i => $desc) {
                        if (trim($desc) !== '') {
                            $step = new SOPStepModel();
                            $step->id_sop = $id_sop;
                            $step->step_order = $i + 1;
                            $step->step_description = $desc;
                            $step->deleted = 0;
                            $step->save();
                        }
                    }
                    Tools::redirectAdmin(self::$currentIndex.'&conf=3&token='.$this->token);
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

        // fetch employee name
        $employee_name = '';
        if ($sopModel->id_employee) {
            $employee = new Employee((int)$sopModel->id_employee);
            if (Validate::isLoadedObject($employee)) {
                $employee_name = $employee->firstname . ' ' . $employee->lastname;
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
            'link' => $this->context->link,
            'employee_name' => $employee_name,
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

    /**
     * custom list rendering
     */
    public function renderList()
    {
        // use default list for export actions
        if (Tools::isSubmit('export'.$this->table)) {
            return parent::renderList();
        }

        // load CSS/JS and translations needed for list page (SweetAlert, module JS/CSS)
        Media::addJsDef(array(
            'delete_sop_title'      => $this->l('Delete SOP'),
            'delete_sop_confirm'    => $this->l('Are you sure you want to delete this SOP?'),
            'delete_confirm_btn'    => $this->l('Yes, delete it'),
            'delete_cancel_btn'     => $this->l('Cancel'),
        ));
        // add SweetAlert2 CDN and module JS/CSS
        $this->addJS('https://cdn.jsdelivr.net/npm/sweetalert2@11');
        $this->addJS(_PS_MODULE_DIR_.'housekeepingmanagement/views/js/sop_steps.js');
        $this->addCSS(_PS_MODULE_DIR_.'housekeepingmanagement/views/css/housekeeping-admin.css');

        //process filter submission
        $this->processFilter();

        //initialize fitler values
        $id_sop_filter = Tools::getValue('id_sop_filter', '');
        $title_filter = Tools::getValue('title_filter', '');
        $room_type_filter = Tools::getValue('room_type_filter', '');
        $active_filter = Tools::getValue('active_filter', '');
        $date_from       = Tools::getValue('date_from', '');
        $date_to         = Tools::getValue('date_to', '');

        //pagination
        $page = (int)Tools::getValue('page', 1);
        $limit = 10; // items per page

        // buiild SQL filters with sanitized values (avoid PDO prepare)
        $sql_filters = '';
        if ($id_sop_filter !== '') {
            $sql_filters .= ' AND s.id_sop = ' . (int)$id_sop_filter;
        }
        if ($title_filter !== '') {
            $sql_filters .= " AND s.title LIKE '%" . pSQL($title_filter) . "%'";
        }
        if ($room_type_filter !== '') {
            $sql_filters .= ' AND s.room_type = ' . (int)$room_type_filter;
        }
        if ($active_filter !== '') {
            $sql_filters .= ' AND s.active = ' . (int)$active_filter;
        }

        // date filters: validate and apply
        if ($date_from !== '') {
            $ts = strtotime($date_from);
            if ($ts !== false) {
                $sql_filters .= " AND s.date_add >= '" . pSQL(date('Y-m-d 00:00:00', $ts)) . "'";
            }
        }
        if ($date_to !== '') {
            $ts = strtotime($date_to);
            if ($ts !== false) {
                $sql_filters .= " AND s.date_add <= '" . pSQL(date('Y-m-d 23:59:59', $ts)) . "'";
            }
        }

        // count total
        $count_sql = 'SELECT COUNT(DISTINCT s.id_sop) FROM `' . _DB_PREFIX_ . 'housekeeping_sop` s WHERE s.deleted = 0' . $sql_filters;
        $total = (int)Db::getInstance()->getValue($count_sql);
        $pages = ($total > 0) ? ceil($total / $limit) : 1;
        $offset = ($page > 1) ? (($page - 1) * $limit) : 0;
        if ($offset < 0) {
            $offset = 0;
        }

        // get data with filtering and pagination
        $sql = 'SELECT s.*, COUNT(st.id_sop_step) as steps_count
                FROM `' . _DB_PREFIX_ . 'housekeeping_sop` s
                LEFT JOIN `' . _DB_PREFIX_ . 'housekeeping_sop_step` st ON s.id_sop = st.id_sop
                WHERE s.deleted = 0 ' . $sql_filters . '
                GROUP BY s.id_sop
                ORDER BY ' . pSQL($this->_defaultOrderBy) . ' ' . pSQL($this->_defaultOrderWay) . '
                LIMIT ' . (int)$offset . ', ' . (int)$limit;

        $results = Db::getInstance()->executeS($sql);

        $sops = [];
        if ($results) {
            foreach ($results as $row) {
                $roomTypeName = $this->l('All Room Types');
                if (!empty($row['room_type'])) {
                    $objProduct = new Product($row['room_type'], false, $this->context->language->id);
                    if (Validate::isLoadedObject($objProduct)) {
                        $roomTypeName = $objProduct->name;
                    }
                }

                $sops[] = array(
                    'id_sop' => $row['id_sop'],
                    'title' => $row['title'],
                    'room_type_name' => $roomTypeName,
                    'active' => $row['active'],
                    'steps_count' => $row['steps_count'],
                    'date_add' => $row['date_add'],
                    'date_upd' => $row['date_upd'],
                );
            }
        }

        // get room types for filter dropdown
        $room_types = $this->getRoomTypeOptions();

        // build filter params for pagination links
        $filter_params = '';
        if ($id_sop_filter !== '')    $filter_params .= '&id_sop_filter=' . (int)$id_sop_filter;
        if ($title_filter !== '')     $filter_params .= '&title_filter=' . urlencode($title_filter);
        if ($room_type_filter !== '') $filter_params .= '&room_type_filter=' . (int)$room_type_filter;
        if ($active_filter !== '')    $filter_params .= '&active_filter=' . (int)$active_filter;
        if ($date_from !== '')        $filter_params .= '&date_from=' . urlencode($date_from);
        if ($date_to !== '')          $filter_params .= '&date_to=' . urlencode($date_to);

        $this->context->smarty->assign(array(
            'sops' => $sops,
            'link' => $this->context->link,
            'id_sop_filter' => $id_sop_filter,
            'title_filter' => $title_filter,
            'room_type_filter' => $room_type_filter,
            'active_filter' => $active_filter,
            'date_from' => $date_from,
            'date_to' => $date_to,
            'room_types' => $room_types,
            'pagination_page' => $page,
            'pagination_pages' => $pages,
            'pagination_total' => $total,
            'pagination_limit' => $limit,
            'filter_params' => ltrim($filter_params, '&'),
            'token' => $this->token,
        ));

        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/sop_list.tpl');
    }

    /**
     * process filter form submission
     */
    public function processFilter()
    {
        // reset filters
        if (Tools::isSubmit('submitResetSOP')) {
            $this->processResetFilters();
        }
        
        // apply filters
        if (Tools::isSubmit('submitFilterButtonSOP')) {
            $this->processFilterParams();
        }
    }

    /**
     * save filter parameters
     */
    protected function processFilterParams()
    {
        $filters = array(
            'id_sop_filter',
            'title_filter',
            'room_type_filter',
            'active_filter'
        );
        
        foreach ($filters as $filter) {
            if (Tools::getValue($filter) !== false) {
                $value = Tools::getValue($filter);
                if ($value != '') {
                    $this->context->cookie->{$filter} = $value;
                } else {
                    unset($this->context->cookie->{$filter});
                }
            }
        }
        
        // always reset to page 1 when filtering
        $this->context->cookie->page = 1;
        $this->context->cookie->write();
    }

    /**
     * reset all filters
     * signature must match AdminControllerCore::processResetFilters($list_id = null)
     */
    public function processResetFilters($list_id = null)
    {
        $filters = array(
            'id_sop_filter',
            'title_filter',
            'room_type_filter',
            'active_filter',
            'page'
        );
        
        foreach ($filters as $filter) {
            unset($this->context->cookie->{$filter});
        }
        
        $this->context->cookie->write();
        Tools::redirectAdmin($this->context->link->getAdminLink('AdminSOPManagement'));
    }
}