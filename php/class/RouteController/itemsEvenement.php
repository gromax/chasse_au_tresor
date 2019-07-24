<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\ItemEvenement;

class itemsEvenement
{
    /**
     * paramères de la requète
     * @array
     */
    private $params;
    /**
     * Constructeur
     */
    public function __construct($params)
    {
        $this->params = $params;
    }

    public function fetch()
    {
        // Rédacteur seul
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$ac->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item = ItemEvenement::getObject($id);
        if ($item===null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->getLoggedUserId()!==$item->getIdProprietaire())
        {
            EC::set_error_code(403);
            return false;
        }

        return $item->getValues();
    }

    public function delete()
    {
        // Rédacteur seul
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$ac->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item=ItemEvenement::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->getLoggedUserId()!==$item->getIdProprietaire())
        {
            EC::set_error_code(403);
            return false;
        }

        if ($item->delete())
        {
            return array("message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        // Seul un rédacteur peut créer un événement
        $ac = new AC();
        if ($ac->isRedacteur() )
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $item = new ItemEvenement($data);
            if ($item->modItemAuthorized($ac->getLoggedUserId()) === true)
            {
              $id = $item->insertion();
              if ($id!==null)
              {
                return $item->getValues();
              }
            } else {
              EC::set_error_code(403);
              return false;
            }
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
        EC::set_error_code(501);
        return false;
    }

    public function update()
    {
        // Seul le rédacteur propriétaire peut changer un événement
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$ac->isRedacteur()){
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $item = ItemEvenement::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        $moditem = $item->modItemAuthorized($ac->getLoggedUserId());
        if ($moditem===null)
        {
          EC::set_error_code(501);
          return false;
        }

        if ($moditem===false)
        {
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);

        $modOk=$item->update($data);
        if ($modOk === true)
        {
            return $item->getValues();
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }
    }

}
?>
