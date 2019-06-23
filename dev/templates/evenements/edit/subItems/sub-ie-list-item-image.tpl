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
        <input type="text" name="imgUrl" class="form-control" id="subitem-<%-index%>" placeholder="Entrez l'url" value="<%-imgUrl%>">
        <div class="input-group-append">
          <button class="btn btn-outline-secondary js-image" type="button"><i class="fa fa-file-image-o"></i></button>
        </div>
      </div>
      <div class="input-group">
        <input type="text" name="width" class="form-control" id="subitem-width" placeholder="Largeur" value="<%-width %>">
        <div class="input-group-append">
          <span class="input-group-text"><i class="fa fa-arrows-h"></i></span>
        </div>
        <div class="invalid-feedback">
          Par exemple 50px ou 85%.
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
    _imgUrl = imgUrl.split(".");
    if (_imgUrl.length>1) { ext = _imgUrl[1]; } else { ext = ""; }
    if(ext=="pdf")
    {
    %><embed src='./image.php?src=<%-_imgUrl[0]%>&ext=pdf&seed=<%-Math.random()%>' height=400 type='application/pdf'/><%
    }
    else
    {
      if ((width=="100%")||!redacteurMode)
      {
        %><img src="./image.php?src=<%-_imgUrl[0]%>" class="card-img"><%
      }
      else
      {
        %><div class="card-body"><img src="./image.php?src=<%-_imgUrl[0]%>" width="<%-width%>"></div><%
      }
    }
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

