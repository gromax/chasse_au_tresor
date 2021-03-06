<nav class="navbar navbar-dark bg-dark">
  <a href="#" class="navbar-brand js-parent" title="Item parent"><i class="fa fa-level-up"></i> <%-titreEvenement %></a>
  <span class="navbar-text mr-auto">
     / <%- tagCle %> <span class="badge badge-pill badge-primary"><%- id %></span>
  </span>
  <form class="form-inline">
    <div class="btn-group" role="group">
      <% if (moditem) {
      %><button type="button" class="btn btn-secondary btn-sm js-images" title="Modifier les images"><i class="fa fa-file-image-o"></i></button>
      <div class="btn-group" role="group">
        <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown">
          Ajout d'une zone
        </button>
        <div class="dropdown-menu">
          <a class="dropdown-item js-add" type="brut" href="#">Brut</a>
          <a class="dropdown-item js-add" type="image" href="#">Image</a>
          <a class="dropdown-item js-add" type="svg">Svg</a>
        </div>
      </div><% } else {
      %><button type="button" class="btn btn-secondary btn-sm js-images" title="Voir les images"><i class="fa fa-file-image-o"></i></button><% }
    %></div>
  </form>
</nav>
<br/>
