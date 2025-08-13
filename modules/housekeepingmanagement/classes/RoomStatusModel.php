<?php
if (!defined('_PS_VERSION_')) {
    exit;
}

class RoomStatusModel extends ObjectModel
{
    public $id_room_status;
    public $id_room;
    public $status;
    public $id_employee;
    public $date_upd;

    // room status constants
    const STATUS_CLEANED = 'CLEANED';
    const STATUS_NOT_CLEANED = 'NOT_CLEANED';
    const STATUS_FAILED_INSPECTION = 'FAILED_INSPECTION';

    /**
     * @see ObjectModel::$definition
     */
    public static $definition = array(
        'table' => 'housekeeping_room_status',
        'primary' => 'id_room_status',
        'fields' => array(
            'id_room' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'status' => array('type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true),
            'id_employee' => array('type' => self::TYPE_INT, 'validate' => 'isUnsignedId', 'required' => true),
            'date_upd' => array('type' => self::TYPE_DATE, 'validate' => 'isDate', 'required' => true),
        ),
    );

    /**
     * get room status summary counts
     * 
     * @return array summary counts
     */
    public static function getRoomStatusSummary()
    {
        // get total room count from hotel room information
        $objRoomInfo = new HotelRoomInformation();
        $totalRooms = count($objRoomInfo->getAllHotelRooms());

        // initialize summary
        $summary = array(
            'total' => $totalRooms,
            'cleaned' => 0,
            'not_cleaned' => 0,
            'failed_inspection' => 0,
        );

        // get status counts
        $sql = new DbQuery();
        $sql->select('status, COUNT(*) as count');
        $sql->from(self::$definition['table']);
        $sql->groupBy('status');
        
        $results = Db::getInstance()->executeS($sql);
        
        if ($results && is_array($results)) {
            foreach ($results as $result) {
                switch ($result['status']) {
                    case self::STATUS_CLEANED:
                        $summary['cleaned'] = (int)$result['count'];
                        break;
                    case self::STATUS_NOT_CLEANED:
                        $summary['not_cleaned'] = (int)$result['count'];
                        break;
                    case self::STATUS_FAILED_INSPECTION:
                        $summary['failed_inspection'] = (int)$result['count'];
                        break;
                }
            }
        }
        
        // for rooms without a status record, consider them as not cleaned
        $summary['not_cleaned'] += ($totalRooms - ($summary['cleaned'] + $summary['not_cleaned'] + $summary['failed_inspection']));
        
        return $summary;
    }

    /**
     * get rooms by status
     * 
     * @param string $status Optional status filter
     * @return array Array of rooms with status
     */
    public static function getRoomsByStatus($status = null)
    {
        // get all room statuses
        $sql = new DbQuery();
        $sql->select('rs.*, e.firstname, e.lastname');
        $sql->from(self::$definition['table'], 'rs');
        $sql->leftJoin('employee', 'e'. 'e.id_employee = rs.id_employee');

        if ($status) {
            $sql->where('rs.status = "'.pSQL($status).'"');
        }

        $sql->orderBy('rs.date_upd DESC');

        $results = Db::getInstance()->executeS($sql);

        if ($results && is_array($results)) {
            foreach ($results as &$room) {
                if (isset($room['firstname']) && isset($room['lastname'])) {
                    $room['employee_name'] = $room['firstname'].' '.$room['lastname'];
                } else {
                    $room['employee_name'] = null;
                }
                unset($room['firstname'], $room['lastname']);
            }
        }
        
        return $results ? $results : array();
    }

    /**
     * get the statys ID for a room
     * 
     * @param int $id_room Room ID
     * @return int|dalse Status id or false if not found
     */
    public static function getRoomStatusId($id_room)
    {
        $sql = new DbQuery();
        $sql->select('id_room_status');
        $sql->from(self::$definition['table']);
        $sql->where('id_room = '.(int)$id_room);
        
        return Db::getInstance()->getValue($sql);
    }

    /**
     * update room status
     * 
     * @param int $id_room Room ID
     * @param string $status New status
     * @param int $id_employee Employee ID
     * @return bool Success
     */
    public static function updateRoomStatus($id_room, $status, $id_employee)
    {
        $id_room = (int)$id_room;
        $id_employee = (int)$id_employee;

        //validate status
        $valid_statuses = array(
            self::STATUS_CLEANED,
            self::STATUS_NOT_CLEANED,
            self::STATUS_FAILED_INSPECTION
        );
        
        if (!in_array($status, $valid_statuses)) {
            return false;
        }

        // check if record exists
        $id_room_status = self::getRoomStatusId($id_room);
        
        if ($id_room_status) {
            // update existing record
            $room_status = new RoomStatusModel($id_room_status);
        } else {
            // create new record
            $room_status = new RoomStatusModel();
            $room_status->id_room = $id_room;
        }
        
        $room_status->status = $status;
        $room_status->id_employee = $id_employee;
        $room_status->date_upd = date('Y-m-d H:i:s');
        
        return $room_status->save();
    }

    /**
     * get room info by id
     * 
     * @param int $id_room Room ID
     * @return array|false Room info or false
     */
    public static function getRoomInfo($id_room)
    {
        $objHotelRoomInfo = new HotelRoomInformation($id_room);
        
        if (Validate::isLoadedObject($objHotelRoomInfo)) {
            $objHotelBranch = new HotelBranchInformation($objHotelRoomInfo->id_hotel);
            $objRoomType = new HotelRoomType();
            $roomTypeInfo = $objRoomType->getRoomTypeInfoByIdProduct($objHotelRoomInfo->id_product);
            
            return array(
                'id' => $objHotelRoomInfo->id,
                'room_num' => $objHotelRoomInfo->room_num,
                'id_product' => $objHotelRoomInfo->id_product,
                'id_hotel' => $objHotelRoomInfo->id_hotel,
                'hotel_name' => $objHotelBranch->hotel_name,
                'room_type' => $roomTypeInfo ? $roomTypeInfo['room_type'] : '',
                'floor' => $objHotelRoomInfo->floor,
                'comment' => $objHotelRoomInfo->comment,
                'status' => $objHotelRoomInfo->id_status
            );
        }
        
        return false;
    }

    /**
     * get all rooms with their status
     * 
     * @return array Array of rooms with status
     */
    public static function getAllRoomsWithStatus()
    {
        // getall hotel roms 
        $objHotelRoomInfo = new HotelRoomInformation();
        $rooms = $objHotelRoomInfo->getAllHotelRooms();
        
        // get all room statuses
        $roomStatuses = self::getRoomsByStatus();
        
        // ceate a map of room ID to status
        $statusMap = array();
        foreach ($roomStatuses as $status) {
            $statusMap[$status['id_room']] = $status;
        }
        
        // merge room info with status
        foreach ($rooms as &$room) {
            if (isset($statusMap[$room['id']])) {
                $room['status'] = $statusMap[$room['id']]['status'];
                $room['employee_name'] = $statusMap[$room['id']]['employee_name'];
                $room['date_upd'] = $statusMap[$room['id']]['date_upd'];
            } else {
                $room['status'] = self::STATUS_NOT_CLEANED;
                $room['employee_name'] = null;
                $room['date_upd'] = null;
            }
        }
        
        return $rooms;
    }

    /**
     * check if a room needs cleaning based on bookings
     * 
     * @param int $id_room Room ID
     * @return bool True if room needs cleaning
     */
    public static function checkIfRoomNeedsCleaning($id_room)
    {
        // get recent booking details for this room
        $objBookingDetail = new HotelBookingDetail();
        $recentBookings = $objBookingDetail->getBookingDataByRoomId($id_room, date('Y-m-d', strtotime('-7 days')));

        // if ther were recent bookings with checkout date in the past, room needs cleaning
        if ($recentBookings && is_array($recentBookings)) {
            foreach ($recentBookings as $booking) {
                $checkoutDate = strtotime($booking['date_to']);
                $now = time();
                
                if ($checkoutDate < $now) {
                    return true;
                }
            }
        }
        
        return false;
    }

    /**
     * get rooms that need cleaning
     * 
     * @return array Array of rooms that need cleaning
     */
    public static function getRoomsThatNeedCleaning()
    {
        $rooms = array();
        
        // get all rooms
        $objHotelRoomInfo = new HotelRoomInformation();
        $allRooms = $objHotelRoomInfo->getAllHotelRooms();
        
        // gett room statuses
        $roomStatuses = self::getRoomsByStatus();
        $statusMap = array();
        foreach ($roomStatuses as $status) {
            $statusMap[$status['id_room']] = $status['status'];
        }
        
        // check each room
        foreach ($allRooms as $room) {
            // if  room is not marked as cleaned and has recent checkouts
            if ((!isset($statusMap[$room['id']]) || $statusMap[$room['id']] !== self::STATUS_CLEANED) 
                && self::checkIfRoomNeedsCleaning($room['id'])) {
                $rooms[] = $room;
            }
        }
        
        return $rooms;
    }

    /**
     * get rooms where cleaning is overdue
     * 
     * @param int $days Number of days overdue
     * @return array Array of rooms with overdue cleaning
     */
    public static function getOverdueCleaningRooms($days = 1)
    {
        $rooms = array();
        $cutoffDate = date('Y-m-d H:i:s', strtotime('-'.$days.' days'));
        
        // get all rooms that are not cleaned
        $sql = new DbQuery();
        $sql->select('rs.*');
        $sql->from(self::$definition['table'], 'rs');
        $sql->where('rs.status = "'.self::STATUS_NOT_CLEANED.'"');
        $sql->where('rs.date_upd < "'.pSQL($cutoffDate).'"');
        
        $results = Db::getInstance()->executeS($sql);
        
        if ($results && is_array($results)) {
            foreach ($results as $result) {
                $roomInfo = self::getRoomInfo($result['id_room']);
                if ($roomInfo) {
                    $rooms[] = array_merge($roomInfo, $result);
                }
            }
        }
        
        return $rooms;
    }

    /**
     * override add method to set creation date
     */
    public function add($auto_date = true, $null_values = false)
    {
        if ($auto_date && property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }
        
        return parent::add($auto_date, $null_values);
    }
    
    /**
     * override update method to set update date
     */
    public function update($null_values = false)
    {
        if (property_exists($this, 'date_upd')) {
            $this->date_upd = date('Y-m-d H:i:s');
        }
        
        return parent::update($null_values);
    }
}
