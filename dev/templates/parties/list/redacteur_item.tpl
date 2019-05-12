<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nomProprietaire %><br/><small><i class="fa fa-gamepad">&nbsp;</i><%- titreEvenement %></small></td>
<td align="center"><%- dateDebut_fr %></td>
<td><% if(fini){%><i class="fa fa-flag-checkered text-success"></i><%} else {%><i class="fa fa-times text-danger"></i><% } %></td>
<td align="center"><%if (!fini){ %><span class="text-danger"><%- dureeStr %></span><% } else { %><%- dureeStr %><% } %></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button>
	</div>
</td>
