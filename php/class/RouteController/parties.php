<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Partie;
use BDDObject\ClePartie;
use BDDObject\Logged;

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
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($uLog->isRoot()) {
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

        if ($uLog->isRedacteur()) {
            $evenement = $item->getEvenement();
            if ($evenement===null)
            {
                EC::set_error_code(501);
                return false;
            }
            if ($evenement->getIdProprietaire() !== $uLog->getId())
            {
                EC::set_error_code(403);
                return false;
            }
        }
        elseif ($uLog->isJoueur())
        {
            if ($item->getIdProprietaire() !== $uLog->getId())
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
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$uLog->isRoot() && !$uLog->isRedacteur()) {
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

        if ($uLog->isRedacteur())
        {
            $evenement = $item->getEvenement();
            if (($evenement!==null)&&($evenement->getIdProprietaire() !== $uLog->getId()))
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
        $uLog=Logged::getConnectedUser();
        if ($uLog->isJoueur())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $data['idProprietaire'] = $uLog->getId();
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
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$uLog->isJoueur()){
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

        if ($uLog->getId()!==$item->getIdProprietaire())
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
