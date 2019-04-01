<nav class="navbar navbar-dark bg-dark">
	<span class="navbar-text">
		<span class="badge badge-pill badge-primary"><%- id %></span> <%- cle %>
	</span>
	<form class="form-inline">
		<div class="btn-group" role="group">
			<% if (type == 1){%><button type="button" class="btn btn-success btn-sm js-type" title="Changer de type">Deb</button><%} else if(type ==2){%><button type="button" class="btn btn-danger btn-sm js-type" title="Changer de type">Fin</button><%} else {%><button type="button" class="btn btn-secondary btn-sm js-type" title="Changer de type">Norm</button><%}%>
			<button type="button" class="btn btn-secondary btn-sm js-images" title="Modifier les images"><i class="fa fa-file-image-o"></i></button>
			<div class="btn-group" role="group">
				<button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown">
					Ajout d'une zone
				</button>
				<div class="dropdown-menu">
					<a class="dropdown-item js-add" type="brut" href="#">Brut</a>
					<a class="dropdown-item js-add" type="url-image" href="#">Url-Image</a>
					<a class="dropdown-item js-add" type="upload-image" href="#">Upload-Image</a>
					<a class="dropdown-item js-add" type="svg">Svg</a>
				</div>
			</div>
		</div>

	</form>
</nav>
<br/>
