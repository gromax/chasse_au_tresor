<?php

namespace RouteController;
use ErrorController as EC;
use SessionController as SC;
use AuthController as AC;

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
        $ac = new AC();
        if ($ac->connexionOk())
        {
            return $ac->getloggedUserData();
        }
        else
        {
            return array("rank"=>"off");
        }
    }

    public function delete()
    {
        SC::get()->destroy();
        $ac = new AC();
        if ($ac->connexionOk())
        {
            return $ac->getloggedUserData();
        }
        else
        {
            return array("rank"=>"off");
        }
    }

    public function insert()
    {
        $data = json_decode(file_get_contents("php://input"),true);

        if (isset($data['username']) && isset($data['pwd']))
        {
            $username=$data['username'];
            $pwd=$data['pwd'];
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }

        $loginSuccess = AC::tryLogin($username, $pwd);

        if ($loginSuccess)
        {
            $ac = new AC();
            return $ac->getloggedUserData();
        }
        else
        {
            return false;
        }
    }

    public function getUserSessionWithHash()
    {
        $hash = $this->params['hash'];
        $loginSuccess = AC::tryLoginWithHash($hash);
        if ($loginSuccess)
        {
            $ac = new AC();
            return $ac->getloggedUserData();
        }
        else
        {
            return false;
        }
    }
}
?>
