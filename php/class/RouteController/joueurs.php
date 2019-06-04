<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Joueur as Item;

class joueurs
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

        $id = (integer) $this->params['id'];
        if (!$ac->isRoot() && ($ac->getLoggedUserId()!==$id)) {
            EC::set_error_code(403);
            return false;
        }


        $user = Item::getObject($id);
        if ($user===null)
        {
            EC::set_error_code(404);
            return false;
        }

        return $user->getValues();
    }

    public function fetchList()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($ac->isRoot()) return Item::getList(array("root"=>true));
        EC::set_error_code(403);
        return false;
    }


    public function delete()
    {
        // Seul root peut effacer un joueur
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$ac->isRoot())
        {
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $redac = Item::getObject($id);
        if ($redac === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($redac->delete())
        {
            return array( "message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $itAdd = new Item();
            $validation = $itAdd->update_validation($data);
            if ($validation === true)
            {
                $id = $itAdd->update($data);
                if ($id!==null)
                    return $itAdd->getValues();
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
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        $id = (integer) $this->params['id'];
        if (!$ac->isRoot()&& (!$ac->isJoueur() || ($ac->getLoggedUserId() != $id)))
        {
            // Seul root ou joueur soi-même peut faire la modif
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);

        $userToMod = Item::getObject($id);
        if ($userToMod==null)
        {
            EC::set_error_code(404);
            return false;
        }

        $validation = $userToMod->update_validation($data);
        if ($validation === true)
        {
            $modOk=$userToMod->update($data);
            if ($modOk === true)
            {
                return $userToMod->getValues();
            }
            else
            {
                EC::set_error_code(501);
                return false;
            }
        }
        else
        {
            EC::set_error_code(422);
            return array('errors' => $validation);
        }
    }

    public function forgottenWithEmail()
    {
        if ((isset($_POST['email'])) && (Item::checkEMail($_POST['email'])))
        {
            $email = $_POST['email'];
            $user = Item::getObjectWithKey("username",$email);

            if ($user===null)
            {
                EC::set_error_code(404);
                return false;
            }

            $hash = $user->addHashForPasswordLost();
            if ($hash===false)
            {
                EC::set_error_code(501);
                return false;
            }
            $mail = new PHPMailer(true);            // Passing `true` enables exceptions
            try{
                //Server settings
                $mail->CharSet = 'UTF-8';
                //$mail->SMTPDebug = 2;             // Enable verbose debug output
                $mail->isSMTP();                    // Set mailer to use SMTP
                $mail->Host = SMTP_HOST;            // Specify main and backup SMTP servers
                $mail->SMTPAuth = true;             // Enable SMTP authentication
                $mail->Username = SMTP_USER;        // SMTP username
                $mail->Password = SMTP_PASSWORD;    // SMTP password
                $mail->SMTPSecure = 'ssl';          // Enable TLS encryption, `ssl` also accepted
                $mail->Port = SMTP_PORT;            // TCP port to connect to

                //Recipients
                $mail->setFrom(EMAIL_FROM, PSEUDO_FROM);
                $arrUser = $user->getValues();
                $mail->addAddress($email, $arrUser['nom']);     // Add a recipient

                //Content
                $mail->isHTML(true);                            // Set email format to HTML
                $mail->Subject = "Mot de passe oublié";
                $mail->Body    = "<b>".NOM_SITE.".</b> Vous avez oublié votre mot de passe. Suivez ce lien pour pour modifier votre mot de passe : <a href='".PATH_TO_SITE."/#joueur/forgotten/$hash'>Réinitialisation du mot de passe</a>.";
                $mail->AltBody = NOM_SITE." Vous avez oublié votre mot de passe. Copiez ce lien dans votre navigateur pour vous connecter et modifier votre mot de passe : ".PATH_TO_SITE."/#joueur/forgotten/$hash";
                $mail->send();
            }   catch (Exception $e) {
                EC::addError("Le message n'a pu être envoyé. Erreur :".$mail->ErrorInfo);
                EC::set_error_code(501);
                return false;
            }
            return array("message"=>"Email envoyé.");
        }
        EC::set_error_code(501);
        return false;
    }



}
?>
