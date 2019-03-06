<?php

namespace RouteController;
use ErrorController as EC;
use SessionController as SC;

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

    /*public function insert()
    {
        $data = json_decode(file_get_contents("php://input"),true);

        if (isset($data['identifiant']) && isset($data['pwd']))
        {
            $identifiant=$data['identifiant'];
            $pwd=$data['pwd'];
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }

        $logged = Logged::tryConnexion($identifiant, $pwd);

        if ($logged == null)
        {
            return false;
        }
        else
        {
            return array_merge(
                $logged->toArray(),
                array("unread"=>Message::unReadNumber($logged->getId()) )
            );
            //return $logged->toArray();
        }
    }*/

    public function logged()
    {
        return array( "logged" => false );
    }


    protected function getData($uLog = null)
    {
        return array(
            "logged" => array( "connected" => false ),
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
