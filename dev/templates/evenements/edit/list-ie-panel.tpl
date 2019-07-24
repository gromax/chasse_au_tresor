<div class="card">
<div class="card-header text-white bg-primary"><h3><a href="#" class="btn btn-dark js-parent" role="button" title="Liste des événements"><i class="fa fa-level-up"></i></a> <% if(partagesView) { %><a href="#" class="btn btn-success js-partage" role="button" title="Voir les items"><i class="fa fa-users"></i></a><% } else { if(!isshare) { %><a href="#" class="btn btn-dark js-partage" role="button" title="Voir les partages"><i class="fa fa-users"></i></a><% }} %> <%- titre %></h3></div>
<div class="card-body">
<p class="card-text"><strong>description :</strong> <%- description %></p>
<% if (actif) { %>
<p class="card-text"><strong>Actif</strong></p>
<% } else { %>
<p class="card-text"><strong>Inactif</strong></p>
<% } %>
<p class="card-text"><i class="fa fa-link"></i>&nbsp;<span class="text-primary"><%- baseUrl %>partie/hash:<%- hash %></span></p>
</div>
</div>
