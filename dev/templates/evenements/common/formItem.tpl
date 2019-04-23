<form>
  <div class="form-group">
    <label for="item-tagCle" class="control-label">Étiquette :</label>
    <input class="form-control" id="item-tagCle" name="tagCle" type="text" value="<%- tagCle %>" placeHolder="Étiquette"/>
  </div>
    <div class="form-group">
    <label for="item-regexCle" class="control-label">Regex :</label>
    <input class="form-control" id="item-regexCle" name="regexCle" type="text" value="<%- regexCle %>" placeHolder="Expression régulière"/>
  </div>
  <div class="form-group">
    <label for="item-test" class="control-label">Test :</label>
    <input class="form-control js-test" id="item-test" type="text" value="" placeHolder="Test"/>
  </div>
  <button class="btn btn-success js-submit">Enregistrer</button>
</form>
