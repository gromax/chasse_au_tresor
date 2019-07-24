<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%- tagCle %></td>
<td><%- regexCle %><%if ((prerequis!="")||(suite!="")) {%><br><small><%-prerequis%> &rarr; <%- suite %><% } %></td>
<td><%- pts %></td>
<td align="right">
  <div class="btn-group" role="group">
    <!-- Bouton d'édition -->
    <% if (moditem) { %><a href="#itemEvenement:<%- id %>/edit" class="btn btn-secondary btn-sm js-edit" role="button"><i class="fa fa-pencil" title="Modifier"></i></a><% } %>
    <!-- Bouton suppression -->
    <% if (!isshare) { %><button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" title="Supprimer"></i></button><% } %>
  </div>
</td>
