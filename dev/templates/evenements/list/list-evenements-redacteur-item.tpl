<td><span class="badge badge-pill badge-primary"><%- id %></span></td>
<td><%if (isshare) {%><i class="fa fa-users" title="Cet événement a été partagé avec vous par son propriétaire"> <%}%><%- titre %> <small class="text-danger"><i class="fa fa-user" title="Propriétaire"></i>&nbsp;<%- nomProprietaire %> &nbsp; <i class="fa fa-key"></i>&nbsp;<%- hash %></small><% if (description!=""){ %><br/><span class="text-info"><i class="fa fa-file-text"></i>&nbsp;</i><%- description %><% } %></span></td>
<td><%- count_parties %></td>
<td><%- ptsEchecs %></td>
<td align="right">
  <div class="btn-group" role="group">
    <% if (modevent) {
    %><!-- Bouton d'édition -->
    <a href="#" class="btn btn-secondary btn-sm js-edit" role="button"><i class="fa fa-pencil" title="Modifier"></i></a>
    <!-- Bouton de visibilité -->
    <% if (visible) { %>
    <button type="button" class="btn btn-success btn-sm js-visible"><i class="fa fa-eye" title="Rendre invisible"></i></button>
    <% } else { %>
    <button type="button" class="btn btn-danger btn-sm js-visible"><i class="fa fa-eye-slash" title="Rendre visible"></i></button>
    <% } %>
    <!-- Bouton d'activité -->
    <% if (actif) { %>
    <button type="button" class="btn btn-success btn-sm js-actif"><i class="fa fa-check-circle-o" title="Désactiver"></i></button>
    <% } else { %>
    <button type="button" class="btn btn-danger btn-sm js-actif"><i class="fa fa-ban" title="Activer"></i></button>
    <% } %>
    <!-- Bouton sauve échec -->
    <% if (sauveEchecs) { %>
    <button type="button" class="btn btn-success btn-sm js-sauveEchecs"><i class="fa fa-window-close" title="Sauver échecs : actif"></i></button>
    <% } else { %>
    <button type="button" class="btn btn-danger btn-sm js-sauveEchecs"><i class="fa fa-window-close" title="Sauver échecs : inactif"></i></button>
    <% }
    } %>
    <% if (!isshare) {
    %><!-- Bouton suppression -->
    <button type="button" class="btn btn-danger btn-sm js-delete"><i class="fa fa-trash" aria-hidden="true" title="Supprimer"></i></button><%
    } %>
  </div>
</td>
