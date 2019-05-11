<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nom %><br/><small class="text-info"><i class="fa fa-envelope fa-1">&nbsp;</i><%- username %></small></td>
<td><%- count_parties %></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton d'édition -->
		<a href="#joueur:<%- id %>/edit" class="btn btn-secondary btn-sm js-edit" role="button"><i class="fa fa-pencil" title="Modifier"></i></a>
		<!-- Bouton de mot de passe -->
		<a href="#joueur:<%- id %>/password" class="btn btn-secondary btn-sm js-editPwd" role="button"><i class="fa fa-key" title="Modifier"></i></a>
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" aria-hidden="true" title="Supprimer"></i></button>
	</div>
</td>
