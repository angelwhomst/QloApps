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

require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelBranchInformation.php');

class RoomStatusModel extends ObjectModel
{
    public $id_room_status;
    public $id_room;
    public $room_num;
    public $status;
    public $notes;
    public $assigned_staff_id;
    public $date_add;
    public $date_upd;

    // Status Constants
    const STATUS_NOT_CLEANED = 'Not Cleaned';
    const STATUS_CLEANED = 'Cleaned';
    const STATUS_FAILED_INSPECTION = 'Failed Inspection';
    const STATUS_TO_BE_INSPECTED = 'To Be Inspected';
    const STATUS_UNASSIGNED = 'Unassigned';

    /**
     * @see ObjectModel::$definition
     */
    public static $definition = array(
        'table' => 'housekeeping_room_status',
        'primary' => 'id_room_status',
        'fields' => array(
            'id_room' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'room_num' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 50),
            'status' => array('type' => self::TYPE_STRING, 'validate' => 'isGenericName', 'required' => true, 'size' => 20),
            'notes' => array('type' => self::TYPE_HTML, 'validate' => 'isCleanHtml', 'size' => 65535),
            'assigned_staff_id' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId'),
            'date_add' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate'),
        ),
    );

    /**
     * Update room status and save to database
     * 
     * @param int $id_room
     * @param string $status
     * @param int $assigned_staff_id
     * @param string $notes
     * @return bool
     */
    public static function updateRoomStatus($id_room, $status, $assigned_staff_id = null, $notes = null)
    {
        // Get room information
        $roomInfo = self::getRoomInfo($id_room);
        
        if (!$roomInfo) {
            return false;
        }
        
        // Check if status record exists
        $id_room_status = self::getRoomStatusId($id_room);
        
        if ($id_room_status) {
            // Update existing record
            $roomStatus = new RoomStatusModel($id_room_status);
        } else {
            // Create new record
            $roomStatus = new RoomStatusModel();
            $roomStatus->id_room = $id_room;
            $roomStatus->room_num = $roomInfo['room_num'];
            $roomStatus->date_add = date('Y-m-d H:i:s');
        }
        
        // Update status
        $roomStatus->status = $status;
        
        // Set notes if provided
        if ($notes !== null) {
            $roomStatus->notes = $notes;
        }
        
        // Set assigned staff if provided
        if ($assigned_staff_id !== null) {
            $roomStatus->assigned_staff_id = $assigned_staff_id;
        }
        
        $roomStatus->date_upd = date('Y-m-d H:i:s');
        
        // Save to database
        return $roomStatus->save();
    }
    
    /**
     * Get room information from HotelRoomInformation
     * 
     * @param int $id_room
     * @return array|bool
     */
    public static function getRoomInfo($id_room)
    {
        $id_lang = (int)Context::getContext()->language->id;
        $sql = new DbQuery();
        $sql->select('hri.id, hri.id_hotel, hri.id_product, hri.room_num, hbl.hotel_name, pl.name as room_type')
            ->from('htl_room_information', 'hri')
            ->innerJoin('htl_branch_info', 'hbi', 'hri.id_hotel = hbi.id')
            ->innerJoin('htl_branch_info_lang', 'hbl', 'hbi.id = hbl.id AND hbl.id_lang = '.$id_lang)
            ->innerJoin('product_lang', 'pl', 'hri.id_product = pl.id_product AND pl.id_lang = '.$id_lang)
            ->where('hri.id = '.(int)$id_room);
        
        $result = Db::getInstance()->getRow($sql);
        
        return $result;
    }
    
    /**
     * Get room status ID from database
     * 
     * @param int $id_room
     * @return int|bool
     */
    public static function getRoomStatusId($id_room)
    {
        $sql = new DbQuery();
        $sql->select('id_room_status')
            ->from('housekeeping_room_status')
            ->where('id_room = '.(int)$id_room);
        
        return Db::getInstance()->getValue($sql);
    }
    
    /**
     * Get room status summary counts
     * 
     * @return array
     */
    public static function getRoomStatusSummary()
    {
        // Get total rooms count
        $totalRooms = (int)Db::getInstance()->getValue('SELECT COUNT(*) FROM '._DB_PREFIX_.'htl_room_information');
        
        // Initialize summary
        $summary = array(
            'total' => $totalRooms,
            'cleaned' => 0,
            'not_cleaned' => 0,
            'failed_inspection' => 0
        );
        
        // Get counts by status
        $sql = new DbQuery();
        $sql->select('status, COUNT(*) as count')
            ->from('housekeeping_room_status')
            ->groupBy('status');
        
        $results = Db::getInstance()->executeS($sql);
        
        if ($results) {
            foreach ($results as $row) {
                if ($row['status'] == self::STATUS_CLEANED) {
                    $summary['cleaned'] = (int)$row['count'];
                } elseif ($row['status'] == self::STATUS_NOT_CLEANED) {
                    $summary['not_cleaned'] = (int)$row['count'];
                } elseif ($row['status'] == self::STATUS_FAILED_INSPECTION) {
                    $summary['failed_inspection'] = (int)$row['count'];
                }
            }
        }
        
        // Rooms without status are considered not cleaned
        $summary['not_cleaned'] += ($totalRooms - ($summary['cleaned'] + $summary['not_cleaned'] + $summary['failed_inspection']));
        
        return $summary;
    }
    
    /**
     * Get rooms that need attention (not cleaned or failed inspection)
     * 
     * @param int $limit
     * @return array
     */
    public static function getRoomsNeedingAttention($limit = null)
    {
        $id_lang = (int)Context::getContext()->language->id;
        $sql = new DbQuery();
        $sql->select('hrs.*, hri.room_num, hbl.hotel_name, pl.name as room_type, CONCAT(e.firstname, " ", e.lastname) as assigned_staff')
            ->from('housekeeping_room_status', 'hrs')
            ->innerJoin('htl_room_information', 'hri', 'hrs.id_room = hri.id')
            ->innerJoin('htl_branch_info', 'hbi', 'hri.id_hotel = hbi.id')
            ->innerJoin('htl_branch_info_lang', 'hbl', 'hbi.id = hbl.id AND hbl.id_lang = '.$id_lang)
            ->innerJoin('product_lang', 'pl', 'hri.id_product = pl.id_product AND pl.id_lang = '.$id_lang)
            ->leftJoin('employee', 'e', 'hrs.assigned_staff_id = e.id_employee')
            ->where('hrs.status IN ("'.self::STATUS_NOT_CLEANED.'", "'.self::STATUS_FAILED_INSPECTION.'")')
            ->orderBy('hrs.date_upd DESC');
        
        if ($limit) {
            $sql->limit($limit);
        }
        
        return Db::getInstance()->executeS($sql);
    }
    
    /**
     * Get room status history
     * 
     * @param int $id_room
     * @param int $limit
     * @return array
     */
    public static function getRoomStatusHistory($id_room, $limit = 10)
    {
        $sql = new DbQuery();
        $sql->select('rsh.*, CONCAT(e.firstname, " ", e.lastname) as employee_name')
            ->from('housekeeping_room_status_history', 'rsh')
            ->leftJoin('employee', 'e', 'rsh.id_employee = e.id_employee')
            ->where('rsh.id_room = '.(int)$id_room)
            ->orderBy('rsh.date_add DESC')
            ->limit($limit);
        
        return Db::getInstance()->executeS($sql);
    }
    
    /**
     * Save status history when status changes
     * 
     * @param int $id_room
     * @param string $status
     * @param string $notes
     * @param int $id_employee
     * @return bool
     */
    public static function saveStatusHistory($id_room, $status, $notes = null, $id_employee = null)
    {
        // Insert into history table
        return Db::getInstance()->insert('housekeeping_room_status_history', array(
            'id_room' => (int)$id_room,
            'status' => pSQL($status),
            'notes' => pSQL($notes),
            'id_employee' => $id_employee ? (int)$id_employee : null,
            'date_add' => date('Y-m-d H:i:s')
        ));
    }
    
    /**
     * Get status counts by hotel
     * 
     * @return array
     */
    public static function getStatusCountsByHotel()
    {
        $id_lang = (int)Context::getContext()->language->id;
        $sql = 'SELECT 
                hbi.id as id_hotel,
                hbl.hotel_name,
                COUNT(DISTINCT hri.id) as total_rooms,
                SUM(CASE WHEN hrs.status = "'.self::STATUS_CLEANED.'" THEN 1 ELSE 0 END) as cleaned,
                SUM(CASE WHEN hrs.status = "'.self::STATUS_NOT_CLEANED.'" THEN 1 ELSE 0 END) as not_cleaned,
                SUM(CASE WHEN hrs.status = "'.self::STATUS_FAILED_INSPECTION.'" THEN 1 ELSE 0 END) as failed_inspection,
                SUM(CASE WHEN hrs.id_room_status IS NULL THEN 1 ELSE 0 END) as no_status
            FROM 
                '._DB_PREFIX_.'htl_branch_info hbi
            LEFT JOIN 
                '._DB_PREFIX_.'htl_branch_info_lang hbl ON (hbi.id = hbl.id AND hbl.id_lang = '.$id_lang.')
            LEFT JOIN 
                '._DB_PREFIX_.'htl_room_information hri ON hbi.id = hri.id_hotel
            LEFT JOIN 
                '._DB_PREFIX_.'housekeeping_room_status hrs ON hri.id = hrs.id_room
            GROUP BY 
                hbi.id
            ORDER BY 
                hbl.hotel_name';
        
        $results = Db::getInstance()->executeS($sql);
        
        // Rooms without status are considered not cleaned
        if ($results) {
            foreach ($results as &$row) {
                $row['not_cleaned'] += $row['no_status'];
                unset($row['no_status']);
            }
        }
        
        return $results;
    }
}