<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Image;
use BDDObject\Evenement;

class images
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
        $item = Image::getObject($id);
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
        $item=Image::getObject($id);
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
        if ($ac->isRedacteur())
        {
            if (isset($_FILES['image']) && isset($_POST['idEvenement']))
            {
                $idEvenement = (integer) $_POST['idEvenement'];
                # Il faut vérifier que l'utilisateur a le droit de mofifier cet événement
                $evenement = Evenement::getObject($idEvenement);
                if ($evenement==null)
                {
                    EC::set_error_code(404);
                    return false;
                }
                if (!$evenement->modItemAuthorized($ac->getLoggedUserId()))
                {
                    EC::set_error_code(403);
                    return false;
                }
                $file = $_FILES['image']['tmp_name'];
                $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
                // On ajoute le idEvenement en tête du nom
                // ainsi deux fichiers identiques dans deux événements différents n'ont pas le même nom
                // ce qui évite que la suppression de l'un n'entraîne la suppression de l'autre
                $hash = $idEvenement."_".md5_file($file);
                $item = new Image(array("idEvenement"=>$idEvenement, "hash"=>$hash, "ext"=>$ext));
                $item->moveUploadedFile($file);
                $id = $item->insertion();
                if ($id!==null)
                {
                    return $item->getValues();
                }
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
        // Effacé et remplacé, jamais modifié
        EC::set_error_code(501);
        return false;
    }

}
?>
