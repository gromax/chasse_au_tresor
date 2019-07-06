<form>
  <div class="form-group">
    <label for="item-tagCle" class="control-label">Étiquette :</label>
    <input class="form-control" id="item-tagCle" name="tagCle" type="text" value="<%- tagCle %>" placeHolder="Étiquette"/>
    <small class="form-text text-muted">Entrez Accueil pour la page d'accueil.</small>
  </div>
    <div class="form-group">
    <label for="item-regexCle" class="control-label">Regex :</label>
    <div class="input-group mb-3">
      <input class="form-control" id="item-regexCle" name="regexCle" type="text" value="<%- regexCle %>" placeHolder="Expression régulière"/>
      <div class="input-group-append">
        <button class="btn btn-primary js-gps" type="button" title="géolocalisation"><i class="fa fa-map-marker"></i></button>
      </div>
   </div>
   <small class="form-text text-muted">Entrez ^accueil$ pour la page d'accueil.</small>
  </div>
  <div class="form-group">
    <label for="item-test" class="control-label">Test :</label>
    <input class="form-control js-test" id="item-test" type="text" value="" placeHolder="Test"/>
  </div>
  <div class="form-group">
    <label for="item-pts" class="control-label">points</label>
    <input class="form-control js-pts" id="item-pts" name="pts" type="text" value="<%- pts %>" placeHolder="Nombre de points"/>
  </div>
  <div class="form-group">
    <label for="item-prerequis" class="control-label">prérequis</label>
    <input class="form-control js-pts" id="item-prerequis" name="prerequis" type="text" value="<%- prerequis %>" placeHolder="Prérequis"/>
    <small class="form-text text-muted">forme id1&id2&id3|id4&id5...</small>
  </div>
  <button class="btn btn-success js-submit">Enregistrer</button>
</form>
