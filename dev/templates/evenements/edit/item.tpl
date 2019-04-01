<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- cle %></td>
<td><% if (type == 1){%><button type="button" class="btn btn-success btn-sm js-type" title="Changer de type">Deb</button><%} else if(type ==2){%><button type="button" class="btn btn-danger btn-sm js-type" title="Changer de type">Fin</button><%} else {%><button type="button" class="btn btn-secondary btn-sm js-type" title="Changer de type">Norm</button><%}%></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton d'édition -->
		<a href="#itemEvenement:<%- id %>/edit" class="btn btn-secondary btn-sm js-edit" role="button"><i class="fa fa-pencil" title="Modifier"></i></a>
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button>
	</div>
</td>
