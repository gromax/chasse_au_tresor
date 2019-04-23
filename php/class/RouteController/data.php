<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Evenement;
use BDDObject\Joueur;
use BDDObject\Redacteur;
use BDDObject\ClePartie;
use BDDObject\Partie;
use BDDObject\ItemEvenement;
use BDDObject\Image;
use BDDObject\Fichier;

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
        $ac = new AC();
        if (!$ac->connexionOk())
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
            "images" => "Image",
            "fichiers" => "Fichier"
            );

        if ($ac->isRoot())
            $options = array("root" => true);
        elseif ($ac->isRedacteur())
            $options = array("redacteur"=> $ac->getLoggedUserId());
        else
            $options = array("joueur"=> $ac->getLoggedUserId());

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

    public function partieFetch()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::addError("Déconnecté !");
            EC::set_error_code(401);
            return false;
        }

        if ($ac->isJoueur())
        {
            $id = (integer) $this->params['id'];
            $partie = Partie::getObject($id);
            if ($partie===null)
            {
                EC::set_error_code(404);
                return false;
            }
            if ($partie->getIdProprietaire() !== $ac->getLoggedUserId())
            {
                EC::set_error_code(403);
                return false;
            }
            $evenement = $partie->getEvenement();

            // Il faut voir si une clé est proposée
            $itemEvenement = null;
            if (isset($_GET["cle"]))
            {
                $cle = trim($_GET["cle"]);
                if ($cle!="")
                {
                    // on doit chercher un itEvent avec cette clé
                    $itemEvenement = ItemEvenement::tryCle($evenement->getId(), $cle);
                    if ($itemEvenement!==null)
                    {
                        // on inserre la clé correspondante dans la liste des clePartie
                        $dataNewCle = array(
                            "idPartie"=>$id,
                            "essai"=>$cle,
                            "date"=> date("Y-m-d H:i:s"),
                            "idItem"=>$itemEvenement->getId()
                            );
                        $clePartie = new ClePartie();
                        $validation = $clePartie->insert_validation($dataNewCle);
                        if ($validation===true)
                        {
                            $clePartie->update($dataNewCle);
                        }
                        // inutile de charger cette clé, elle sera automatiquement chargée
                        // si la clé n'est pas crée car existait déjà, c'est idem
                    }
                }
            }

            $cles = ClePartie::getList(array("partie"=>$id));
            if ($evenement !==null)
            {
                $startCles = ItemEvenement::getList(array("starting"=>$evenement->getId()));
            }
            else
            {
                $startCles = array();
            }

            $tagCleColumn = array_column($startCles,"tagCle");

            $output = array(
                "partie"=>$partie->getValues(),
                "evenement"=>$evenement->getValues(),
                "cles"=>$cles,
                "startCles"=>$tagCleColumn
                );

            if ($itemEvenement!= null)
            {
                $output["item"] = $itemEvenement->getValues();
            }

            return $output;
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
    }



}
?>
