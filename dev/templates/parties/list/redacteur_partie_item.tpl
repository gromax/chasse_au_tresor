<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nomProprietaire %><br/><small><i class="fa fa-gamepad">&nbsp;</i><%- titreEvenement %></small></td>
<td align="center"><%- dateDebut_fr %></td>
<td align="center"><%- score %></td>
<td align="center"><% if(dureeStr=="") { %>&infin;<% } else { %><%- dureeStr %><% } %></td>
<td align="right">
  <div class="btn-group" role="group">
    <!-- Bouton suppression -->
    <button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button>
  </div>
</td>
