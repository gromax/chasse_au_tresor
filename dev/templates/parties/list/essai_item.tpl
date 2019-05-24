<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><% if (tagCle!="") { %><i class="fa fa-tag"></i>&nbsp;</i><%- tagCle %><br/><small><%- essai %></small><% } else { %><%- essai %><% } %></td>
<td align="center"><%- pts %></td>
<td align="center"><%- date_fr %></td>
<td align="right">
	<div class="btn-group" role="group">
		<!-- Bouton suppression -->
		<button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button>
	</div>
</td>
