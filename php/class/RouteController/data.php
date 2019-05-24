<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Evenement;
use BDDObject\Joueur;
use BDDObject\Redacteur;
use BDDObject\EssaiJoueur;
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
            "essaisJoueur" => "EssaiJoueur",
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

    private function helperPartieFetch($partie, $evenement, $idJoueur, $cle)
    {
        // Il faut voir si une clé est proposée
        $itemEvenement = null;

        // on doit chercher un itEvent avec cette clé
        $itemEvenement = ItemEvenement::tryCle($evenement->getId(), $cle);
        if ($itemEvenement!==null)
        {
            // on inserre la clé correspondante dans la liste des essaiJoueur
            if ($cle===null)
            {
                $essai = "Accueil";
            }
            else
            {
                $essai = $cle;
            }
            $dataNewEssai = array(
                "idPartie"=>$partie->getId(),
                "essai"=>$essai,
                "date"=> date("Y-m-d H:i:s"),
                "idItem"=>$itemEvenement->getId()
                );
            $essaiJoueur = new EssaiJoueur();
            $validation = $essaiJoueur->insert_validation($dataNewEssai);
            if ($validation===true)
            {
                $essaiJoueur->update($dataNewEssai);
            }
            // inutile de charger cette clé, elle sera automatiquement chargée
            // si la clé n'est pas crée car existait déjà, c'est idem
        }

        $essais = EssaiJoueur::getList(array("partie"=>$partie->getId()));

        $output = array(
            "partie"=>$partie->getValues(),
            "evenement"=>$evenement->getValues(),
            "essais"=>$essais,
            );

        if ($itemEvenement!= null)
        {
            $output["item"] = $itemEvenement->getValues();
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
            $idJoueur = $ac->getLoggedUserId();
            $partie = Partie::getObject($id);
            if (isset($_GET["cle"]) && ($_GET["cle"]!=""))
            {
                $cle = str_replace("__"," ", $_GET["cle"]);
            }
            else
            {
                $cle = null;
            }

            if ($partie===null)
            {
                EC::set_error_code(404);
                return false;
            }
            if ($partie->getIdProprietaire() !== $idJoueur)
            {
                EC::set_error_code(403);
                return false;
            }
            $evenement = $partie->getEvenement();

            return $this->helperPartieFetch($partie,$evenement,$idJoueur,$cle);
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
    }

    public function getPartieWithHash()
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
            $hash = $this->params['hash'];
            $idJoueur = $ac->getLoggedUserId();
            // On vérifie l'existence de l'événement
            $evenement = Evenement::getWithHash($hash);
            if ($evenement===null)
            {
            // Le hash n'existe pas ou l'évent n'est pas actif
                EC::set_error_code(404);
                return false;
            }
            // On cherche la partie
            $partie = Partie::getLinkedWithEvenementEtJoueur($evenement->getId(), $idJoueur);
            if ($partie===null)
            {
                // il faut créer la partie
                $data = array("idProprietaire"=>$idJoueur, "idEvenement"=>$evenement->getId());
                $partie = new Partie();
                $idPartie = $partie->update($data);
                if ($idPartie===null){
                    EC::set_error_code(501);
                    return false;
                }
            }
            // On peut poursuivre avec la partie et l'événement
            return $this->helperPartieFetch($partie,$evenement,$idJoueur,null);
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
    }

    public function getEssaisFromPartie()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::addError("Déconnecté !");
            EC::set_error_code(401);
            return false;
        }

        if (!$ac->isRedacteur())
        {
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $idRedacteur = $ac->getLoggedUserId();

        $partie = Partie::getObject($id);
        if ($partie===null)
        {
            EC::set_error_code(404);
            return false;
        }

        $evenement = $partie->getEvenement();
        if ($evenement===null)
        {
            EC::set_error_code(501);
            return false;
        }

        if ($evenement->getIdProprietaire()!=$idRedacteur)
        {
            EC::set_error_code(403);
            return false;
        }

        $essais = EssaiJoueur::getList(array("partie"=>$id));
        return array(
            "partie"=>$partie->getValues(),
            "evenement"=>$evenement->getValues(),
            "essais"=>$essais,
        );


    }

}
?>
