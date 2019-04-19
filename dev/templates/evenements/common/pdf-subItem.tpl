<% if (redacteurMode) {%>
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
<% }
if(editMode){%>
<div class="card-body">
  <form>
    <div class="form-group">
      <label for="subitem-<%-index%>">Url</label>

      <div class="input-group">
        <input type="text" name="url" class="form-control" id="subitem-<%-index%>" placeholder="Entrez l'url" value="<%-url%>">
        <div class="input-group-append">
          <button class="btn btn-outline-secondary js-image" type="button"><i class="fa fa-file-pdf-o"></i></button>
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

