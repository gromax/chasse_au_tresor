<div class="card" style="width: 18rem;">
  <img src='./image.php?src=<%-hash%>&seed=<%-Math.random()%>' class="card-img-top">
  <div class="card-body text-center">
    <div class="btn-group" role="group">
      <a class="btn btn-secondary js-prec" href="#" role="button">Précédent</a>
      <%if (selectButton) {%><a class="btn btn-secondary js-select" href="#" role="button">Choisir</a><%}%>
      <a class="btn btn-secondary js-suiv" href="#" role="button">Suivant</a>
    </div>
  </div>
  <div class="card-body text-center">
  <form>
    <div class="form-group">
      <label for="fileUploader">Uploader une image</label>
      <input type="file" class="form-control-file" id="fileUploader" name="image">
    </div>
    <button type="submit" class="btn btn-primary js-submit">Valider</button>
  </form>
  </div>
</div>
