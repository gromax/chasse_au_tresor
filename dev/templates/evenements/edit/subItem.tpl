<div class="card-header">
  <ul class="nav nav-pills card-header-pills">
    <li class="nav-item">
      <a class="nav-link js-up" href="#"><i class="fa fa-long-arrow-up"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-down" href="#"><i class="fa fa-long-arrow-down"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-delete" href="#"><i class="fa fa-trash"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-edit <% if (editMode) {%>active<%}%>" href="#"><i class="fa fa-pencil"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-show <% if (!editMode) {%>active<%}%>" href="#"><i class="fa fa-eye"></i></a>
    </li>
  </ul>
</div>
<% switch(type) { case "brut" : %>

<% if(editMode){%>
<div class="card-body">
  <form>
    <div class="form-group">
      <label for="subitem-<%-index%>">Contenu</label>
      <textarea class="form-control rounded-0" id="subitem-<%-index%>" rows="3" name="contenu"><%=contenu%></textarea>
    </div>
    <button type="submit" class="btn btn-primary js-submit">Valider</button>
  </form>
</div>
<%} else {%>
<div class="card-body">
  <% if(contenu!==""){%><%=contenu%><%} else {%><p class="text-muted">Élément vide</p><%}%>
</div>
<%}%>

<% break; case "url-image": %>

<% if(editMode){%>
<div class="card-body">
  <form>
    <div class="form-group">
      <label for="subitem-<%-index%>">Url</label>

      <div class="input-group">
        <input type="text" name="imgUrl" class="form-control" id="subitem-<%-index%>" placeholder="Entrez l'url" value="<%-imgUrl%>">
        <div class="input-group-append">
          <button class="btn btn-outline-secondary js-image" type="button"><i class="fa fa-file-image-o"></i></button>
        </div>
      </div>
    </div>
    <button type="submit" class="btn btn-primary js-submit">Valider</button>
  </form>
</div>
<%} else {
if (imgUrl !== ""){
  if (imgUrl.indexOf("/")==-1){
    // C'est une image uploadée
    %><img src="./image.php?src=<%-imgUrl%>" class="card-img"><%
  } else {
    // C'est une adresse web
    %><img src="<%-imgUrl%>" class="card-img"><%
  }
} else {%>
<div class="card-body">
  <p class="text-muted">Élément vide</p>
</div>
<%}
}%>

<% break; case "upload-image": %>

<% if(editMode){%>
<div class="card-body">
  <form>
    <input type="file" name="imgLoad">
    <button type="submit" class="btn btn-primary js-submit">Valider</button>
  </form>
</div>
<%} else {
if (imgName !== ""){%><img src="./image.php?src='<%-imgName%>'" class="card-img">
<%} else {%>
<div class="card-body">
  <p class="text-muted">Élément vide</p>
</div>
<%}
}%>

<% break; case "svg": %>

<% if(editMode){%>
<div class="card-body">
  Édition type svg
</div>
<%} else {%>
<div class="card-body">
  Affichage type svg
</div>
<%}%>

<% break; default: %>
<div class="card-body">
  <h5 class="card-title">Erreur !</h5>
  <p class="card-text">Cet élément a un type inconnu</p>
</div>
<%}%>
