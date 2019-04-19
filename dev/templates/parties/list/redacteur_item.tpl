<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nomProprietaire %><br/><small><i class="fa fa-gamepad"></i><%- titreEvenement %></small></td>
<td><%- dateDebut_fr %></td>
<td><% if(fini){%><i class="fa fa-flag-checkered"></i><%}%></td>
<td><%- duree %></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" aria-hidden="true" title="Supprimer"></i></button>
	</div>
</td>
