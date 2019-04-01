<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Logged;
use BDDObject\Evenement;
use BDDObject\Joueur;
use BDDObject\Redacteur;
use BDDObject\ClePartie;
use BDDObject\Partie;
use BDDObject\ItemEvenement;
use BDDObject\Image;

class data
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
    /**
     * renvoie les infos sur l'objet d'identifiant id
     * @return array
     */

    public function customFetch()
    {
        // Renvoie les données demandées

        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::addError("Déconnecté !");
            EC::set_error_code(401);
            return false;
        }
        $asks = explode("&",$this->params['asks']);

        $collections = array(
            "evenements" => "Evenement",
            "redacteurs" => "Redacteur",
            "joueurs" => "Joueur",
            "parties" => "Partie",
            "clesPartie" => "ClePartie",
            "itemsEvenement" => "ItemEvenement",
            "images" => "Image"
            );

        if ($uLog->isRoot())
            $options = array("root" => true);
        elseif ($uLog->isRedacteur())
            $options = array("redacteur"=>$uLog->getId());
        else
            $options = array("joueur"=>$uLog->getId());

        $output = array();
        foreach ($collections as $key => $class){
            $classFullName = "BDDObject\\".$class;
            if (in_array($key, $asks)){
                $answer = $classFullName::getList($options);
                if (isset($answer["error"]) && $answer["error"]) {
                    EC::addError($answer["message"]);
                    EC::set_error_code(501);
                    return false;
                } else {
                    $output[$key] = $answer;
                }
            }
        }

        return $output;
    }



}
?>
