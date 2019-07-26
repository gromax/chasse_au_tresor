<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- nom %></td>
<td align="right">
  <div class="btn-group" role="group">
    <button type="button" class="btn <%if (modevent) { %>btn-success<% } else { %>btn-danger<% } %> btn-sm js-modevent"><i class="fa fa-edit" title="Droit de modifier l'événement"></i>&nbsp;Événement</button>
    <button type="button" class="btn <%if (moditem) { %>btn-success<% } else { %>btn-danger<% } %> btn-sm js-moditem"><i class="fa fa-edit" title="Droit de modifier les items"></i>&nbsp;Items</button>
    <button type="button" class="btn <%if (modessai) { %>btn-success<% } else { %>btn-danger<% } %> btn-sm js-modessai"><i class="fa fa-edit" title="Droit de modifier les essais joueurs"></i>&nbsp;Essais joueurs</button>
  </div>
</td>
<td align="right">
  <button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" aria-hidden="true" title="Supprimer"></i></button>
</td>
