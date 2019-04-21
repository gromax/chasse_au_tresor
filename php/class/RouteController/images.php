<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Image;

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
            //$data = json_decode(file_get_contents("php://input"),true);
            //var_dump($_POST);


            if (isset($_FILES['image']) && isset($_POST['idEvenement']))
            {
                $file = $_FILES['image']['tmp_name'];
                $ext = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
                $hash = md5_file($file);
                $item = new Image(array("idEvenement"=>$_POST['idEvenement'], "hash"=>$hash, "ext"=>$ext));
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
