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

class WebserviceSpecificManagementSOP implements WebserviceSpecificManagementInterface
{
    /** @var WebserviceOutputBuilder */
    protected $objOutput;

    /** @var string */
    protected $output;

    /** @var WebserviceRequest */
    protected $wsObject;

    /** @var String request method */
    protected $method;
    
    /** @var array request parameters */
    protected $urlSegment = array();

    /**
     * @param WebserviceOutputBuilderCore $obj
     * @return WebserviceSpecificManagementInterface
     */
    public function setObjectOutput(WebserviceOutputBuilderCore $obj)
    {
        $this->objOutput = $obj;
        return $this;
    }
    
    public function getObjectOutput()
    {
        return $this->objOutput;
    }
    
    public function setWsObject(WebserviceRequestCore $obj)
    {
        $this->wsObject = $obj;
        return $this;
    }
    
    public function getWsObject()
    {
        return $this->wsObject;
    }

    /**
     * set url segment array
     * 
     * @param array $segments
     * @return WebserviceSpecificManagementInterface
     */
    public function setUrlSegment($segments)
    {
        $this->urlSegment = $segments;
        return $this;
    }
    
    /**
     * get url segment array
     * 
     * @return array
     */
    public function getUrlSegment()
    {
        return $this->urlSegment;
    }

    /**
     * MAIN METHOD to handle API REQUEST
     */
    public function manage()
    {
        $this->method = $this->wsObject->method;
        
        // get request URI segments
        if (isset($this->wsObject->urlSegment)) {
            $this->urlSegment = $this->wsObject->urlSegment;
        }
        
        switch ($this->method) {
            case 'GET':
                $this->handleGet();
                break;
            case 'POST':
                $this->handlePost();
                break;
            case 'PUT':
                $this->handlePut();
                break;
            case 'DELETE':
                $this->handleDelete();
                break;
            default:
                throw new WebserviceException('Method not supported', array(405, 400));
        }
    }

    /**
     * GET THE CONTENT to output
     */
    public function getContent()
    {
        return $this->output;
    }

    /**
     * handle GET requests
     */
    protected function handleGet()
    {
        // check if this is for schema
        if (isset($this->wsObject->urlFragments['schema'])) {
            $this->generateSchema();
            return;
        }
        
        // get the SOP id if provided in url
        $id_sop = isset($this->urlSegment[1]) ? (int)$this->urlSegment[1] : 0;
        
        // if id is provided, get single SOP, otherwise get list
        if ($id_sop) {
            $this->getSOPDetails($id_sop);
        } else {
            // check if this is a summary request
            if (isset($this->urlSegment[1]) && $this->urlSegment[1] == 'summary') {
                $this->getSOPSummary();
            } else {
                $this->getSOPList();
            }
        }
    }

    /**
     * handle POST requests for creating new SOPs
     */
    protected function handlePost()
    {
        $postData = $this->getPostData();
        
        // validate required fields
        $this->validateSOPData($postData);
        
        // create new sop
        $result = $this->createSOP($postData);
        
        // set response
        $this->output = json_encode([
            'success' => true,
            'message' => 'SOP created successfully',
            'sop' => $result
        ]);
    }

    /**
     * handle PUT requests for updating SOPs
     */
    protected function handlePut()
    {
        // get the sop id from url
        $id_sop = isset($this->urlSegment[1]) ? (int)$this->urlSegment[1] : 0;

        if (!$id_sop) {
            throw new WebserviceException('SOP ID is required for update operation', array(400, 400));
        }

        $putData = $this->getPutData();

        // validate sop exists
        $sop = new SOPModel($id_sop);
        if (!Validate::isLoadedObject($sop)) {
            throw new WebserviceException('SOP not found', array(404, 404));
        }

        // update sop
        $result = $this->updateSOP($id_sop, $putData);

        // set response
        $this->output = json_encode([
            'success' => true,
            'message' => 'SOP updated successfully',
            'sop' => $result
        ]);
    }

