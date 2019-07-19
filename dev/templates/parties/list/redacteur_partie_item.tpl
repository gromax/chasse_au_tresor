<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nomProprietaire %><br/><small><a href='#' class='badge badge-secondary js-event-filter'><i class="fa fa-filter"></i>&nbsp;<%- titreEvenement %></a></small></td>
<td align="center"><%- dateDebut_fr %></td>
<td align="center"><%- score %></td>
<td align="center"><% if(dureeStr=="") { %>&infin;<% } else { %><%- dureeStr %><% } %></td>
<td align="right">
  <div class="btn-group" role="group">
    <!-- Bouton suppression -->
    <button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button>
  </div>
</td>
