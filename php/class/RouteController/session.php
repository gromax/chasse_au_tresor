<?php

namespace RouteController;
use ErrorController as EC;
use SessionController as SC;
use BDDObject\Logged;

class session
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
        return $this->getData(null);
    }

    public function delete()
    {
        SC::get()->destroy();
        return $this->getData(null);
    }

    public function insert()
    {
        $data = json_decode(file_get_contents("php://input"),true);

        if (isset($data['email']) && isset($data['pwd']))
        {
            $email=$data['email'];
            $pwd=$data['pwd'];
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }

        $adm = (isset($data['adm'])&&($data['adm']));
        $uLog = Logged::tryConnexion($email, $pwd, $adm);

        if ($uLog == null)
        {
            return false;
        }
        else
        {
            return $uLog->toArray();
        }
    }

    public function logged()
    {
        return Logged::getConnectedUser();
    }


    protected function getData($uLog = null)
    {
        return array(
            "logged" => Logged::getConnectedUser()->toArray(),
            "messages" => EC::messages()
        );
    }

    /*public function reinitMDP()
    {
        $key = $this->params["key"];
        Logged::tryConnexionOnInitMDP($key);
        $uLog = Logged::getConnectedUser();
        if ($uLog->connexionOk())
        {
            return $data = $this->getData($uLog);
        }
        else
        {
            EC::set_error_code(401);
            return false;
        }
    }*/
}
?>
