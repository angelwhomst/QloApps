<?php
/**
* NOTICE OF LICENSE
*
* This source file is subject to the Open Software License version 3.0
* that is bundled with this package in the file LICENSE.md
* It is also available through the world-wide-web at this URL:
* https://opensource.org/license/osl-3-0-php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to support@qloapps.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade this module to a newer
* versions in the future. If you wish to customize this module for your needs
* please refer to https://opensource.org/license/osl-3-0-php for more information.
*/

if (!defined('_PS_VERSION_')) {
    exit;
}

class AdminRoomStatusManagementController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;
        $this->table = 'housekeeping_room_status';
        $this->className = 'RoomStatusModel';
        $this->lang = false;
        $this->context = Context::getContext();
        $this->identifier = 'id_room_status';
        $this->_defaultOrderBy = 'date_upd';
        $this->_defaultOrderWay = 'DESC';
        $this->allow_export = true;

        parent::__construct();

        // define list fields
        $this->fields_list = array(
            'id_room_status' => array(
                'title' => $this->l('ID'),
                'align' => 'center',
                'class' => 'fixed-width-xs'
            ),
            'room_num' => array(
                'title' => $this->l('Room Number'),
                'filter_key' => 'hri!room_num',
                'callback' => 'displayRoomNumber'
            ),
            'hotel_name' => array(
                'title' => $this->l('Hotel'),
                'filter_key' => 'hbi!hotel_name'
            ),
            'room_type' => array(
                'title' => $this->l('Room Type'),
                'filter_key' => 'pl!name'
            ),
            'status' => array(
                'title' => $this->l('Status'),
                'align' => 'center',
                'type' => 'select',
                'list' => array(
                    RoomStatusModel::STATUS_CLEANED => $this->l('Cleaned'),
                    RoomStatusModel::STATUS_NOT_CLEANED => $this->l('Not Cleaned'),
                    RoomStatusModel::STATUS_FAILED_INSPECTION => $this->l('Failed Inspection')
                ),
                'filter_key' => 'a!status',
                'callback' => 'displayRoomStatus'
            ),
            'employee_name' => array(
                'title' => $this->l('Last Updated By'),
                'filter_key' => 'employee_name',
                'callback' => 'displayEmployeeName',
                'havingFilter' => true
            ),
            'date_upd' => array(
                'title' => $this->l('Last Updated'),
                'type' => 'datetime',
                'filter_key' => 'a!date_upd'
            )
        );

        // define bulk actions
        $this->bulk_actions = array(
            'mark_cleaned' => array(
                'text' => $this->l('Mark as Cleaned'),
                'icon' => 'icon-check text-success'
            ),
            'mark_not_cleaned' => array(
                'text' => $this->l('Mark as Not Cleaned'),
                'icon' => 'icon-times text-warning'
            ),
            'mark_failed' => array(
                'text' => $this->l('Mark as Failed Inspection'),
                'icon' => 'icon-exclamation-triangle text-danger'
            )
        );

        // custom actions for each row
        $this->addRowAction('edit');
        $this->addRowAction('viewroom');
    }

    /**
     * process bulk actions
     */
    public function processBulkMarkCleaned()
    {
        return $this->processBulkUpdateStatus(RoomStatusModel::STATUS_CLEANED);
    }

    public function processBulkMarkNotCleaned()
    {
        return $this->processBulkUpdateStatus(RoomStatusModel::STATUS_NOT_CLEANED);
    }

    public function processBulkMarkFailed()
    {
        return $this->processBulkUpdateStatus(RoomStatusModel::STATUS_FAILED_INSPECTION);
    }

    /**
     * updaate status for selected rooms
     */
    protected function processBulkUpdateStatus($status)
    {
        if (is_array($this->boxes) && !empty($this->boxes)) {
            $success = true;
            foreach ($this->boxes as $id) {
                $roomStatus = new RoomStatusModel($id);
                if (Validate::isLoadedObject($roomStatus)) {
                    $result = RoomStatusModel::updateRoomStatus(
                        $roomStatus->id_room,
                        $status,
                        $this->context->employee->id
                    );
                    $success &= $result;
                }
            }
            
            if ($success) {
                $this->confirmations[] = $this->l('Selected rooms status updated successfully');
            } else {
                $this->errors[] = $this->l('An error occurred while updating room status');
            }
        } else {
            $this->errors[] = $this->l('You must select at least one item to perform this action');
        }

        return $success;
    }

    /**
     * overrrride getList to join with room information
     */
    public function getList($id_lang, $order_by = null, $order_way = null, $start = 0, $limit = null, $id_lang_shop = false)
    {
        // add SQL tables and columns for joins
        $this->_select = '
        hri.`room_num`,
        hbl.`hotel_name`,
        pl.`name` AS room_type,
        CONCAT(e.`firstname`, " ", e.`lastname`) AS employee_name';

    $this->_join = '
        LEFT JOIN `'._DB_PREFIX_.'htl_room_information` hri ON (a.`id_room` = hri.`id`)
        LEFT JOIN `'._DB_PREFIX_.'htl_branch_info` hbi ON (hri.`id_hotel` = hbi.`id`)
        LEFT JOIN `'._DB_PREFIX_.'htl_branch_info_lang` hbl ON (hbi.`id` = hbl.`id` AND hbl.`id_lang` = '.(int)$id_lang.')
        LEFT JOIN `'._DB_PREFIX_.'product` p ON (hri.`id_product` = p.`id_product`)
        LEFT JOIN `'._DB_PREFIX_.'product_lang` pl ON (p.`id_product` = pl.`id_product` AND pl.`id_lang` = '.(int)$id_lang.')
        LEFT JOIN `'._DB_PREFIX_.'employee` e ON (a.`id_employee` = e.`id_employee`)';

        $this->_where = '';
        $this->_group = '';

        // call parent method to process list
        parent::getList($id_lang, $order_by, $order_way, $start, $limit, $id_lang_shop);

        // prrocess data for rooms that don't have status entries yet
        $this->processRoomsWithoutStatus($id_lang);
    }

    /**
     * process rooms that don't have status entries yet
     */
    protected function processRoomsWithoutStatus($id_lang)
    {
        // get rooms that don't have status entries
        $sql = '
        SELECT 
            hri.`id` AS id_room,
            hri.`room_num`,
            hbl.`hotel_name`,
            pl.`name` AS room_type,
            "'.pSQL(RoomStatusModel::STATUS_NOT_CLEANED).'" AS status,
            NULL AS id_employee,
            NULL AS employee_name,
            NULL AS date_upd
        FROM `'._DB_PREFIX_.'htl_room_information` hri
        LEFT JOIN `'._DB_PREFIX_.'htl_branch_info` hbi ON (hri.`id_hotel` = hbi.`id`)
        LEFT JOIN `'._DB_PREFIX_.'htl_branch_info_lang` hbl ON (hbi.`id` = hbl.`id` AND hbl.`id_lang` = '.(int)$id_lang.')
        LEFT JOIN `'._DB_PREFIX_.'product` p ON (hri.`id_product` = p.`id_product`)
        LEFT JOIN `'._DB_PREFIX_.'product_lang` pl ON (p.`id_product` = pl.`id_product` AND pl.`id_lang` = '.(int)$id_lang.')
        LEFT JOIN `'._DB_PREFIX_.'housekeeping_room_status` hrs ON (hri.`id` = hrs.`id_room`)
        WHERE hrs.`id_room_status` IS NULL';
        
        $result = Db::getInstance()->executeS($sql);
        
        if ($result) {
        foreach ($result as &$row) {
            if (!$row['employee_name']) {
                $row['employee_name'] = $this->l('N/A');
            }
            if (!$row['date_upd']) {
                $row['date_upd'] = '-';
            }
        }
        $this->_list = array_merge($this->_list, $result);
        $this->_listTotal += count($result);
    }
}
    /**
     * render the list toolbar
     */
    public function initToolbar()
    {
        parent::initToolbar();
        
        // Remove the Add New button since we don't directly create statuses
        unset($this->toolbar_btn['new']);
        
        // Add summary button
        $this->toolbar_btn['summary'] = array(
            'href' => self::$currentIndex.'&summary=1&token='.$this->token,
            'desc' => $this->l('View Summary'),
            'icon' => 'process-icon-stats'
        );
    }

    /**
     * init content based on requested action
     */
    public function initContent()
    {
        if (Tools::isSubmit('summary')) {
            $this->content = $this->renderSummaryView();
        } elseif (Tools::isSubmit('viewroom')) {
            $this->content = $this->renderRoomView();
        } elseif (Tools::isSubmit('updatehousekeeping_room_status')) {
            parent::initContent();
        } else {
            parent::initContent();
            
            // add status filter
            $statusCounts = $this->getStatusCounts();
            
            $this->context->smarty->assign(array(
                'status_counts' => $statusCounts,
                'status_cleaned' => RoomStatusModel::STATUS_CLEANED,
                'status_not_cleaned' => RoomStatusModel::STATUS_NOT_CLEANED,
                'status_failed' => RoomStatusModel::STATUS_FAILED_INSPECTION,
                'current_url' => $this->context->link->getAdminLink('AdminRoomStatusManagement')
            ));
            
            // add status filter above the list
            $statusFilter = $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/status_filter.tpl');
            $this->content = $statusFilter . $this->content;
        }
    }

    /**
     * render the summary view
     */
    protected function renderSummaryView()
    {
        // get summary data
        $summary = RoomStatusModel::getRoomStatusSummary();
        
        // get status by hotel
        $statusByHotel = $this->getStatusByHotel();
        
        // get rooms that need attention
        $needsAttention = $this->getRoomsThatNeedAttention();
        
        $this->context->smarty->assign(array(
            'summary' => $summary,
            'status_by_hotel' => $statusByHotel,
            'needs_attention' => $needsAttention,
            'status_cleaned' => RoomStatusModel::STATUS_CLEANED,
            'status_not_cleaned' => RoomStatusModel::STATUS_NOT_CLEANED,
            'status_failed' => RoomStatusModel::STATUS_FAILED_INSPECTION,
            'link' => $this->context->link
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/room_status_summary.tpl');
    }

    /**
     * render the room detail view
     */
    protected function renderRoomView()
    {
        $id_room = (int)Tools::getValue('id_room');
        
        if (!$id_room) {
            $this->errors[] = $this->l('Invalid room ID');
            return $this->renderList();
        }
        
        // get room details
        $roomInfo = RoomStatusModel::getRoomInfo($id_room);
        
        if (!$roomInfo) {
            $this->errors[] = $this->l('Room not found');
            return $this->renderList();
        }
        
        // get room status history
        $statusHistory = $this->getRoomStatusHistory($id_room);
        
        // get applicable SOPs for this room type
        $sops = SOPModel::getSOPs($roomInfo['room_type']);
        
        $this->context->smarty->assign(array(
            'room' => $roomInfo,
            'status_history' => $statusHistory,
            'sops' => $sops,
            'current_status' => $this->getCurrentRoomStatus($id_room),
            'status_cleaned' => RoomStatusModel::STATUS_CLEANED,
            'status_not_cleaned' => RoomStatusModel::STATUS_NOT_CLEANED,
            'status_failed' => RoomStatusModel::STATUS_FAILED_INSPECTION,
            'link' => $this->context->link
        ));
        
        return $this->context->smarty->fetch(_PS_MODULE_DIR_.'housekeepingmanagement/views/templates/admin/room_detail.tpl');
    }

    /**
     * get room status counts
     */
    protected function getStatusCounts()
    {
        return RoomStatusModel::getRoomStatusSummary();
    }

    /**
     * get status breakdown by hotel
     */
    protected function getStatusByHotel()
    {
        $id_lang = (int)$this->context->language->id;
        $sql = '
            SELECT 
                hbl.`hotel_name`,
                COUNT(DISTINCT hri.`id`) as total,
                SUM(CASE WHEN hrs.`status` = "'.pSQL(RoomStatusModel::STATUS_CLEANED).'" THEN 1 ELSE 0 END) as cleaned,
                SUM(CASE WHEN hrs.`status` = "'.pSQL(RoomStatusModel::STATUS_NOT_CLEANED).'" OR hrs.`status` IS NULL THEN 1 ELSE 0 END) as not_cleaned,
                SUM(CASE WHEN hrs.`status` = "'.pSQL(RoomStatusModel::STATUS_FAILED_INSPECTION).'" THEN 1 ELSE 0 END) as failed_inspection
            FROM `'._DB_PREFIX_.'htl_branch_info` hbi
            LEFT JOIN `'._DB_PREFIX_.'htl_branch_info_lang` hbl ON (hbi.`id` = hbl.`id` AND hbl.`id_lang` = '.$id_lang.')
            LEFT JOIN `'._DB_PREFIX_.'htl_room_information` hri ON (hbi.`id` = hri.`id_hotel`)
            LEFT JOIN `'._DB_PREFIX_.'housekeeping_room_status` hrs ON (hri.`id` = hrs.`id_room`)
            GROUP BY hbi.`id`
            ORDER BY hbl.`hotel_name`';
        
        return Db::getInstance()->executeS($sql);
    }

    /**
     * get rooms that need attention (not cleaned and have recent checkouts)
     */
    protected function getRoomsThatNeedAttention()
    {
        return RoomStatusModel::getRoomsThatNeedCleaning();
    }

    /**
     * get room status history
     */
    protected function getRoomStatusHistory($id_room)
    {
        $sql = '
            SELECT 
                a.`status`,
                a.`date_upd`,
                CONCAT(e.`firstname`, " ", e.`lastname`) as employee_name
            FROM `'._DB_PREFIX_.'housekeeping_room_status_history` a
            LEFT JOIN `'._DB_PREFIX_.'employee` e ON (a.`id_employee` = e.`id_employee`)
            WHERE a.`id_room` = '.(int)$id_room.'
            ORDER BY a.`date_upd` DESC
            LIMIT 10';
        
        return Db::getInstance()->executeS($sql);
    }

    /**
     * getcurrent room status
     */
    protected function getCurrentRoomStatus($id_room)
    {
        $sql = '
            SELECT 
                a.`status`,
                a.`date_upd`,
                CONCAT(e.`firstname`, " ", e.`lastname`) as employee_name
            FROM `'._DB_PREFIX_.'housekeeping_room_status` a
            LEFT JOIN `'._DB_PREFIX_.'employee` e ON (a.`id_employee` = e.`id_employee`)
            WHERE a.`id_room` = '.(int)$id_room;
        
        $result = Db::getInstance()->getRow($sql);
        
        if (!$result) {
            return array(
                'status' => RoomStatusModel::STATUS_NOT_CLEANED,
                'date_upd' => null,
                'employee_name' => null
            );
        }
        
        return $result;
    }

    /**
     * render form for editing room status
     */
    public function renderForm()
    {
        // check if we have a valid room status ID
        if (Tools::isSubmit('id_room_status')) {
            $id_room_status = (int)Tools::getValue('id_room_status');
            $roomStatus = new RoomStatusModel($id_room_status);
            
            if (!Validate::isLoadedObject($roomStatus)) {
                $this->errors[] = $this->l('Invalid room status ID');
                return $this->renderList();
            }
            
            // get room information
            $roomInfo = RoomStatusModel::getRoomInfo($roomStatus->id_room);
            
            if (!$roomInfo) {
                $this->errors[] = $this->l('Room not found');
                return $this->renderList();
            }
            
            $this->fields_form = array(
                'legend' => array(
                    'title' => sprintf($this->l('Edit Status for Room %s'), $roomInfo['room_num']),
                    'icon' => 'icon-edit'
                ),
                'input' => array(
                    array(
                        'type' => 'hidden',
                        'name' => 'id_room',
                        'value' => $roomStatus->id_room
                    ),
                    array(
                        'type' => 'text',
                        'label' => $this->l('Room Number'),
                        'name' => 'room_num',
                        'value' => $roomInfo['room_num'],
                        'disabled' => true,
                        'required' => false
                    ),
                    array(
                        'type' => 'text',
                        'label' => $this->l('Hotel'),
                        'name' => 'hotel_name',
                        'value' => $roomInfo['hotel_name'],
                        'disabled' => true,
                        'required' => false
                    ),
                    array(
                        'type' => 'text',
                        'label' => $this->l('Room Type'),
                        'name' => 'room_type',
                        'value' => $roomInfo['room_type'],
                        'disabled' => true,
                        'required' => false
                    ),
                    array(
                        'type' => 'select',
                        'label' => $this->l('Status'),
                        'name' => 'status',
                        'required' => true,
                        'options' => array(
                            'query' => array(
                                array(
                                    'id' => RoomStatusModel::STATUS_CLEANED,
                                    'name' => $this->l('Cleaned')
                                ),
                                array(
                                    'id' => RoomStatusModel::STATUS_NOT_CLEANED,
                                    'name' => $this->l('Not Cleaned')
                                ),
                                array(
                                    'id' => RoomStatusModel::STATUS_FAILED_INSPECTION,
                                    'name' => $this->l('Failed Inspection')
                                )
                            ),
                            'id' => 'id',
                            'name' => 'name'
                        )
                    ),
                    array(
                        'type' => 'textarea',
                        'label' => $this->l('Notes'),
                        'name' => 'notes',
                        'rows' => 3,
                        'desc' => $this->l('Optional notes about the room status (will be saved in history)')
                    )
                ),
                'submit' => array(
                    'title' => $this->l('Save'),
                    'name' => 'submitAddRoomStatus'
                )
            );
            
            return parent::renderForm();
        } else {
            $this->errors[] = $this->l('Invalid request');
            return $this->renderList();
        }
    }

    /**
     * process form submission
     */
    public function postProcess()
    {
        if (Tools::isSubmit('submitAddRoomStatus')) {
            $id_room = (int)Tools::getValue('id_room');
            $status = Tools::getValue('status');
            $notes = Tools::getValue('notes');
            
            // validate status
            $valid_statuses = array(
                RoomStatusModel::STATUS_CLEANED,
                RoomStatusModel::STATUS_NOT_CLEANED,
                RoomStatusModel::STATUS_FAILED_INSPECTION
            );
            
            if (!in_array($status, $valid_statuses)) {
                $this->errors[] = $this->l('Invalid status value');
            }
            
            if (empty($this->errors)) {
                // update room status
                $result = RoomStatusModel::updateRoomStatus(
                    $id_room,
                    $status,
                    $this->context->employee->id,
                    $notes
                );
                
                if ($result) {
                    $this->confirmations[] = $this->l('Room status updated successfully');
                    
                    // redirect back to list
                    Tools::redirectAdmin(self::$currentIndex.'&conf=4&token='.$this->token);
                } else {
                    $this->errors[] = $this->l('An error occurred while updating room status');
                }
            }
        }
        
        // handle AJAX status update
        if (Tools::isSubmit('ajax')) {
            if (Tools::getValue('action') == 'updateRoomStatus') {
                $this->ajaxProcessUpdateRoomStatus();
            }
        }
        
        return parent::postProcess();
    }

    /**
     * AJAX handler for updating room status
     */
    public function ajaxProcessUpdateRoomStatus()
    {
        header('Content-Type: application/json');
        
        $response = array('success' => false);
        
        if (Tools::isSubmit('id_room') && Tools::isSubmit('status')) {
            $id_room = (int)Tools::getValue('id_room');
            $status = Tools::getValue('status');
            $notes = Tools::getValue('notes', '');
            
            // validate status
            $valid_statuses = array(
                RoomStatusModel::STATUS_CLEANED,
                RoomStatusModel::STATUS_NOT_CLEANED,
                RoomStatusModel::STATUS_FAILED_INSPECTION
            );
            
            if (in_array($status, $valid_statuses)) {
                $result = RoomStatusModel::updateRoomStatus(
                    $id_room,
                    $status,
                    $this->context->employee->id,
                    $notes
                );
                
                if ($result) {
                    $response['success'] = true;
                    $response['message'] = $this->l('Room status updated successfully');
                    $response['summary'] = RoomStatusModel::getRoomStatusSummary();
                } else {
                    $response['message'] = $this->l('An error occurred while updating room status');
                }
            } else {
                $response['message'] = $this->l('Invalid status value');
            }
        } else {
            $response['message'] = $this->l('Missing required parameters');
        }
        
        die(json_encode($response));
    }

    /**
     * display room number with link to room details
     */
    public function displayRoomNumber($roomNum, $rowData)
    {
        if (isset($rowData['id_room'])) {
            $link = $this->context->link->getAdminLink('AdminRoomStatusManagement').'&viewroom=1&id_room='.$rowData['id_room'];
            return '<a href="'.$link.'">'.$roomNum.'</a>';
        }
        return $roomNum;
    }

    /**
     * display formatted room status with color-coding
     */
    public function displayRoomStatus($status, $rowData)
    {
        switch ($status) {
            case RoomStatusModel::STATUS_CLEANED:
                return '<span class="badge badge-success">'.$this->l('Cleaned').'</span>';
            case RoomStatusModel::STATUS_NOT_CLEANED:
                return '<span class="badge badge-warning">'.$this->l('Not Cleaned').'</span>';
            case RoomStatusModel::STATUS_FAILED_INSPECTION:
                return '<span class="badge badge-danger">'.$this->l('Failed Inspection').'</span>';
            default:
                return $status;
        }
    }

    /**
     * display employee name or N/A if not available
     */
    public function displayEmployeeName($name, $rowData)
    {
        return $name ? $name : $this->l('N/A');
    }
}