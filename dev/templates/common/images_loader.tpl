<div class="card" <%if (ext!="pdf") {%>style="width: 18rem;"<%}%>>
  <% if (ext=="pdf") {%>
  <embed src='./image.php?src=<%-hash%>&ext=pdf&seed=<%-Math.random()%>' height=200 type='application/pdf'/>
  <% } else { %>
  <img src='./image.php?src=<%-hash%>&ext=<%- ext%>&seed=<%-Math.random()%>' width:100% class="card-img-top">
  <% } %>

  <div class="card-body text-center">
    <div class="btn-group" role="group">
      <a class="btn btn-secondary js-prec" href="#" role="button">Précédent</a>
      <%if (selectButton) {%><a class="btn btn-secondary js-select" href="#" role="button">Choisir</a><%}%>
      <%if (delFile) {%><button type="button" class="btn btn-danger js-delete" title="Supprimer"><i class="fa fa-trash" title="Supprimer"></i></button><%}%>
      <a class="btn btn-secondary js-suiv" href="#" role="button">Suivant</a>
    </div>
  </div>
  <% if (addFile) {%>
  <div class="card-body text-center">
    <form>
      <div class="form-group">
        <label for="fileUploader">Uploader une image</label>
        <input type="file" class="form-control-file" id="fileUploader" name="image" accept=".jpg,.jpeg,.png,.pdf">
      </div>
      <button type="submit" class="btn btn-primary js-submit">Valider</button>
    </form>
  </div>
  <%}%>
</div>
