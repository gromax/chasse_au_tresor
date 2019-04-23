<?php

namespace BDDObject;
use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

abstract class Item
{
	const	SAVE_IN_SESSION = true;
	protected $id = null;
	protected $values = null;
	protected static $BDDName = "Item";
	protected static $privates = false; # liste de clé qui ne doivent pas être publiées

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array();
	}

	public function __construct($values=false)
	{
		$arr = static::champs();
		$this->values = array_combine(array_keys($arr), array_column($arr,"def"));

		if ($values !== false) {
			$filtered_values = self::filter($values);
			$this->values = array_merge($this->values, $filtered_values);
			if (isset($filtered_values['id'])) {
				$this->id = $filtered_values['id'];
			}
		}
	}

	public static function filter($values=array())
	{
		$arr = static::champs();
		$arr_types = array_combine(array_keys($arr), array_column($arr,"type"));

		$filtered_values = array();

		if (isset($values["id"])) {
			$filtered_values["id"] = (integer) $values["id"];
		}

		foreach ( $arr_types as $key => $value ) {
			if(isset($values[$key])) {
				switch ($value) {
					case "integer":
						$filtered_values[$key] = (integer) $values[$key];
						break;
					case "string":
						$filtered_values[$key] = (string) $values[$key];
						break;
					case "boolean":
						$filtered_values[$key] = (boolean) $values[$key];
						break;
					case "dateHeure":
						$filtered_values[$key] = $values[$key];
						break;
					case "date":
						$filtered_values[$key] = $values[$key];
						break;
					default:
						$filtered_values[$key] = $values[$key];
				}
			}
		}
		return $filtered_values;
	}

	public static function getObject($idInput)
	{
		if (is_numeric($idInput)) {
			$id = (integer) $idInput;
		} else return null;
		if (self::SAVE_IN_SESSION) {
			$item = SC::get()->getParamInCollection(static::$BDDName, $id, null);
			if ($item !== null){
				return $item;
			}
		}

		// Pas trouvé dans la session, il faut chercher en bdd
		$keys = array_keys(static::champs());
		array_unshift($keys,"id");

		require_once BDD_CONFIG;
		try {
			$bdd_result=DB::queryFirstRow("SELECT ".implode(",",$keys)." FROM ".PREFIX_BDD.static::$BDDName." WHERE id=%i", $id);
			if ($bdd_result === null)
			{
				return null;
			}

			$item = new static($bdd_result);
			if (self::SAVE_IN_SESSION)
			{
				SC::get()->setParamInCollection(static::$BDDName, $item->id, $item);
			}
			return $item;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(),static::$BDDName."/getObject");
		}
		return null;
	}

	##################################### METHODES #####################################

	public function __toString()
	{
		if ($this->id!==null) {
			return static::$BDDName."@".$this->id;
		} else {
			return static::$BDDName."@?";
		}
	}

	public function delete()
	{
		require_once BDD_CONFIG;
		if (method_exists($this, "customDelete")) {
			if(!$this->customDelete())
			{
				return false;
			}
		}
		try {
			// Suppression des assoc liées
			$message = $this." supprimé avec succès.";
			if (method_exists(get_called_class(),"getAssocs")) {
				$arr = static::getAssocs();
				foreach ($arr as $table => $col) {
					DB::delete(PREFIX_BDD.$table, $col.'= %i', $this->id);
					if (static::SAVE_IN_SESSION) $session=SC::get()->unsetParam($table);
				}
			}
			DB::delete(PREFIX_BDD.static::$BDDName, 'id=%i', $this->id);
			EC::add($message);
			if (static::SAVE_IN_SESSION) $session=SC::get()->unsetParamInCollection(static::$BDDName, $this->id);
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), static::$BDDName."/delete");
		}
		return false;
	}

	public function insertion()
	{
		if (method_exists($this, "parseBeforeInsert")) {
			$toInsert = $this->parseBeforeInsert();
		} else {
			$toInsert = $this->values;
		}

		if ($toInsert === false) {
			return null;
		}

		require_once BDD_CONFIG;
		try {
			DB::insert(PREFIX_BDD.static::$BDDName, $toInsert);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), static::$BDDName."/insertion");
			return null;
		}
		$this->id=DB::insertId();
		$this->values["id"] = $this->id;
		EC::add($this." créé avec succès.");
		return $this->id;
	}

	public function update($modifs=array(),$updateBDD=true)
	{
		if (method_exists($this,"parseBeforeUpdate"))
			$modifs= $this->parseBeforeUpdate($modifs);
		$modifs = self::filter($modifs);

		$this->values = array_merge($this->values, $modifs);

		if (!$updateBDD) {
			EC::add(static::$BDDName."/update : Succès.");
			return true;
		}

		// On peut lancer l'update de la bdd
		require_once BDD_CONFIG;
		if (!isset($this->values['id'])) {
			# il s'agit d'une insertion
			try {
				DB::insert(PREFIX_BDD.static::$BDDName, $this->values);
			} catch(MeekroDBException $e) {
				EC::addBDDError($e->getMessage(), static::$BDDName."/insertion");
				return null;
			}
			$this->id=DB::insertId();
			$this->values["id"] = $this->id;
			EC::add($this." créé avec succès.");
			return $this->id;
		} else {
			# il s'agit d'un update
			try{
				DB::update(PREFIX_BDD.static::$BDDName, $modifs, "id=%i",$this->id);
			} catch(MeekroDBException $e) {
				EC::addBDDError($e->getMessage(), static::$BDDName."/update");
				return false;
			}
			EC::add(static::$BDDName."/update : Succès.");
			return true;
		}
	}

	public function isSameAs($id)
	{
		return ($this->id ===$id);
	}

	public function getId()
	{
		return $this->id;
	}

	public function getValues()
	{
		if (static::$privates){
			$p = explode(" ", static::$privates);
			$out = $this->values;
			foreach ( $p as $key ) {
				unset($out[$key]);
			}
			return $out;
		} else {
			return $this->values;
		}
	}
}
?>