    /**
     * handle DELETE requests
     */
    protected function handleDelete()
    {
        // get the sop id from url
        $id_sop = isset($this->urlSegment[1]) ? (int)$this->urlSegment[1] : 0;
        
        if (!$id_sop) {
            throw new WebserviceException('SOP ID is required for delete operation', array(400, 400));
        }

        // validate sop exists
        $sop = new SOPModel($id_sop);
        if (!Validate::isLoadedObject($sop)) {
            throw new WebserviceException('SOP not found', array(404, 404));
        }

        // delete sop and its steps (soft delete)
        $result = $this->deleteSOP($id_sop);
        
        // set response
        $this->output = json_encode([
            'success' => true,
            'message' => 'SOP deleted successfully'
        ]);
    }

    /**
     * GET SOP LIST with optional filtering
     */
    protected function getSOPList()
    {
        $filters = [];
        $room_type = null;
        $active = true;
        $includeDeleted = false;

        // process filter params
        if (isset($this->wsObject->urlFragments['room_type'])) {
            $room_type = $this->wsObject->urlFragments['room_type'];
        }
        
        if (isset($this->wsObject->urlFragments['active']) && $this->wsObject->urlFragments['active'] === '0') {
            $active = false;
        }
        
        if (isset($this->wsObject->urlFragments['include_deleted']) && $this->wsObject->urlFragments['include_deleted'] === '1') {
            $includeDeleted = true;
        }

        // get SOPs from db
        $sops = SOPModel::getSOPs($room_type, $active, 0, 0, $includeDeleted);

        // format response 
        $response = [
            'sops' => $sops
        ];

        $this->output = json_encode($response);
    }

    /**
     * get details of a specific SOP
     * 
     * @param int $id_sop
     */
    protected function getSOPDetails($id_sop)
    {
        $includeDeleted = false;
        
        if (isset($this->wsObject->urlFragments['include_deleted']) && $this->wsObject->urlFragments['include_deleted'] === '1') {
            $includeDeleted = true;
        }
        
        $sop = SOPModel::getSOPWithSteps($id_sop, $includeDeleted);
        
        if (!$sop) {
            throw new WebserviceException('SOP not found', array(404, 404));
        }
        
        // format response
        $response = [
            'sop' => $sop
        ];
        
        $this->output = json_encode($response);
    }

    /**
     * get summary counts of rooms by status
     */
    protected function getSOPSummary()
    { 
        $summary = RoomStatusModel::getRoomStatusSummary();
        
        $this->output = json_encode($summary);
    }

    /**
     * create a new SOP with steps
     * 
     * @param array $data
     * @return array
     */
    protected function createSOP($data)
    {
        // create SOP
        $sopModel = new SOPModel();
        $sopModel->title = $data['title'];
        $sopModel->description = $data['description'];
        $sopModel->room_type = isset($data['room_type']) ? $data['room_type'] : null;
        $sopModel->id_employee = Context::getContext()->employee->id;
        $sopModel->active = 1;
        $sopModel->deleted = 0;
        
        if (!$sopModel->add()) {
            throw new WebserviceException('Failed to create SOP', array(500, 500));
        }

        // create SOP steps
        if (isset($data['steps']) && is_array($data['steps'])) {
            foreach ($data['steps'] as $index => $step) {
                $sopStepModel = new SOPStepModel();
                $sopStepModel->id_sop = $sopModel->id_sop;
                $sopStepModel->step_order = $index + 1;
                $sopStepModel->step_description = $step['step_description'];
                $sopStepModel->add();
            }
        }

        // return the created SOP with its ID
        $createdSOP = SOPModel::getSOPWithSteps($sopModel->id_sop);
        
        return $createdSOP;
    }

    /**
     * update an existing SOP
     * 
     * @param int $id_sop
     * @param array $data
     * @return array
     */
    protected function updateSOP($id_sop, $data)
    {
        // update SOP
        $sopModel = new SOPModel($id_sop);
        
        if (isset($data['title'])) {
            $sopModel->title = $data['title'];
        }
        
        if (isset($data['description'])) {
            $sopModel->description = $data['description'];
        }
        
        if (isset($data['room_type'])) {
            $sopModel->room_type = $data['room_type'];
        }
        
        if (isset($data['active'])) {
            $sopModel->active = (bool)$data['active'];
        }
        
        if (!$sopModel->update()) {
            throw new WebserviceException('Failed to update SOP', array(500, 500));
        }

        // update sop steps if provided 
        if (isset($data['steps']) && is_array($data['steps'])) {
            // Delete existing steps
            SOPStepModel::deleteStepsBySOP($id_sop);
            
            // Create new steps
            foreach ($data['steps'] as $index => $step) {
                $sopStepModel = new SOPStepModel();
                $sopStepModel->id_sop = $id_sop;
                $sopStepModel->step_order = $index + 1;
                $sopStepModel->step_description = $step['step_description'];
                $sopStepModel->add();
            }
        }

        // Get updated SOP with steps
        $updatedSop = SOPModel::getSOPWithSteps($id_sop);
        
        return $updatedSop;
    }

