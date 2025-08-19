<?php
if (!defined('_PS_VERSION_')) {
	exit;
}

require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskAssignmentModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/SOPStepModel.php');
require_once(_PS_MODULE_DIR_.'housekeepingmanagement/classes/TaskStepStatusModel.php');
require_once(_PS_MODULE_DIR_.'hotelreservationsystem/classes/HotelRoomInformation.php');

class HousekeepingManagementHousekeepingModuleFrontController extends ModuleFrontController
{
	public $ssl = true;

	public function initContent()
	{
		parent::initContent();

		// Include front assets
		$this->context->controller->addCSS($this->module->getPathUri().'views/css/housekeeping-front.css');
		$this->context->controller->addJS($this->module->getPathUri().'views/js/housekeeping_task_detail.js');

		$idTask = (int)Tools::getValue('id_task');
		$this->context->smarty->assign(array(
			'id_task' => $idTask,
			'ajax_url' => $this->context->link->getModuleLink('housekeepingmanagement', 'housekeeping', array(), Tools::usingSecureMode()),
		));

		$this->setTemplate('module:housekeepingmanagement/views/templates/front/task_detail.tpl');
	}

	public function postProcess()
	{
		if (!Tools::getIsset('ajax')) {
			return;
		}

		$action = Tools::getValue('action');
		switch ($action) {
			case 'getTaskDetail':
				$idTask = (int)Tools::getValue('id_task');
				$this->ajaxDie(json_encode($this->getTaskDetail($idTask)));
				break;
			case 'toggleStep':
				$idTask = (int)Tools::getValue('id_task');
				$idSopStep = (int)Tools::getValue('id_sop_step');
				$statusParam = Tools::getValue('status');
				$allowed = array('Not Executed','In Progress','Completed');
				if ($statusParam !== null && in_array($statusParam, $allowed)) {
					$newStatus = $statusParam;
				} else {
					$passed = (bool)Tools::getValue('passed');
					$newStatus = $passed ? 'Completed' : 'Not Executed';
				}
				$ok = TaskStepStatusModel::upsertStatus($idTask, $idSopStep, $newStatus);
				$this->ajaxDie(json_encode(array('success' => (bool)$ok)));
				break;
			case 'submitChecklist':
				$idTask = (int)Tools::getValue('id_task');
				$rawItems = Tools::getValue('items');
				$items = array();
				if ($rawItems) {
					$decoded = json_decode($rawItems, true);
					if (is_array($decoded)) {
						$items = $decoded;
					}
				}
				$updated = 0; $total = 0; $done = 0;
				foreach ($items as $it) {
					if (!isset($it['id_sop_step'])) { continue; }
					$total++;
					$idSopStep = (int)$it['id_sop_step'];
					$passed = !empty($it['passed']);
					$status = $passed ? 'Completed' : 'Not Executed';
					if (TaskStepStatusModel::upsertStatus($idTask, $idSopStep, $status)) {
						$updated++;
						if ($passed) { $done++; }
					}
				}

				// Optional: If all done, push room status towards inspection
				try {
					if ($total > 0 && $done === $total) {
						$row = Db::getInstance()->getRow('SELECT id_room_status FROM `'._DB_PREFIX_.'housekeeping_task_assignment` WHERE id_task='.(int)$idTask);
						if ($row && (int)$row['id_room_status'] > 0) {
							Db::getInstance()->update('housekeeping_room_status', array(
								'status' => pSQL('To Be Inspected'),
								'date_upd' => date('Y-m-d H:i:s'),
							), 'id_room_status='.(int)$row['id_room_status']);
						}
					}
				} catch (Exception $e) {
					// ignore soft failure of status update
				}

				$this->ajaxDie(json_encode(array(
					'success' => true,
					'updated' => $updated,
					'done' => $done,
					'total' => $total,
				)));
				break;
		}
	}

	protected function getTaskDetail($idTask)
	{
		$task = Db::getInstance()->getRow('
			SELECT t.*, r.room_num, pl.name as room_type, 
			       CONCAT(e.firstname, " ", e.lastname) as staff_name
			FROM `'._DB_PREFIX_.'housekeeping_task_assignment` t 
			INNER JOIN `'._DB_PREFIX_.'htl_room_information` r ON r.id=t.id_room 
			INNER JOIN `'._DB_PREFIX_.'product_lang` pl ON (pl.id_product=r.id_product AND pl.id_lang='.(int)$this->context->language->id.')
			LEFT JOIN `'._DB_PREFIX_.'employee` e ON t.id_employee=e.id_employee
			WHERE t.id_task='.(int)$idTask
		);
		
		if (!$task) return array('success' => false);
		
		$steps = $this->getStepsForRoomType((int)$task['id_task'], (int)$task['id_room']);
		$completed = 0; $total = count($steps);
		foreach ($steps as $st) { if ($st['status'] === 'Completed') { $completed++; } }
		
		// Determine current status
		$currentStatus = 'In Progress';
		if ($total > 0 && $completed === $total) {
			$currentStatus = 'Completed';
		} elseif ($completed > 0) {
			$currentStatus = 'In Progress';
		} else {
			$currentStatus = 'Not Started';
		}
		
		return array(
			'success' => true,
			'task' => array(
				'id_task' => (int)$task['id_task'],
				'room' => array('number' => $task['room_num'], 'type' => $task['room_type']),
				'priority' => $task['priority'],
				'deadline' => $task['deadline'],
				'start' => isset($task['date_add']) ? $task['date_add'] : null,
				'notes' => isset($task['special_notes']) ? $task['special_notes'] : '',
				'staff' => $task['staff_name'] ?: 'Unassigned',
				'status' => $currentStatus,
				'steps' => $steps,
				'progress' => array('done' => $completed, 'total' => $total),
			)
		);
	}

	protected function getStepsForRoomType($idTask, $idRoom)
	{
		$room = new HotelRoomInformation((int)$idRoom);
		$idProduct = (int)$room->id_product;
		$sopId = (int)Db::getInstance()->getValue('SELECT `id_sop` FROM `'._DB_PREFIX_.'housekeeping_sop` WHERE `active`=1 AND (`room_type`="" OR `room_type`='.(int)$idProduct.') ORDER BY `date_upd` DESC');
		$steps = array();
		if ($sopId) {
			$rows = SOPStepModel::getStepsBySOP($sopId);
			$statuses = TaskStepStatusModel::getStatusesByTask((int)$idTask);
			foreach ($rows as $row) {
				$idStep = (int)$row['id_sop_step'];
				$steps[] = array(
					'id_sop_step' => $idStep,
					'label' => $row['step_description'],
					'status' => isset($statuses[$idStep]) ? $statuses[$idStep] : 'Not Executed',
				);
			}
		}
		return $steps;
	}
}
