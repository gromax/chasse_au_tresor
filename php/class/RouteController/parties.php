<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Partie;
use BDDObject\ClePartie;

class parties
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
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($ac->isRoot()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item = Partie::getObject($id);

        if ($item===null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur()) {
            $evenement = $item->getEvenement();
            if ($evenement===null)
            {
                EC::set_error_code(501);
                return false;
            }
            if ($evenement->getIdProprietaire() !== $ac->getLoggedUserId())
            {
                EC::set_error_code(403);
                return false;
            }
        }
        elseif ($ac->isJoueur())
        {
            if ($item->getIdProprietaire() !== $ac->getLoggedUserId())
            {
                EC::set_error_code(403);
                return false;
            }
        }

        $values = $item->getValues();
        $values['cles'] = ClePartie::getList(array('partie'=>$id));
        return $values;
    }

    public function delete()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$ac->isRoot() && !$ac->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item=Partie::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur())
        {
            $evenement = $item->getEvenement();
            if (($evenement!==null)&&($evenement->getIdProprietaire() !== $ac->getLoggedUserId()))
            {
                EC::set_error_code(403);
                return false;
            }
        }

        if ($item->delete())
        {
            return array( "message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        // Seul un joueur peut créer une partie
        $ac = new AC();
        if ($ac->isJoueur())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $data['idProprietaire'] = $ac->getLoggedUserId();
            # La vérification que cet événement n'existe pas pour ce joueur sera faite dans l'insertion
            $item = new Partie();
            $validation = $item->insert_validation($data);
            if ($validation === true)
            {
                $id = $item->update($data);
                if ($id!==null)
                {
                    return $item->getValues();
                }
            }
            else
            {
                EC::set_error_code(422);
                return array('errors'=>$validation);
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
        // Seul le joueur propriétaire peut changer un événement
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$ac->isJoueur()){
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $item=Partie::getObject($id);
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

        $data = json_decode(file_get_contents("php://input"),true);
        // le seul changement possible est qu'on indique la fin
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