    /**
     * DELETE a SOP (soft delete) 
     * 
     * @param int $id_sop
     * @return bool
     */
    protected function deleteSOP($id_sop)
    {
        $sopModel = new SOPModel($id_sop);
        return $sopModel->delete(); // This is now a soft delete
    }

    /**
     * validate SOP data for creation/update
     * 
     * @param array $data
     * @throws WebserviceException
     */
    protected function validateSOPData($data)
    {
        $errors = [];
        
        // validate required fields
        if (!isset($data['title']) || empty($data['title'])) {
            $errors[] = 'Title is required';
        }
        
        if (!isset($data['description']) || empty($data['description'])) {
            $errors[] = 'Description is required';
        }
        
        // validate steps
        if (!isset($data['steps']) || !is_array($data['steps']) || empty($data['steps'])) {
            $errors[] = 'At least one step is required';
        } else {
            foreach ($data['steps'] as $step) {
                if (!isset($step['step_description']) || empty($step['step_description'])) {
                    $errors[] = 'Step description is required for all steps';
                    break;
                }
            }
        }
        
        if (!empty($errors)) {
            throw new WebserviceException(implode(', ', $errors), array(400, 400));
        }
    }

    /**
     * get POST data from request
     * 
     * @return array
     */
    protected function getPostData()
    {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new WebserviceException('Invalid JSON data provided', array(400, 400));
        }
        
        return $data;
    }

    /**
     * get PUT data from request
     * 
     * @return array
     */
    protected function getPutData()
    {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new WebserviceException('Invalid JSON data provided', array(400, 400));
        }
        
        return $data;
    }

    /** 
     * generate API schema for documentation purposes
     */
    protected function generateSchema()
    {
        $schema = [
            'sop' => [
                'id_sop' => ['type' => 'integer', 'required' => true, 'description' => 'SOP ID'],
                'title' => ['type' => 'string', 'required' => true, 'description' => 'SOP title'],
                'description' => ['type' => 'string', 'required' => true, 'description' => 'SOP description'],
                'room_type' => ['type' => 'string', 'required' => false, 'description' => 'Room type this SOP applies to'],
                'id_employee' => ['type' => 'integer', 'required' => true, 'description' => 'User ID who created the SOP'],
                'active' => ['type' => 'boolean', 'required' => true, 'description' => 'Whether the SOP is active'],
                'deleted' => ['type' => 'boolean', 'required' => true, 'description' => 'Whether the SOP is deleted (soft delete)'],
                'date_add' => ['type' => 'datetime', 'required' => true, 'description' => 'Creation timestamp'],
                'date_upd' => ['type' => 'datetime', 'required' => true, 'description' => 'Last update timestamp'],
                'steps' => [
                    'type' => 'array',
                    'required' => true,
                    'description' => 'Steps for this SOP',
                    'items' => [
                        'id_sop_step' => ['type' => 'integer', 'required' => true, 'description' => 'Step ID'],
                        'id_sop' => ['type' => 'integer', 'required' => true, 'description' => 'SOP ID this step belongs to'],
                        'step_order' => ['type' => 'integer', 'required' => true, 'description' => 'Order position of this step'],
                        'step_description' => ['type' => 'string', 'required' => true, 'description' => 'Step description']
                    ]
                ]
            ],
            'room_status' => [
                'id_room_status' => ['type' => 'integer', 'required' => true, 'description' => 'Room status ID'],
                'id_room' => ['type' => 'integer', 'required' => true, 'description' => 'Room ID'],
                'status' => ['type' => 'enum', 'required' => true, 'description' => 'Room status (CLEANED, NOT_CLEANED, FAILED_INSPECTION)'],
                'id_employee' => ['type' => 'integer', 'required' => false, 'description' => 'Staff assigned to this room'],
                'date_upd' => ['type' => 'datetime', 'required' => true, 'description' => 'Last status update timestamp']
            ]
        ];
        
        $this->output = json_encode($schema);
    }
}