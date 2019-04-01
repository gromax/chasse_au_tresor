<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- titre %> <small class="text-danger"><i class="fa fa-link"></i><%- nomProprietaire %></small><br/><span class="text-info"><i class="fa fa-file-text"></i></i><%- description %></span></td>
<td><%- count_parties %></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton d'activité -->
		<% if (actif) { %>
		<button type="button" class="btn btn-success btn-sm js-actif"><i class="fa fa-check-circle-o" title="Désactiver"></i></button>
		<% } else { %>
		<button type="button" class="btn btn-danger btn-sm js-actif"><i class="fa fa-ban" title="Activer"></i></button>
		<% } %>
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" aria-hidden="true" title="Supprimer"></i></button>
	</div>
</td>
